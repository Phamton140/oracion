// Script CLI que construye:
//   1) Índice semántico BM25 → assets/data/semantic_index.bin
//   2) Embeddings subword (Word2Vec-lite) → assets/data/verse_embeddings.bin
//
// Salidas:
//   - assets/data/semantic_index.bin
//   - assets/data/verse_embeddings.bin
//
// Uso (desde la raíz del repo):
//   dart run tool/build_semantic_index.dart
//
// Requiere que `bible_assets.db` esté presente en
// `assets/bible/bible_assets.db` (lo genera `tools/build_bible_db.py`).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:oracion/core/constants/bible_constants.dart';
import 'package:oracion/features/engine/embeddings/embedding_store.dart';
import 'package:oracion/features/engine/embeddings/word2vec_trainer.dart';
import 'package:oracion/features/engine/semantic/bm25_scorer.dart';
import 'package:oracion/features/engine/semantic/semantic_index.dart';
import 'package:oracion/features/engine/semantic/semantic_index_format.dart';
import 'package:oracion/features/engine/semantic/semantic_tokenizer.dart';
import 'package:sqlite3/sqlite3.dart';

Future<void> main() async {
  final DateTime t0 = DateTime.now();
  final String assetDb = 'assets/bible/bible_assets.db';
  final String outBm25 = BibleConstants.semanticIndexAssetPath;
  final String outEmb = 'assets/data/verse_embeddings.bin';

  stdout.writeln('▶ Abriendo $assetDb (read-only)…');
  final Sqlite3 sqlite = sqlite3;
  final Database src = sqlite.open(assetDb, mode: OpenMode.readOnly);
  try {
    // 1. Leer versículos.
    stdout.writeln('▶ Leyendo versículos…');
    final ResultSet verses = src.select(
      'SELECT id, book, book_number, body FROM verses ORDER BY id',
    );
    final List<_VerseRow> verseRows = <_VerseRow>[];
    for (final Row r in verses) {
      verseRows.add(_VerseRow(
        id: r['id'] as int,
        book: r['book'] as String,
        bookNumber: r['book_number'] as int,
        body: r['body'] as String,
      ));
    }
    stdout.writeln('  ${verseRows.length} versículos.');

    // 2. Construir documentos (versículos + libros).
    final List<String> documents = <String>[];
    final List<int> docKinds = <int>[];
    final List<int> docRefIds = <int>[];
    for (final _VerseRow v in verseRows) {
      documents.add('${v.book} ${v.body}');
      docKinds.add(BibleConstants.docKindVerse);
      docRefIds.add(v.id);
    }
    final Set<int> seenBooks = <int>{};
    for (final _VerseRow v in verseRows) {
      if (seenBooks.add(v.bookNumber)) {
        documents.add(v.book);
        docKinds.add(BibleConstants.docKindBook);
        docRefIds.add(v.bookNumber);
      }
    }
    stdout.writeln('  ${documents.length} documentos.');

    // 3. Tokenizar.
    stdout.writeln('▶ Tokenizando (word 1-2 grams)…');
    const SemanticTokenizer tokenizer = SemanticTokenizer(
      wordNgramMin: 1,
      wordNgramMax: 2,
      charNgramMin: 0,
      charNgramMax: 0,
    );
    final List<List<String>> tokenized = <List<String>>[];
    for (final String d in documents) {
      tokenized.add(tokenizer.tokenize(d));
    }

    // 4. BM25.
    stdout.writeln('▶ Ajustando BM25…');
    final Bm25Scorer scorer = const Bm25Scorer();
    final Bm25Corpus corpus = scorer.fit(
      tokenizedDocs: tokenized,
      minDf: BibleConstants.minDocumentFrequency,
      maxDfRatio: BibleConstants.maxDocumentFrequencyRatio,
    );
    stdout.writeln('  Vocabulario: ${corpus.vocabulary.length} términos.');

    // 5. Reconstruir Bm25CorpusData con sparse vectors.
    final Map<String, int> termId = <String, int>{
      for (int i = 0; i < corpus.vocabulary.length; i++) corpus.vocabulary[i]: i,
    };
    final List<List<int>> docTerms = <List<int>>[];
    final List<List<double>> docWeights = <List<double>>[];
    for (final List<String> toks in tokenized) {
      final Map<int, int> counts = <int, int>{};
      for (final String t in toks) {
        final int? id = termId[t];
        if (id == null) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      final List<MapEntry<int, int>> entries = counts.entries.toList()
        ..sort((MapEntry<int, int> a, MapEntry<int, int> b) =>
            a.key.compareTo(b.key));
      docTerms.add(<int>[for (final MapEntry<int, int> e in entries) e.key]);
      docWeights.add(<double>[
        for (final MapEntry<int, int> e in entries) e.value.toDouble(),
      ]);
    }
    final Bm25CorpusData data = Bm25CorpusData(
      vocabulary: corpus.vocabulary,
      idf: corpus.idf,
      docKinds: docKinds,
      docRefIds: docRefIds,
      documents: docTerms,
      docWeightsPerDoc: docWeights,
      avgDocLength: corpus.avgDocLength,
    );
    final SemanticIndex idx = SemanticIndex.fromCorpus(data);
    stdout.writeln('  Índice: ${idx.numDocs} docs, '
        '${idx.numTerms} términos, ${idx.numNonZeros} no-ceros.');

    // 6. Serializar BM25.
    stdout.writeln('▶ Serializando $outBm25…');
    final Uint8List bm25Bytes = _serializeBm25(idx, data);
    await File(outBm25).parent.create(recursive: true);
    await File(outBm25).writeAsBytes(bm25Bytes, flush: true);
    stdout.writeln('  Tamaño: ${(bm25Bytes.length / 1024).toStringAsFixed(1)} KB.');

    // 7. Entrenar embeddings subword.
    stdout.writeln('▶ Entrenando Word2Vec subword…');
    final Word2VecTrainer trainer = Word2VecTrainer(
      dim: 100,
      window: 5,
      minCount: 5,
      negativeSamples: 5,
      epochs: 3,
      subwordMin: 3,
      subwordMax: 6,
    );
    final WordEmbedding embModel = trainer.train(tokenized);

    // 8. Pre-agregar vectores por versículo.
    stdout.writeln('▶ Pre-agregando vectores de versículo…');
    final List<List<double>> verseVectors = <List<double>>[];
    for (int i = 0; i < verseRows.length; i++) {
      final List<String> toks = tokenized[i];
      verseVectors.add(embModel.vectorOfDoc(toks));
    }
    final EmbeddingStore finalStore = EmbeddingStore.fromMemory(
      vocab: embModel.subwords,
      vectors: embModel.inputVectors,
      docVectors: verseVectors,
    );
    stdout.writeln('  Vocab: ${finalStore.vocabSize} subwords, '
        'dim: ${finalStore.dim}.');

    // 9. Serializar embeddings.
    stdout.writeln('▶ Serializando $outEmb…');
    final Uint8List embBytes = finalStore.toBytes();
    await File(outEmb).writeAsBytes(embBytes, flush: true);
    stdout.writeln('  Tamaño: ${(embBytes.length / 1024 / 1024).toStringAsFixed(2)} MB.');

    final Duration dt = DateTime.now().difference(t0);
    stdout.writeln('✓ Listo en ${dt.inMilliseconds}ms.');
  } finally {
    src.close();
  }
}

Uint8List _serializeBm25(SemanticIndex idx, Bm25CorpusData data) {
  final int N = idx.numDocs;
  final int T = idx.numTerms;
  final int Z = idx.numNonZeros;

  int p = SemanticIndexFormat.headerSize;
  final int offIndptr = SemanticIndexFormat.align8(p);
  p = offIndptr + (N + 1) * 4;
  final int offIndices = SemanticIndexFormat.align8(p);
  p = offIndices + Z * 4;
  final int offData = SemanticIndexFormat.align8(p);
  p = offData + Z * 4;
  final int offVocab = SemanticIndexFormat.align8(p);
  p = offVocab + (T + 1) * 4;
  final int offVocabData = SemanticIndexFormat.align8(p);

  final List<int> vocabOffsets = <int>[];
  final BytesBuilder bbVocabData = BytesBuilder();
  for (final String t in data.vocabulary) {
    vocabOffsets.add(bbVocabData.length);
    bbVocabData.add(utf8.encode(t));
  }
  final Uint8List vocabData = bbVocabData.toBytes();
  vocabOffsets.add(vocabData.length);

  p = offVocabData + vocabData.length;
  final int offMeta = SemanticIndexFormat.align8(p);
  p = offMeta + N * 5;
  final int offIdf = SemanticIndexFormat.align8(p);
  p = offIdf + T * 4;
  final int offDocLengths = SemanticIndexFormat.align8(p);
  // DocLengths: N+1 (último = avgDocLength)
  p = offDocLengths + (N + 1) * 4;
  final int totalSize = p;

  final ByteData out = ByteData(totalSize);
  final Uint8List headerBytes = SemanticIndexFormat.encodeHeader(
    numDocs: N,
    numTerms: T,
    numNonZeros: Z,
    offsetIndptr: offIndptr,
    offsetIndices: offIndices,
    offsetData: offData,
    offsetVocab: offVocab,
    offsetVocabData: offVocabData,
    offsetMeta: offMeta,
    offsetIdf: offIdf,
    offsetDocNorms: offDocLengths,
  );
  for (int i = 0; i < headerBytes.length; i++) {
    out.setUint8(i, headerBytes[i]);
  }
  final Int32List indptr = idx.indptrView;
  final Int32List indices = idx.indicesView;
  final Float32List dataArr = idx.dataView;
  for (int i = 0; i < indptr.length; i++) {
    out.setInt32(offIndptr + i * 4, indptr[i], Endian.little);
  }
  for (int i = 0; i < indices.length; i++) {
    out.setInt32(offIndices + i * 4, indices[i], Endian.little);
    out.setFloat32(offData + i * 4, dataArr[i], Endian.little);
  }
  for (int i = 0; i < vocabOffsets.length; i++) {
    out.setUint32(offVocab + i * 4, vocabOffsets[i], Endian.little);
  }
  for (int i = 0; i < vocabData.length; i++) {
    out.setUint8(offVocabData + i, vocabData[i]);
  }
  for (int i = 0; i < N; i++) {
    out.setUint8(offMeta + i * 5, data.docKinds[i]);
    out.setUint32(offMeta + i * 5 + 1, data.docRefIds[i], Endian.little);
  }
  final Float32List idf = idx.idfView;
  for (int i = 0; i < T; i++) {
    out.setFloat32(offIdf + i * 4, idf[i], Endian.little);
  }
  final Float32List docLens = idx.docLengthsView;
  for (int i = 0; i < N; i++) {
    out.setFloat32(offDocLengths + i * 4, docLens[i], Endian.little);
  }
  out.setFloat32(offDocLengths + N * 4, idx.avgDocLength, Endian.little);
  return out.buffer.asUint8List();
}

class _VerseRow {
  const _VerseRow({
    required this.id,
    required this.book,
    required this.bookNumber,
    required this.body,
  });

  final int id;
  final String book;
  final int bookNumber;
  final String body;
}
