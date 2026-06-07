import '../../../core/database/daos/context_dao.dart';
import '../../../core/database/daos/verses_dao.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/lexicon_service.dart';
import '../domain/verse_candidate.dart';
import 'mmr.dart';

/// Resultado del selector para una consulta.
class SelectionResult {
  const SelectionResult({
    required this.verses,
    required this.matchedTags,
    required this.usedFallback,
  });

  /// Versículos seleccionados (top N, ya en orden de presentación).
  final List<Verse> verses;

  /// Tags que hicieron match con la consulta (los que se usaron para
  /// buscar). Puede ser vacío si hubo fallback aleatorio.
  final List<String> matchedTags;

  /// True si no hubo tags matcheados y se usó fallback aleatorio.
  final bool usedFallback;
}

/// Selector de versículos: el corazón del Bible Engine v1.
///
/// Pipeline:
///   1. userInput → tags (LexiconService)
///   2. tags → ids candidatos (VersesDao.idsByAnyTag, topK=50)
///   3. ids → verses + tags (batch) → score = #tags matcheados
///   4. filtrar ya mostrados (anti-repetición)
///   5. aplicar MMR lite (diversidad por libro)
///   6. devolver top N
///   7. registrar IDs mostrados en el context (para próximas consultas)
///
/// Si no hay tags matcheados o no hay candidatos, hace fallback
/// aleatorio (también filtrando ya mostrados).
class VerseSelector {
  VerseSelector({
    required this.versesDao,
    required this.lexicon,
    required this.contextDao,
    this.mmr = const MmrSelector(),
    this.topK = 50,
    this.finalN = 3,
  });

  final VersesDao versesDao;
  final LexiconService lexicon;
  final ContextDao contextDao;
  final MmrSelector mmr;

  /// Máximo de candidatos a recuperar de la DB.
  final int topK;

  /// Número de versículos a devolver al chat.
  final int finalN;

  Future<SelectionResult> select({
    required String userInput,
    required int conversationId,
  }) async {
    final List<String> tags = lexicon.tokensToTags(userInput);
    final List<int> shown =
        await contextDao.readShownVerses(conversationId);
    final Set<int> shownSet = shown.toSet();

    if (tags.isEmpty) {
      // Fallback: random sin tags.
      final List<Verse> fallback = await versesDao.randomExcluding(
        shownSet,
        limit: finalN,
      );
      if (fallback.isNotEmpty) {
        await _markShown(conversationId, fallback.map((Verse v) => v.id).toList());
      }
      return SelectionResult(
        verses: fallback,
        matchedTags: const <String>[],
        usedFallback: true,
      );
    }

    final List<int> candidateIds =
        await versesDao.idsByAnyTag(tags, limit: topK);
    if (candidateIds.isEmpty) {
      // Hay tags pero no hay candidatos (puede pasar si los tags
      // son nuevos o no tienen versículos asignados). Fallback.
      final List<Verse> fallback = await versesDao.randomExcluding(
        shownSet,
        limit: finalN,
      );
      if (fallback.isNotEmpty) {
        await _markShown(conversationId, fallback.map((Verse v) => v.id).toList());
      }
      return SelectionResult(
        verses: fallback,
        matchedTags: tags,
        usedFallback: true,
      );
    }

    // Cargar verses y tags en batch.
    final List<Verse> verses = await versesDao.versesByIds(candidateIds);
    final Map<int, List<String>> tagsByVerse =
        await versesDao.tagsByVerseIds(candidateIds);

    // Construir candidatos, filtrar ya mostrados, calcular score.
    final List<VerseCandidate> candidates = <VerseCandidate>[];
    for (final Verse v in verses) {
      if (shownSet.contains(v.id)) continue;
      final List<String> vTags = tagsByVerse[v.id] ?? <String>[];
      final List<String> matched = vTags
          .where((String t) => tags.contains(t))
          .toList(growable: false);
      candidates.add(VerseCandidate(
        verse: v,
        score: matched.length.toDouble(),
        matchedTags: matched,
      ));
    }

    if (candidates.isEmpty) {
      // Todos los candidatos ya fueron mostrados. Fallback aleatorio
      // para no dejar al usuario sin respuesta.
      final List<Verse> fallback = await versesDao.randomExcluding(
        shownSet,
        limit: finalN,
      );
      if (fallback.isNotEmpty) {
        await _markShown(conversationId, fallback.map((Verse v) => v.id).toList());
      }
      return SelectionResult(
        verses: fallback,
        matchedTags: tags,
        usedFallback: true,
      );
    }

    // Aplicar MMR y devolver top N.
    final List<VerseCandidate> picked = mmr.select(candidates, finalN);
    final List<Verse> finalVerses =
        picked.map((VerseCandidate c) => c.verse).toList(growable: false);
    await _markShown(conversationId, finalVerses.map((Verse v) => v.id).toList());

    return SelectionResult(
      verses: finalVerses,
      matchedTags: tags,
      usedFallback: false,
    );
  }

  Future<void> _markShown(int conversationId, List<int> verseIds) async {
    if (verseIds.isEmpty) return;
    await contextDao.addShownVerses(conversationId, verseIds);
  }
}
