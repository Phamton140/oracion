// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VersesTable extends Verses with TableInfo<$VersesTable, Verse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
    'book',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNumberMeta = const VerificationMeta(
    'bookNumber',
  );
  @override
  late final GeneratedColumn<int> bookNumber = GeneratedColumn<int>(
    'book_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('RV1909'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    book,
    bookNumber,
    chapter,
    verse,
    body,
    translation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Verse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book')) {
      context.handle(
        _bookMeta,
        book.isAcceptableOrUnknown(data['book']!, _bookMeta),
      );
    } else if (isInserting) {
      context.missing(_bookMeta);
    }
    if (data.containsKey('book_number')) {
      context.handle(
        _bookNumberMeta,
        bookNumber.isAcceptableOrUnknown(data['book_number']!, _bookNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNumberMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      book: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book'],
      )!,
      bookNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_number'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }
}

class Verse extends DataClass implements Insertable<Verse> {
  final int id;
  final String book;
  final int bookNumber;
  final int chapter;
  final int verse;
  final String body;
  final String translation;
  const Verse({
    required this.id,
    required this.book,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.body,
    required this.translation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book'] = Variable<String>(book);
    map['book_number'] = Variable<int>(bookNumber);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['body'] = Variable<String>(body);
    map['translation'] = Variable<String>(translation);
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      id: Value(id),
      book: Value(book),
      bookNumber: Value(bookNumber),
      chapter: Value(chapter),
      verse: Value(verse),
      body: Value(body),
      translation: Value(translation),
    );
  }

  factory Verse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verse(
      id: serializer.fromJson<int>(json['id']),
      book: serializer.fromJson<String>(json['book']),
      bookNumber: serializer.fromJson<int>(json['bookNumber']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      body: serializer.fromJson<String>(json['body']),
      translation: serializer.fromJson<String>(json['translation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'book': serializer.toJson<String>(book),
      'bookNumber': serializer.toJson<int>(bookNumber),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'body': serializer.toJson<String>(body),
      'translation': serializer.toJson<String>(translation),
    };
  }

  Verse copyWith({
    int? id,
    String? book,
    int? bookNumber,
    int? chapter,
    int? verse,
    String? body,
    String? translation,
  }) => Verse(
    id: id ?? this.id,
    book: book ?? this.book,
    bookNumber: bookNumber ?? this.bookNumber,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    body: body ?? this.body,
    translation: translation ?? this.translation,
  );
  Verse copyWithCompanion(VersesCompanion data) {
    return Verse(
      id: data.id.present ? data.id.value : this.id,
      book: data.book.present ? data.book.value : this.book,
      bookNumber: data.bookNumber.present
          ? data.bookNumber.value
          : this.bookNumber,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      body: data.body.present ? data.body.value : this.body,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verse(')
          ..write('id: $id, ')
          ..write('book: $book, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('body: $body, ')
          ..write('translation: $translation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, book, bookNumber, chapter, verse, body, translation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verse &&
          other.id == this.id &&
          other.book == this.book &&
          other.bookNumber == this.bookNumber &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.body == this.body &&
          other.translation == this.translation);
}

class VersesCompanion extends UpdateCompanion<Verse> {
  final Value<int> id;
  final Value<String> book;
  final Value<int> bookNumber;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> body;
  final Value<String> translation;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.book = const Value.absent(),
    this.bookNumber = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.body = const Value.absent(),
    this.translation = const Value.absent(),
  });
  VersesCompanion.insert({
    this.id = const Value.absent(),
    required String book,
    required int bookNumber,
    required int chapter,
    required int verse,
    required String body,
    this.translation = const Value.absent(),
  }) : book = Value(book),
       bookNumber = Value(bookNumber),
       chapter = Value(chapter),
       verse = Value(verse),
       body = Value(body);
  static Insertable<Verse> custom({
    Expression<int>? id,
    Expression<String>? book,
    Expression<int>? bookNumber,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? body,
    Expression<String>? translation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (book != null) 'book': book,
      if (bookNumber != null) 'book_number': bookNumber,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (body != null) 'body': body,
      if (translation != null) 'translation': translation,
    });
  }

  VersesCompanion copyWith({
    Value<int>? id,
    Value<String>? book,
    Value<int>? bookNumber,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? body,
    Value<String>? translation,
  }) {
    return VersesCompanion(
      id: id ?? this.id,
      book: book ?? this.book,
      bookNumber: bookNumber ?? this.bookNumber,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      body: body ?? this.body,
      translation: translation ?? this.translation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (book.present) {
      map['book'] = Variable<String>(book.value);
    }
    if (bookNumber.present) {
      map['book_number'] = Variable<int>(bookNumber.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('book: $book, ')
          ..write('bookNumber: $bookNumber, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('body: $body, ')
          ..write('translation: $translation')
          ..write(')'))
        .toString();
  }
}

class $VerseTagsTable extends VerseTags
    with TableInfo<$VerseTagsTable, VerseTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES verses (id)',
    ),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant<double>(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, verseId, tag, weight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VerseTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
    );
  }

  @override
  $VerseTagsTable createAlias(String alias) {
    return $VerseTagsTable(attachedDatabase, alias);
  }
}

class VerseTag extends DataClass implements Insertable<VerseTag> {
  final int id;
  final int verseId;
  final String tag;
  final double weight;
  const VerseTag({
    required this.id,
    required this.verseId,
    required this.tag,
    required this.weight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['verse_id'] = Variable<int>(verseId);
    map['tag'] = Variable<String>(tag);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  VerseTagsCompanion toCompanion(bool nullToAbsent) {
    return VerseTagsCompanion(
      id: Value(id),
      verseId: Value(verseId),
      tag: Value(tag),
      weight: Value(weight),
    );
  }

  factory VerseTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseTag(
      id: serializer.fromJson<int>(json['id']),
      verseId: serializer.fromJson<int>(json['verseId']),
      tag: serializer.fromJson<String>(json['tag']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'verseId': serializer.toJson<int>(verseId),
      'tag': serializer.toJson<String>(tag),
      'weight': serializer.toJson<double>(weight),
    };
  }

  VerseTag copyWith({int? id, int? verseId, String? tag, double? weight}) =>
      VerseTag(
        id: id ?? this.id,
        verseId: verseId ?? this.verseId,
        tag: tag ?? this.tag,
        weight: weight ?? this.weight,
      );
  VerseTag copyWithCompanion(VerseTagsCompanion data) {
    return VerseTag(
      id: data.id.present ? data.id.value : this.id,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      tag: data.tag.present ? data.tag.value : this.tag,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseTag(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('tag: $tag, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verseId, tag, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseTag &&
          other.id == this.id &&
          other.verseId == this.verseId &&
          other.tag == this.tag &&
          other.weight == this.weight);
}

class VerseTagsCompanion extends UpdateCompanion<VerseTag> {
  final Value<int> id;
  final Value<int> verseId;
  final Value<String> tag;
  final Value<double> weight;
  const VerseTagsCompanion({
    this.id = const Value.absent(),
    this.verseId = const Value.absent(),
    this.tag = const Value.absent(),
    this.weight = const Value.absent(),
  });
  VerseTagsCompanion.insert({
    this.id = const Value.absent(),
    required int verseId,
    required String tag,
    this.weight = const Value.absent(),
  }) : verseId = Value(verseId),
       tag = Value(tag);
  static Insertable<VerseTag> custom({
    Expression<int>? id,
    Expression<int>? verseId,
    Expression<String>? tag,
    Expression<double>? weight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verseId != null) 'verse_id': verseId,
      if (tag != null) 'tag': tag,
      if (weight != null) 'weight': weight,
    });
  }

  VerseTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? verseId,
    Value<String>? tag,
    Value<double>? weight,
  }) {
    return VerseTagsCompanion(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      tag: tag ?? this.tag,
      weight: weight ?? this.weight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseTagsCompanion(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('tag: $tag, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? title;
  const Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String?>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String?>(title),
    };
  }

  Conversation copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> title = const Value.absent(),
  }) => Conversation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title.present ? title.value : this.title,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> title;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.title = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? title,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES verses (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    verseId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int conversationId;
  final String role;
  final String content;
  final int? verseId;
  final DateTime createdAt;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.verseId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || verseId != null) {
      map['verse_id'] = Variable<int>(verseId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      verseId: verseId == null && nullToAbsent
          ? const Value.absent()
          : Value(verseId),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      verseId: serializer.fromJson<int?>(json['verseId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'verseId': serializer.toJson<int?>(verseId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    Value<int?> verseId = const Value.absent(),
    DateTime? createdAt,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    verseId: verseId.present ? verseId.value : this.verseId,
    createdAt: createdAt ?? this.createdAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, verseId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.verseId == this.verseId &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<int?> verseId;
  final Value<DateTime> createdAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.verseId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String role,
    required String content,
    this.verseId = const Value.absent(),
    required DateTime createdAt,
  }) : conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<int>? verseId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (verseId != null) 'verse_id': verseId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<int?>? verseId,
    Value<DateTime>? createdAt,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      verseId: verseId ?? this.verseId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationContextsTable extends ConversationContexts
    with TableInfo<$ConversationContextsTable, ConversationContextEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id)',
    ),
  );
  static const VerificationMeta _dominantEmotionMeta = const VerificationMeta(
    'dominantEmotion',
  );
  @override
  late final GeneratedColumn<String> dominantEmotion = GeneratedColumn<String>(
    'dominant_emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dominantIntentMeta = const VerificationMeta(
    'dominantIntent',
  );
  @override
  late final GeneratedColumn<String> dominantIntent = GeneratedColumn<String>(
    'dominant_intent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicTagsJsonMeta = const VerificationMeta(
    'topicTagsJson',
  );
  @override
  late final GeneratedColumn<String> topicTagsJson = GeneratedColumn<String>(
    'topic_tags_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shownVerseIdsJsonMeta = const VerificationMeta(
    'shownVerseIdsJson',
  );
  @override
  late final GeneratedColumn<String> shownVerseIdsJson =
      GeneratedColumn<String>(
        'shown_verse_ids_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _centroidMeta = const VerificationMeta(
    'centroid',
  );
  @override
  late final GeneratedColumn<Uint8List> centroid = GeneratedColumn<Uint8List>(
    'centroid',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _turnCountMeta = const VerificationMeta(
    'turnCount',
  );
  @override
  late final GeneratedColumn<int> turnCount = GeneratedColumn<int>(
    'turn_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    dominantEmotion,
    dominantIntent,
    topicTagsJson,
    shownVerseIdsJson,
    centroid,
    turnCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationContextEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('dominant_emotion')) {
      context.handle(
        _dominantEmotionMeta,
        dominantEmotion.isAcceptableOrUnknown(
          data['dominant_emotion']!,
          _dominantEmotionMeta,
        ),
      );
    }
    if (data.containsKey('dominant_intent')) {
      context.handle(
        _dominantIntentMeta,
        dominantIntent.isAcceptableOrUnknown(
          data['dominant_intent']!,
          _dominantIntentMeta,
        ),
      );
    }
    if (data.containsKey('topic_tags_json')) {
      context.handle(
        _topicTagsJsonMeta,
        topicTagsJson.isAcceptableOrUnknown(
          data['topic_tags_json']!,
          _topicTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('shown_verse_ids_json')) {
      context.handle(
        _shownVerseIdsJsonMeta,
        shownVerseIdsJson.isAcceptableOrUnknown(
          data['shown_verse_ids_json']!,
          _shownVerseIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('centroid')) {
      context.handle(
        _centroidMeta,
        centroid.isAcceptableOrUnknown(data['centroid']!, _centroidMeta),
      );
    }
    if (data.containsKey('turn_count')) {
      context.handle(
        _turnCountMeta,
        turnCount.isAcceptableOrUnknown(data['turn_count']!, _turnCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  ConversationContextEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationContextEntry(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      dominantEmotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dominant_emotion'],
      ),
      dominantIntent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dominant_intent'],
      ),
      topicTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_tags_json'],
      ),
      shownVerseIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shown_verse_ids_json'],
      ),
      centroid: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}centroid'],
      ),
      turnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_count'],
      )!,
    );
  }

  @override
  $ConversationContextsTable createAlias(String alias) {
    return $ConversationContextsTable(attachedDatabase, alias);
  }
}

class ConversationContextEntry extends DataClass
    implements Insertable<ConversationContextEntry> {
  final int conversationId;
  final String? dominantEmotion;
  final String? dominantIntent;
  final String? topicTagsJson;
  final String? shownVerseIdsJson;
  final Uint8List? centroid;
  final int turnCount;
  const ConversationContextEntry({
    required this.conversationId,
    this.dominantEmotion,
    this.dominantIntent,
    this.topicTagsJson,
    this.shownVerseIdsJson,
    this.centroid,
    required this.turnCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<int>(conversationId);
    if (!nullToAbsent || dominantEmotion != null) {
      map['dominant_emotion'] = Variable<String>(dominantEmotion);
    }
    if (!nullToAbsent || dominantIntent != null) {
      map['dominant_intent'] = Variable<String>(dominantIntent);
    }
    if (!nullToAbsent || topicTagsJson != null) {
      map['topic_tags_json'] = Variable<String>(topicTagsJson);
    }
    if (!nullToAbsent || shownVerseIdsJson != null) {
      map['shown_verse_ids_json'] = Variable<String>(shownVerseIdsJson);
    }
    if (!nullToAbsent || centroid != null) {
      map['centroid'] = Variable<Uint8List>(centroid);
    }
    map['turn_count'] = Variable<int>(turnCount);
    return map;
  }

  ConversationContextsCompanion toCompanion(bool nullToAbsent) {
    return ConversationContextsCompanion(
      conversationId: Value(conversationId),
      dominantEmotion: dominantEmotion == null && nullToAbsent
          ? const Value.absent()
          : Value(dominantEmotion),
      dominantIntent: dominantIntent == null && nullToAbsent
          ? const Value.absent()
          : Value(dominantIntent),
      topicTagsJson: topicTagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(topicTagsJson),
      shownVerseIdsJson: shownVerseIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(shownVerseIdsJson),
      centroid: centroid == null && nullToAbsent
          ? const Value.absent()
          : Value(centroid),
      turnCount: Value(turnCount),
    );
  }

  factory ConversationContextEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationContextEntry(
      conversationId: serializer.fromJson<int>(json['conversationId']),
      dominantEmotion: serializer.fromJson<String?>(json['dominantEmotion']),
      dominantIntent: serializer.fromJson<String?>(json['dominantIntent']),
      topicTagsJson: serializer.fromJson<String?>(json['topicTagsJson']),
      shownVerseIdsJson: serializer.fromJson<String?>(
        json['shownVerseIdsJson'],
      ),
      centroid: serializer.fromJson<Uint8List?>(json['centroid']),
      turnCount: serializer.fromJson<int>(json['turnCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<int>(conversationId),
      'dominantEmotion': serializer.toJson<String?>(dominantEmotion),
      'dominantIntent': serializer.toJson<String?>(dominantIntent),
      'topicTagsJson': serializer.toJson<String?>(topicTagsJson),
      'shownVerseIdsJson': serializer.toJson<String?>(shownVerseIdsJson),
      'centroid': serializer.toJson<Uint8List?>(centroid),
      'turnCount': serializer.toJson<int>(turnCount),
    };
  }

  ConversationContextEntry copyWith({
    int? conversationId,
    Value<String?> dominantEmotion = const Value.absent(),
    Value<String?> dominantIntent = const Value.absent(),
    Value<String?> topicTagsJson = const Value.absent(),
    Value<String?> shownVerseIdsJson = const Value.absent(),
    Value<Uint8List?> centroid = const Value.absent(),
    int? turnCount,
  }) => ConversationContextEntry(
    conversationId: conversationId ?? this.conversationId,
    dominantEmotion: dominantEmotion.present
        ? dominantEmotion.value
        : this.dominantEmotion,
    dominantIntent: dominantIntent.present
        ? dominantIntent.value
        : this.dominantIntent,
    topicTagsJson: topicTagsJson.present
        ? topicTagsJson.value
        : this.topicTagsJson,
    shownVerseIdsJson: shownVerseIdsJson.present
        ? shownVerseIdsJson.value
        : this.shownVerseIdsJson,
    centroid: centroid.present ? centroid.value : this.centroid,
    turnCount: turnCount ?? this.turnCount,
  );
  ConversationContextEntry copyWithCompanion(
    ConversationContextsCompanion data,
  ) {
    return ConversationContextEntry(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      dominantEmotion: data.dominantEmotion.present
          ? data.dominantEmotion.value
          : this.dominantEmotion,
      dominantIntent: data.dominantIntent.present
          ? data.dominantIntent.value
          : this.dominantIntent,
      topicTagsJson: data.topicTagsJson.present
          ? data.topicTagsJson.value
          : this.topicTagsJson,
      shownVerseIdsJson: data.shownVerseIdsJson.present
          ? data.shownVerseIdsJson.value
          : this.shownVerseIdsJson,
      centroid: data.centroid.present ? data.centroid.value : this.centroid,
      turnCount: data.turnCount.present ? data.turnCount.value : this.turnCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationContextEntry(')
          ..write('conversationId: $conversationId, ')
          ..write('dominantEmotion: $dominantEmotion, ')
          ..write('dominantIntent: $dominantIntent, ')
          ..write('topicTagsJson: $topicTagsJson, ')
          ..write('shownVerseIdsJson: $shownVerseIdsJson, ')
          ..write('centroid: $centroid, ')
          ..write('turnCount: $turnCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    dominantEmotion,
    dominantIntent,
    topicTagsJson,
    shownVerseIdsJson,
    $driftBlobEquality.hash(centroid),
    turnCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationContextEntry &&
          other.conversationId == this.conversationId &&
          other.dominantEmotion == this.dominantEmotion &&
          other.dominantIntent == this.dominantIntent &&
          other.topicTagsJson == this.topicTagsJson &&
          other.shownVerseIdsJson == this.shownVerseIdsJson &&
          $driftBlobEquality.equals(other.centroid, this.centroid) &&
          other.turnCount == this.turnCount);
}

class ConversationContextsCompanion
    extends UpdateCompanion<ConversationContextEntry> {
  final Value<int> conversationId;
  final Value<String?> dominantEmotion;
  final Value<String?> dominantIntent;
  final Value<String?> topicTagsJson;
  final Value<String?> shownVerseIdsJson;
  final Value<Uint8List?> centroid;
  final Value<int> turnCount;
  const ConversationContextsCompanion({
    this.conversationId = const Value.absent(),
    this.dominantEmotion = const Value.absent(),
    this.dominantIntent = const Value.absent(),
    this.topicTagsJson = const Value.absent(),
    this.shownVerseIdsJson = const Value.absent(),
    this.centroid = const Value.absent(),
    this.turnCount = const Value.absent(),
  });
  ConversationContextsCompanion.insert({
    this.conversationId = const Value.absent(),
    this.dominantEmotion = const Value.absent(),
    this.dominantIntent = const Value.absent(),
    this.topicTagsJson = const Value.absent(),
    this.shownVerseIdsJson = const Value.absent(),
    this.centroid = const Value.absent(),
    this.turnCount = const Value.absent(),
  });
  static Insertable<ConversationContextEntry> custom({
    Expression<int>? conversationId,
    Expression<String>? dominantEmotion,
    Expression<String>? dominantIntent,
    Expression<String>? topicTagsJson,
    Expression<String>? shownVerseIdsJson,
    Expression<Uint8List>? centroid,
    Expression<int>? turnCount,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (dominantEmotion != null) 'dominant_emotion': dominantEmotion,
      if (dominantIntent != null) 'dominant_intent': dominantIntent,
      if (topicTagsJson != null) 'topic_tags_json': topicTagsJson,
      if (shownVerseIdsJson != null) 'shown_verse_ids_json': shownVerseIdsJson,
      if (centroid != null) 'centroid': centroid,
      if (turnCount != null) 'turn_count': turnCount,
    });
  }

  ConversationContextsCompanion copyWith({
    Value<int>? conversationId,
    Value<String?>? dominantEmotion,
    Value<String?>? dominantIntent,
    Value<String?>? topicTagsJson,
    Value<String?>? shownVerseIdsJson,
    Value<Uint8List?>? centroid,
    Value<int>? turnCount,
  }) {
    return ConversationContextsCompanion(
      conversationId: conversationId ?? this.conversationId,
      dominantEmotion: dominantEmotion ?? this.dominantEmotion,
      dominantIntent: dominantIntent ?? this.dominantIntent,
      topicTagsJson: topicTagsJson ?? this.topicTagsJson,
      shownVerseIdsJson: shownVerseIdsJson ?? this.shownVerseIdsJson,
      centroid: centroid ?? this.centroid,
      turnCount: turnCount ?? this.turnCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (dominantEmotion.present) {
      map['dominant_emotion'] = Variable<String>(dominantEmotion.value);
    }
    if (dominantIntent.present) {
      map['dominant_intent'] = Variable<String>(dominantIntent.value);
    }
    if (topicTagsJson.present) {
      map['topic_tags_json'] = Variable<String>(topicTagsJson.value);
    }
    if (shownVerseIdsJson.present) {
      map['shown_verse_ids_json'] = Variable<String>(shownVerseIdsJson.value);
    }
    if (centroid.present) {
      map['centroid'] = Variable<Uint8List>(centroid.value);
    }
    if (turnCount.present) {
      map['turn_count'] = Variable<int>(turnCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationContextsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('dominantEmotion: $dominantEmotion, ')
          ..write('dominantIntent: $dominantIntent, ')
          ..write('topicTagsJson: $topicTagsJson, ')
          ..write('shownVerseIdsJson: $shownVerseIdsJson, ')
          ..write('centroid: $centroid, ')
          ..write('turnCount: $turnCount')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _verseIdMeta = const VerificationMeta(
    'verseId',
  );
  @override
  late final GeneratedColumn<int> verseId = GeneratedColumn<int>(
    'verse_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES verses (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, verseId, createdAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('verse_id')) {
      context.handle(
        _verseIdMeta,
        verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      verseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final int id;
  final int verseId;
  final DateTime createdAt;
  final String? note;
  const Favorite({
    required this.id,
    required this.verseId,
    required this.createdAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['verse_id'] = Variable<int>(verseId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      id: Value(id),
      verseId: Value(verseId),
      createdAt: Value(createdAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      id: serializer.fromJson<int>(json['id']),
      verseId: serializer.fromJson<int>(json['verseId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'verseId': serializer.toJson<int>(verseId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  Favorite copyWith({
    int? id,
    int? verseId,
    DateTime? createdAt,
    Value<String?> note = const Value.absent(),
  }) => Favorite(
    id: id ?? this.id,
    verseId: verseId ?? this.verseId,
    createdAt: createdAt ?? this.createdAt,
    note: note.present ? note.value : this.note,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      id: data.id.present ? data.id.value : this.id,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verseId, createdAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.id == this.id &&
          other.verseId == this.verseId &&
          other.createdAt == this.createdAt &&
          other.note == this.note);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<int> id;
  final Value<int> verseId;
  final Value<DateTime> createdAt;
  final Value<String?> note;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.verseId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.id = const Value.absent(),
    required int verseId,
    required DateTime createdAt,
    this.note = const Value.absent(),
  }) : verseId = Value(verseId),
       createdAt = Value(createdAt);
  static Insertable<Favorite> custom({
    Expression<int>? id,
    Expression<int>? verseId,
    Expression<DateTime>? createdAt,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verseId != null) 'verse_id': verseId,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
    });
  }

  FavoritesCompanion copyWith({
    Value<int>? id,
    Value<int>? verseId,
    Value<DateTime>? createdAt,
    Value<String?>? note,
  }) {
    return FavoritesCompanion(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<int>(verseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageStatsTable extends UsageStats
    with TableInfo<$UsageStatsTable, UsageStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationsCreatedMeta =
      const VerificationMeta('conversationsCreated');
  @override
  late final GeneratedColumn<int> conversationsCreated = GeneratedColumn<int>(
    'conversations_created',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _searchesPerformedMeta = const VerificationMeta(
    'searchesPerformed',
  );
  @override
  late final GeneratedColumn<int> searchesPerformed = GeneratedColumn<int>(
    'searches_performed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _favoritesSavedMeta = const VerificationMeta(
    'favoritesSaved',
  );
  @override
  late final GeneratedColumn<int> favoritesSaved = GeneratedColumn<int>(
    'favorites_saved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _versesSharedMeta = const VerificationMeta(
    'versesShared',
  );
  @override
  late final GeneratedColumn<int> versesShared = GeneratedColumn<int>(
    'verses_shared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationsCreated,
    searchesPerformed,
    favoritesSaved,
    versesShared,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversations_created')) {
      context.handle(
        _conversationsCreatedMeta,
        conversationsCreated.isAcceptableOrUnknown(
          data['conversations_created']!,
          _conversationsCreatedMeta,
        ),
      );
    }
    if (data.containsKey('searches_performed')) {
      context.handle(
        _searchesPerformedMeta,
        searchesPerformed.isAcceptableOrUnknown(
          data['searches_performed']!,
          _searchesPerformedMeta,
        ),
      );
    }
    if (data.containsKey('favorites_saved')) {
      context.handle(
        _favoritesSavedMeta,
        favoritesSaved.isAcceptableOrUnknown(
          data['favorites_saved']!,
          _favoritesSavedMeta,
        ),
      );
    }
    if (data.containsKey('verses_shared')) {
      context.handle(
        _versesSharedMeta,
        versesShared.isAcceptableOrUnknown(
          data['verses_shared']!,
          _versesSharedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationsCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversations_created'],
      )!,
      searchesPerformed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}searches_performed'],
      )!,
      favoritesSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}favorites_saved'],
      )!,
      versesShared: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verses_shared'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsageStatsTable createAlias(String alias) {
    return $UsageStatsTable(attachedDatabase, alias);
  }
}

class UsageStat extends DataClass implements Insertable<UsageStat> {
  final int id;
  final int conversationsCreated;
  final int searchesPerformed;
  final int favoritesSaved;
  final int versesShared;
  final DateTime updatedAt;
  const UsageStat({
    required this.id,
    required this.conversationsCreated,
    required this.searchesPerformed,
    required this.favoritesSaved,
    required this.versesShared,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversations_created'] = Variable<int>(conversationsCreated);
    map['searches_performed'] = Variable<int>(searchesPerformed);
    map['favorites_saved'] = Variable<int>(favoritesSaved);
    map['verses_shared'] = Variable<int>(versesShared);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsageStatsCompanion toCompanion(bool nullToAbsent) {
    return UsageStatsCompanion(
      id: Value(id),
      conversationsCreated: Value(conversationsCreated),
      searchesPerformed: Value(searchesPerformed),
      favoritesSaved: Value(favoritesSaved),
      versesShared: Value(versesShared),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsageStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageStat(
      id: serializer.fromJson<int>(json['id']),
      conversationsCreated: serializer.fromJson<int>(
        json['conversationsCreated'],
      ),
      searchesPerformed: serializer.fromJson<int>(json['searchesPerformed']),
      favoritesSaved: serializer.fromJson<int>(json['favoritesSaved']),
      versesShared: serializer.fromJson<int>(json['versesShared']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationsCreated': serializer.toJson<int>(conversationsCreated),
      'searchesPerformed': serializer.toJson<int>(searchesPerformed),
      'favoritesSaved': serializer.toJson<int>(favoritesSaved),
      'versesShared': serializer.toJson<int>(versesShared),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsageStat copyWith({
    int? id,
    int? conversationsCreated,
    int? searchesPerformed,
    int? favoritesSaved,
    int? versesShared,
    DateTime? updatedAt,
  }) => UsageStat(
    id: id ?? this.id,
    conversationsCreated: conversationsCreated ?? this.conversationsCreated,
    searchesPerformed: searchesPerformed ?? this.searchesPerformed,
    favoritesSaved: favoritesSaved ?? this.favoritesSaved,
    versesShared: versesShared ?? this.versesShared,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsageStat copyWithCompanion(UsageStatsCompanion data) {
    return UsageStat(
      id: data.id.present ? data.id.value : this.id,
      conversationsCreated: data.conversationsCreated.present
          ? data.conversationsCreated.value
          : this.conversationsCreated,
      searchesPerformed: data.searchesPerformed.present
          ? data.searchesPerformed.value
          : this.searchesPerformed,
      favoritesSaved: data.favoritesSaved.present
          ? data.favoritesSaved.value
          : this.favoritesSaved,
      versesShared: data.versesShared.present
          ? data.versesShared.value
          : this.versesShared,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageStat(')
          ..write('id: $id, ')
          ..write('conversationsCreated: $conversationsCreated, ')
          ..write('searchesPerformed: $searchesPerformed, ')
          ..write('favoritesSaved: $favoritesSaved, ')
          ..write('versesShared: $versesShared, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationsCreated,
    searchesPerformed,
    favoritesSaved,
    versesShared,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageStat &&
          other.id == this.id &&
          other.conversationsCreated == this.conversationsCreated &&
          other.searchesPerformed == this.searchesPerformed &&
          other.favoritesSaved == this.favoritesSaved &&
          other.versesShared == this.versesShared &&
          other.updatedAt == this.updatedAt);
}

class UsageStatsCompanion extends UpdateCompanion<UsageStat> {
  final Value<int> id;
  final Value<int> conversationsCreated;
  final Value<int> searchesPerformed;
  final Value<int> favoritesSaved;
  final Value<int> versesShared;
  final Value<DateTime> updatedAt;
  const UsageStatsCompanion({
    this.id = const Value.absent(),
    this.conversationsCreated = const Value.absent(),
    this.searchesPerformed = const Value.absent(),
    this.favoritesSaved = const Value.absent(),
    this.versesShared = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsageStatsCompanion.insert({
    this.id = const Value.absent(),
    this.conversationsCreated = const Value.absent(),
    this.searchesPerformed = const Value.absent(),
    this.favoritesSaved = const Value.absent(),
    this.versesShared = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<UsageStat> custom({
    Expression<int>? id,
    Expression<int>? conversationsCreated,
    Expression<int>? searchesPerformed,
    Expression<int>? favoritesSaved,
    Expression<int>? versesShared,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationsCreated != null)
        'conversations_created': conversationsCreated,
      if (searchesPerformed != null) 'searches_performed': searchesPerformed,
      if (favoritesSaved != null) 'favorites_saved': favoritesSaved,
      if (versesShared != null) 'verses_shared': versesShared,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsageStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationsCreated,
    Value<int>? searchesPerformed,
    Value<int>? favoritesSaved,
    Value<int>? versesShared,
    Value<DateTime>? updatedAt,
  }) {
    return UsageStatsCompanion(
      id: id ?? this.id,
      conversationsCreated: conversationsCreated ?? this.conversationsCreated,
      searchesPerformed: searchesPerformed ?? this.searchesPerformed,
      favoritesSaved: favoritesSaved ?? this.favoritesSaved,
      versesShared: versesShared ?? this.versesShared,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationsCreated.present) {
      map['conversations_created'] = Variable<int>(conversationsCreated.value);
    }
    if (searchesPerformed.present) {
      map['searches_performed'] = Variable<int>(searchesPerformed.value);
    }
    if (favoritesSaved.present) {
      map['favorites_saved'] = Variable<int>(favoritesSaved.value);
    }
    if (versesShared.present) {
      map['verses_shared'] = Variable<int>(versesShared.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageStatsCompanion(')
          ..write('id: $id, ')
          ..write('conversationsCreated: $conversationsCreated, ')
          ..write('searchesPerformed: $searchesPerformed, ')
          ..write('favoritesSaved: $favoritesSaved, ')
          ..write('versesShared: $versesShared, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersesTable verses = $VersesTable(this);
  late final $VerseTagsTable verseTags = $VerseTagsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationContextsTable conversationContexts =
      $ConversationContextsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $UsageStatsTable usageStats = $UsageStatsTable(this);
  late final VersesDao versesDao = VersesDao(this as AppDatabase);
  late final ConversationsDao conversationsDao = ConversationsDao(
    this as AppDatabase,
  );
  late final MessagesDao messagesDao = MessagesDao(this as AppDatabase);
  late final ContextDao contextDao = ContextDao(this as AppDatabase);
  late final FavoritesDao favoritesDao = FavoritesDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final UsageStatsDao usageStatsDao = UsageStatsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    verses,
    verseTags,
    conversations,
    messages,
    conversationContexts,
    favorites,
    settings,
    usageStats,
  ];
}

typedef $$VersesTableCreateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      required String book,
      required int bookNumber,
      required int chapter,
      required int verse,
      required String body,
      Value<String> translation,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      Value<String> book,
      Value<int> bookNumber,
      Value<int> chapter,
      Value<int> verse,
      Value<String> body,
      Value<String> translation,
    });

final class $$VersesTableReferences
    extends BaseReferences<_$AppDatabase, $VersesTable, Verse> {
  $$VersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VerseTagsTable, List<VerseTag>>
  _verseTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.verseTags,
    aliasName: $_aliasNameGenerator(db.verses.id, db.verseTags.verseId),
  );

  $$VerseTagsTableProcessedTableManager get verseTagsRefs {
    final manager = $$VerseTagsTableTableManager(
      $_db,
      $_db.verseTags,
    ).filter((f) => f.verseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_verseTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.verses.id, db.messages.verseId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.verseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FavoritesTable, List<Favorite>>
  _favoritesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.favorites,
    aliasName: $_aliasNameGenerator(db.verses.id, db.favorites.verseId),
  );

  $$FavoritesTableProcessedTableManager get favoritesRefs {
    final manager = $$FavoritesTableTableManager(
      $_db,
      $_db.favorites,
    ).filter((f) => f.verseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoritesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> verseTagsRefs(
    Expression<bool> Function($$VerseTagsTableFilterComposer f) f,
  ) {
    final $$VerseTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verseTags,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerseTagsTableFilterComposer(
            $db: $db,
            $table: $db.verseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> favoritesRefs(
    Expression<bool> Function($$FavoritesTableFilterComposer f) f,
  ) {
    final $$FavoritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableFilterComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get book =>
      $composableBuilder(column: $table.book, builder: (column) => column);

  GeneratedColumn<int> get bookNumber => $composableBuilder(
    column: $table.bookNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  Expression<T> verseTagsRefs<T extends Object>(
    Expression<T> Function($$VerseTagsTableAnnotationComposer a) f,
  ) {
    final $$VerseTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verseTags,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerseTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.verseTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> favoritesRefs<T extends Object>(
    Expression<T> Function($$FavoritesTableAnnotationComposer a) f,
  ) {
    final $$FavoritesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.verseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableAnnotationComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersesTable,
          Verse,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (Verse, $$VersesTableReferences),
          Verse,
          PrefetchHooks Function({
            bool verseTagsRefs,
            bool messagesRefs,
            bool favoritesRefs,
          })
        > {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> book = const Value.absent(),
                Value<int> bookNumber = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> translation = const Value.absent(),
              }) => VersesCompanion(
                id: id,
                book: book,
                bookNumber: bookNumber,
                chapter: chapter,
                verse: verse,
                body: body,
                translation: translation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String book,
                required int bookNumber,
                required int chapter,
                required int verse,
                required String body,
                Value<String> translation = const Value.absent(),
              }) => VersesCompanion.insert(
                id: id,
                book: book,
                bookNumber: bookNumber,
                chapter: chapter,
                verse: verse,
                body: body,
                translation: translation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VersesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                verseTagsRefs = false,
                messagesRefs = false,
                favoritesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (verseTagsRefs) db.verseTags,
                    if (messagesRefs) db.messages,
                    if (favoritesRefs) db.favorites,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (verseTagsRefs)
                        await $_getPrefetchedData<
                          Verse,
                          $VersesTable,
                          VerseTag
                        >(
                          currentTable: table,
                          referencedTable: $$VersesTableReferences
                              ._verseTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VersesTableReferences(
                                db,
                                table,
                                p0,
                              ).verseTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.verseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<Verse, $VersesTable, Message>(
                          currentTable: table,
                          referencedTable: $$VersesTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VersesTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.verseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (favoritesRefs)
                        await $_getPrefetchedData<
                          Verse,
                          $VersesTable,
                          Favorite
                        >(
                          currentTable: table,
                          referencedTable: $$VersesTableReferences
                              ._favoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VersesTableReferences(
                                db,
                                table,
                                p0,
                              ).favoritesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.verseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersesTable,
      Verse,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (Verse, $$VersesTableReferences),
      Verse,
      PrefetchHooks Function({
        bool verseTagsRefs,
        bool messagesRefs,
        bool favoritesRefs,
      })
    >;
typedef $$VerseTagsTableCreateCompanionBuilder =
    VerseTagsCompanion Function({
      Value<int> id,
      required int verseId,
      required String tag,
      Value<double> weight,
    });
typedef $$VerseTagsTableUpdateCompanionBuilder =
    VerseTagsCompanion Function({
      Value<int> id,
      Value<int> verseId,
      Value<String> tag,
      Value<double> weight,
    });

final class $$VerseTagsTableReferences
    extends BaseReferences<_$AppDatabase, $VerseTagsTable, VerseTag> {
  $$VerseTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VersesTable _verseIdTable(_$AppDatabase db) => db.verses.createAlias(
    $_aliasNameGenerator(db.verseTags.verseId, db.verses.id),
  );

  $$VersesTableProcessedTableManager get verseId {
    final $_column = $_itemColumn<int>('verse_id')!;

    final manager = $$VersesTableTableManager(
      $_db,
      $_db.verses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_verseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VerseTagsTableFilterComposer
    extends Composer<_$AppDatabase, $VerseTagsTable> {
  $$VerseTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  $$VersesTableFilterComposer get verseId {
    final $$VersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableFilterComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseTagsTable> {
  $$VerseTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  $$VersesTableOrderingComposer get verseId {
    final $$VersesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableOrderingComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseTagsTable> {
  $$VerseTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  $$VersesTableAnnotationComposer get verseId {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableAnnotationComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseTagsTable,
          VerseTag,
          $$VerseTagsTableFilterComposer,
          $$VerseTagsTableOrderingComposer,
          $$VerseTagsTableAnnotationComposer,
          $$VerseTagsTableCreateCompanionBuilder,
          $$VerseTagsTableUpdateCompanionBuilder,
          (VerseTag, $$VerseTagsTableReferences),
          VerseTag,
          PrefetchHooks Function({bool verseId})
        > {
  $$VerseTagsTableTableManager(_$AppDatabase db, $VerseTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<double> weight = const Value.absent(),
              }) => VerseTagsCompanion(
                id: id,
                verseId: verseId,
                tag: tag,
                weight: weight,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int verseId,
                required String tag,
                Value<double> weight = const Value.absent(),
              }) => VerseTagsCompanion.insert(
                id: id,
                verseId: verseId,
                tag: tag,
                weight: weight,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VerseTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({verseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (verseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.verseId,
                                referencedTable: $$VerseTagsTableReferences
                                    ._verseIdTable(db),
                                referencedColumn: $$VerseTagsTableReferences
                                    ._verseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VerseTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseTagsTable,
      VerseTag,
      $$VerseTagsTableFilterComposer,
      $$VerseTagsTableOrderingComposer,
      $$VerseTagsTableAnnotationComposer,
      $$VerseTagsTableCreateCompanionBuilder,
      $$VerseTagsTableUpdateCompanionBuilder,
      (VerseTag, $$VerseTagsTableReferences),
      VerseTag,
      PrefetchHooks Function({bool verseId})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> title,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> title,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(
      db.conversations.id,
      db.messages.conversationId,
    ),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ConversationContextsTable,
    List<ConversationContextEntry>
  >
  _conversationContextsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.conversationContexts,
        aliasName: $_aliasNameGenerator(
          db.conversations.id,
          db.conversationContexts.conversationId,
        ),
      );

  $$ConversationContextsTableProcessedTableManager
  get conversationContextsRefs {
    final manager = $$ConversationContextsTableTableManager(
      $_db,
      $_db.conversationContexts,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _conversationContextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conversationContextsRefs(
    Expression<bool> Function($$ConversationContextsTableFilterComposer f) f,
  ) {
    final $$ConversationContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conversationContexts,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationContextsTableFilterComposer(
            $db: $db,
            $table: $db.conversationContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conversationContextsRefs<T extends Object>(
    Expression<T> Function($$ConversationContextsTableAnnotationComposer a) f,
  ) {
    final $$ConversationContextsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.conversationContexts,
          getReferencedColumn: (t) => t.conversationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConversationContextsTableAnnotationComposer(
                $db: $db,
                $table: $db.conversationContexts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({
            bool messagesRefs,
            bool conversationContextsRefs,
          })
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> title = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> title = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({messagesRefs = false, conversationContextsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (messagesRefs) db.messages,
                    if (conversationContextsRefs) db.conversationContexts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conversationContextsRefs)
                        await $_getPrefetchedData<
                          Conversation,
                          $ConversationsTable,
                          ConversationContextEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ConversationsTableReferences
                              ._conversationContextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConversationsTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationContextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.conversationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool messagesRefs, bool conversationContextsRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int conversationId,
      required String role,
      required String content,
      Value<int?> verseId,
      required DateTime createdAt,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<String> role,
      Value<String> content,
      Value<int?> verseId,
      Value<DateTime> createdAt,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(db.messages.conversationId, db.conversations.id),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<int>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VersesTable _verseIdTable(_$AppDatabase db) => db.verses.createAlias(
    $_aliasNameGenerator(db.messages.verseId, db.verses.id),
  );

  $$VersesTableProcessedTableManager? get verseId {
    final $_column = $_itemColumn<int>('verse_id');
    if ($_column == null) return null;
    final manager = $$VersesTableTableManager(
      $_db,
      $_db.verses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_verseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersesTableFilterComposer get verseId {
    final $$VersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableFilterComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersesTableOrderingComposer get verseId {
    final $$VersesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableOrderingComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VersesTableAnnotationComposer get verseId {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableAnnotationComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId, bool verseId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int?> verseId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                verseId: verseId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                required String role,
                required String content,
                Value<int?> verseId = const Value.absent(),
                required DateTime createdAt,
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                verseId: verseId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false, verseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$MessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._conversationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (verseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.verseId,
                                referencedTable: $$MessagesTableReferences
                                    ._verseIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._verseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId, bool verseId})
    >;
typedef $$ConversationContextsTableCreateCompanionBuilder =
    ConversationContextsCompanion Function({
      Value<int> conversationId,
      Value<String?> dominantEmotion,
      Value<String?> dominantIntent,
      Value<String?> topicTagsJson,
      Value<String?> shownVerseIdsJson,
      Value<Uint8List?> centroid,
      Value<int> turnCount,
    });
typedef $$ConversationContextsTableUpdateCompanionBuilder =
    ConversationContextsCompanion Function({
      Value<int> conversationId,
      Value<String?> dominantEmotion,
      Value<String?> dominantIntent,
      Value<String?> topicTagsJson,
      Value<String?> shownVerseIdsJson,
      Value<Uint8List?> centroid,
      Value<int> turnCount,
    });

final class $$ConversationContextsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConversationContextsTable,
          ConversationContextEntry
        > {
  $$ConversationContextsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(
          db.conversationContexts.conversationId,
          db.conversations.id,
        ),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<int>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConversationContextsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationContextsTable> {
  $$ConversationContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dominantEmotion => $composableBuilder(
    column: $table.dominantEmotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dominantIntent => $composableBuilder(
    column: $table.dominantIntent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicTagsJson => $composableBuilder(
    column: $table.topicTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shownVerseIdsJson => $composableBuilder(
    column: $table.shownVerseIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get centroid => $composableBuilder(
    column: $table.centroid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationContextsTable> {
  $$ConversationContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dominantEmotion => $composableBuilder(
    column: $table.dominantEmotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dominantIntent => $composableBuilder(
    column: $table.dominantIntent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicTagsJson => $composableBuilder(
    column: $table.topicTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shownVerseIdsJson => $composableBuilder(
    column: $table.shownVerseIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get centroid => $composableBuilder(
    column: $table.centroid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationContextsTable> {
  $$ConversationContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dominantEmotion => $composableBuilder(
    column: $table.dominantEmotion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dominantIntent => $composableBuilder(
    column: $table.dominantIntent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicTagsJson => $composableBuilder(
    column: $table.topicTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shownVerseIdsJson => $composableBuilder(
    column: $table.shownVerseIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get centroid =>
      $composableBuilder(column: $table.centroid, builder: (column) => column);

  GeneratedColumn<int> get turnCount =>
      $composableBuilder(column: $table.turnCount, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationContextsTable,
          ConversationContextEntry,
          $$ConversationContextsTableFilterComposer,
          $$ConversationContextsTableOrderingComposer,
          $$ConversationContextsTableAnnotationComposer,
          $$ConversationContextsTableCreateCompanionBuilder,
          $$ConversationContextsTableUpdateCompanionBuilder,
          (ConversationContextEntry, $$ConversationContextsTableReferences),
          ConversationContextEntry,
          PrefetchHooks Function({bool conversationId})
        > {
  $$ConversationContextsTableTableManager(
    _$AppDatabase db,
    $ConversationContextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationContextsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConversationContextsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<String?> dominantEmotion = const Value.absent(),
                Value<String?> dominantIntent = const Value.absent(),
                Value<String?> topicTagsJson = const Value.absent(),
                Value<String?> shownVerseIdsJson = const Value.absent(),
                Value<Uint8List?> centroid = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
              }) => ConversationContextsCompanion(
                conversationId: conversationId,
                dominantEmotion: dominantEmotion,
                dominantIntent: dominantIntent,
                topicTagsJson: topicTagsJson,
                shownVerseIdsJson: shownVerseIdsJson,
                centroid: centroid,
                turnCount: turnCount,
              ),
          createCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<String?> dominantEmotion = const Value.absent(),
                Value<String?> dominantIntent = const Value.absent(),
                Value<String?> topicTagsJson = const Value.absent(),
                Value<String?> shownVerseIdsJson = const Value.absent(),
                Value<Uint8List?> centroid = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
              }) => ConversationContextsCompanion.insert(
                conversationId: conversationId,
                dominantEmotion: dominantEmotion,
                dominantIntent: dominantIntent,
                topicTagsJson: topicTagsJson,
                shownVerseIdsJson: shownVerseIdsJson,
                centroid: centroid,
                turnCount: turnCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationContextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable:
                                    $$ConversationContextsTableReferences
                                        ._conversationIdTable(db),
                                referencedColumn:
                                    $$ConversationContextsTableReferences
                                        ._conversationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConversationContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationContextsTable,
      ConversationContextEntry,
      $$ConversationContextsTableFilterComposer,
      $$ConversationContextsTableOrderingComposer,
      $$ConversationContextsTableAnnotationComposer,
      $$ConversationContextsTableCreateCompanionBuilder,
      $$ConversationContextsTableUpdateCompanionBuilder,
      (ConversationContextEntry, $$ConversationContextsTableReferences),
      ConversationContextEntry,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> id,
      required int verseId,
      required DateTime createdAt,
      Value<String?> note,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<int> id,
      Value<int> verseId,
      Value<DateTime> createdAt,
      Value<String?> note,
    });

final class $$FavoritesTableReferences
    extends BaseReferences<_$AppDatabase, $FavoritesTable, Favorite> {
  $$FavoritesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VersesTable _verseIdTable(_$AppDatabase db) => db.verses.createAlias(
    $_aliasNameGenerator(db.favorites.verseId, db.verses.id),
  );

  $$VersesTableProcessedTableManager get verseId {
    final $_column = $_itemColumn<int>('verse_id')!;

    final manager = $$VersesTableTableManager(
      $_db,
      $_db.verses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_verseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$VersesTableFilterComposer get verseId {
    final $$VersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableFilterComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$VersesTableOrderingComposer get verseId {
    final $$VersesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableOrderingComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$VersesTableAnnotationComposer get verseId {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.verseId,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableAnnotationComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, $$FavoritesTableReferences),
          Favorite,
          PrefetchHooks Function({bool verseId})
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> verseId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FavoritesCompanion(
                id: id,
                verseId: verseId,
                createdAt: createdAt,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int verseId,
                required DateTime createdAt,
                Value<String?> note = const Value.absent(),
              }) => FavoritesCompanion.insert(
                id: id,
                verseId: verseId,
                createdAt: createdAt,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({verseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (verseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.verseId,
                                referencedTable: $$FavoritesTableReferences
                                    ._verseIdTable(db),
                                referencedColumn: $$FavoritesTableReferences
                                    ._verseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, $$FavoritesTableReferences),
      Favorite,
      PrefetchHooks Function({bool verseId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$UsageStatsTableCreateCompanionBuilder =
    UsageStatsCompanion Function({
      Value<int> id,
      Value<int> conversationsCreated,
      Value<int> searchesPerformed,
      Value<int> favoritesSaved,
      Value<int> versesShared,
      required DateTime updatedAt,
    });
typedef $$UsageStatsTableUpdateCompanionBuilder =
    UsageStatsCompanion Function({
      Value<int> id,
      Value<int> conversationsCreated,
      Value<int> searchesPerformed,
      Value<int> favoritesSaved,
      Value<int> versesShared,
      Value<DateTime> updatedAt,
    });

class $$UsageStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageStatsTable> {
  $$UsageStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationsCreated => $composableBuilder(
    column: $table.conversationsCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get searchesPerformed => $composableBuilder(
    column: $table.searchesPerformed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get favoritesSaved => $composableBuilder(
    column: $table.favoritesSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versesShared => $composableBuilder(
    column: $table.versesShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageStatsTable> {
  $$UsageStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationsCreated => $composableBuilder(
    column: $table.conversationsCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get searchesPerformed => $composableBuilder(
    column: $table.searchesPerformed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get favoritesSaved => $composableBuilder(
    column: $table.favoritesSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versesShared => $composableBuilder(
    column: $table.versesShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageStatsTable> {
  $$UsageStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationsCreated => $composableBuilder(
    column: $table.conversationsCreated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get searchesPerformed => $composableBuilder(
    column: $table.searchesPerformed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get favoritesSaved => $composableBuilder(
    column: $table.favoritesSaved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versesShared => $composableBuilder(
    column: $table.versesShared,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsageStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageStatsTable,
          UsageStat,
          $$UsageStatsTableFilterComposer,
          $$UsageStatsTableOrderingComposer,
          $$UsageStatsTableAnnotationComposer,
          $$UsageStatsTableCreateCompanionBuilder,
          $$UsageStatsTableUpdateCompanionBuilder,
          (
            UsageStat,
            BaseReferences<_$AppDatabase, $UsageStatsTable, UsageStat>,
          ),
          UsageStat,
          PrefetchHooks Function()
        > {
  $$UsageStatsTableTableManager(_$AppDatabase db, $UsageStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationsCreated = const Value.absent(),
                Value<int> searchesPerformed = const Value.absent(),
                Value<int> favoritesSaved = const Value.absent(),
                Value<int> versesShared = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsageStatsCompanion(
                id: id,
                conversationsCreated: conversationsCreated,
                searchesPerformed: searchesPerformed,
                favoritesSaved: favoritesSaved,
                versesShared: versesShared,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationsCreated = const Value.absent(),
                Value<int> searchesPerformed = const Value.absent(),
                Value<int> favoritesSaved = const Value.absent(),
                Value<int> versesShared = const Value.absent(),
                required DateTime updatedAt,
              }) => UsageStatsCompanion.insert(
                id: id,
                conversationsCreated: conversationsCreated,
                searchesPerformed: searchesPerformed,
                favoritesSaved: favoritesSaved,
                versesShared: versesShared,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageStatsTable,
      UsageStat,
      $$UsageStatsTableFilterComposer,
      $$UsageStatsTableOrderingComposer,
      $$UsageStatsTableAnnotationComposer,
      $$UsageStatsTableCreateCompanionBuilder,
      $$UsageStatsTableUpdateCompanionBuilder,
      (UsageStat, BaseReferences<_$AppDatabase, $UsageStatsTable, UsageStat>),
      UsageStat,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
  $$VerseTagsTableTableManager get verseTags =>
      $$VerseTagsTableTableManager(_db, _db.verseTags);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationContextsTableTableManager get conversationContexts =>
      $$ConversationContextsTableTableManager(_db, _db.conversationContexts);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$UsageStatsTableTableManager get usageStats =>
      $$UsageStatsTableTableManager(_db, _db.usageStats);
}
