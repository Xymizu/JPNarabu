import 'dart:convert';

enum CardCategory { kanji, kotoba }

enum CardLevel { n5, n4, n3 }

enum CardFilter { all, unseen, memorized, difficult }

enum AppTheme { light, dark }

enum FlashcardTextSize { kecil, sedang, besar }

class StudyDeck {
  const StudyDeck({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.isBuiltIn,
  });

  final String id;
  final String name;
  final CardCategory category;
  final CardLevel level;
  final bool isBuiltIn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'level': level.name,
    'isBuiltIn': isBuiltIn,
  };

  factory StudyDeck.fromJson(Map<String, dynamic> json) => StudyDeck(
    id: json['id'] as String,
    name: json['name'] as String,
    category: CardCategory.values.byName(json['category'] as String),
    level: CardLevel.values.byName(json['level'] as String),
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
  );
}

class StudyCard {
  const StudyCard({
    required this.id,
    required this.category,
    required this.level,
    required this.front,
    required this.reading,
    required this.romaji,
    required this.meaning,
    required this.example,
    required this.order,
    this.deckId = '',
  });

  final String id;
  final CardCategory category;
  final CardLevel level;
  final String front;
  final String reading;
  final String romaji;
  final String meaning;
  final String example;
  final int order;
  final String deckId;

  String get resolvedDeckId =>
      deckId.isNotEmpty ? deckId : '${category.name}-${level.name}';

  StudyCard copyWith({
    String? id,
    CardCategory? category,
    CardLevel? level,
    String? front,
    String? reading,
    String? romaji,
    String? meaning,
    String? example,
    int? order,
    String? deckId,
  }) => StudyCard(
    id: id ?? this.id,
    category: category ?? this.category,
    level: level ?? this.level,
    front: front ?? this.front,
    reading: reading ?? this.reading,
    romaji: romaji ?? this.romaji,
    meaning: meaning ?? this.meaning,
    example: example ?? this.example,
    order: order ?? this.order,
    deckId: deckId ?? this.deckId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'level': level.name,
    'front': front,
    'reading': reading,
    'romaji': romaji,
    'meaning': meaning,
    'example': example,
    'order': order,
    'deckId': deckId,
  };

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    if (id.trim().isEmpty) {
      throw const FormatException('Card ID tidak boleh kosong.');
    }
    return StudyCard(
      id: id,
      category: CardCategory.values.byName(json['category'] as String),
      level: CardLevel.values.byName(json['level'] as String),
      front: json['front'] as String,
      reading: json['reading'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      meaning: json['meaning'] as String,
      example: json['example'] as String? ?? '',
      order: json['order'] as int,
      deckId: json['deckId'] as String? ?? '',
    );
  }
}

class CardProgress {
  CardProgress({
    required this.cardId,
    this.memorized = false,
    this.difficult = false,
    this.timesSeen = 0,
    this.lastSeen,
  });

  final String cardId;
  bool memorized;
  bool difficult;
  int timesSeen;
  DateTime? lastSeen;

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'memorized': memorized,
    'difficult': difficult,
    'timesSeen': timesSeen,
    'lastSeen': lastSeen?.toIso8601String(),
  };

  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
    cardId: json['cardId'] as String,
    memorized: json['memorized'] as bool? ?? false,
    difficult: json['difficult'] as bool? ?? false,
    timesSeen: json['timesSeen'] as int? ?? 0,
    lastSeen: json['lastSeen'] == null
        ? null
        : DateTime.parse(json['lastSeen'] as String),
  );
}

class DailyLog {
  DailyLog({required this.date, this.cards = 0, this.questions = 0});

  final DateTime date;
  int cards;
  int questions;

  int get total => cards + questions;

  Map<String, dynamic> toJson() => {
    'date': _dateKey(date),
    'cards': cards,
    'questions': questions,
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
    date: DateTime.parse(json['date'] as String),
    cards: json['cards'] as int? ?? 0,
    questions: json['questions'] as int? ?? 0,
  );
}

class Streak {
  Streak({this.current = 0, this.longest = 0, this.lastCompleted});

  int current;
  int longest;
  DateTime? lastCompleted;

  Map<String, dynamic> toJson() => {
    'current': current,
    'longest': longest,
    'lastCompleted': lastCompleted == null ? null : _dateKey(lastCompleted!),
  };

  factory Streak.fromJson(Map<String, dynamic> json) => Streak(
    current: json['current'] as int? ?? 0,
    longest: json['longest'] as int? ?? 0,
    lastCompleted: json['lastCompleted'] == null
        ? null
        : DateTime.parse(json['lastCompleted'] as String),
  );
}

class UserSettings {
  UserSettings({
    this.theme = AppTheme.dark,
    this.dailyTarget = 10,
    this.nickname,
    this.showOnyomi = true,
    this.showExamples = true,
    this.flashcardTextSize = FlashcardTextSize.sedang,
    Map<String, CardFilter>? lastFilters,
  }) : lastFilters = lastFilters ?? {};

  AppTheme theme;
  int dailyTarget;
  String? nickname;
  bool showOnyomi;
  bool showExamples;
  FlashcardTextSize flashcardTextSize;
  final Map<String, CardFilter> lastFilters;

  double get flashcardTextScale => switch (flashcardTextSize) {
    FlashcardTextSize.kecil => 0.8,
    FlashcardTextSize.sedang => 1.0,
    FlashcardTextSize.besar => 1.3,
  };

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'dailyTarget': dailyTarget,
    'nickname': nickname,
    'showOnyomi': showOnyomi,
    'showExamples': showExamples,
    'flashcardTextSize': flashcardTextSize.name,
    'lastFilters': lastFilters.map((key, value) => MapEntry(key, value.name)),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    theme: AppTheme.values.byName(json['theme'] as String? ?? 'dark'),
    dailyTarget: json['dailyTarget'] as int? ?? 10,
    nickname: json['nickname'] as String?,
    showOnyomi: json['showOnyomi'] as bool? ?? true,
    showExamples: json['showExamples'] as bool? ?? true,
    flashcardTextSize: _parseFlashcardTextSize(json['flashcardTextSize']),
    lastFilters: (json['lastFilters'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, CardFilter.values.byName(value as String)),
    ),
  );
}

FlashcardTextSize _parseFlashcardTextSize(Object? value) {
  for (final size in FlashcardTextSize.values) {
    if (size.name == value) return size;
  }
  return FlashcardTextSize.sedang;
}

class BackupData {
  BackupData({
    required this.exportedAt,
    required this.settings,
    required this.progress,
    required this.streak,
    required this.history,
    this.schemaVersion = 1,
    this.customDecks = const [],
    this.customCards = const [],
    this.cardOverrides = const [],
    this.deletedCardIds = const [],
    this.hiddenDeckIds = const [],
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final UserSettings settings;
  final List<CardProgress> progress;
  final Streak streak;
  final List<DailyLog> history;
  final List<StudyDeck> customDecks;
  final List<StudyCard> customCards;
  final List<StudyCard> cardOverrides;
  final List<String> deletedCardIds;
  final List<String> hiddenDeckIds;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'settings': settings.toJson(),
    'progress': progress.map((item) => item.toJson()).toList(),
    'streak': streak.toJson(),
    'history': history.map((item) => item.toJson()).toList(),
    'customDecks': customDecks.map((item) => item.toJson()).toList(),
    'customCards': customCards.map((item) => item.toJson()).toList(),
    'cardOverrides': cardOverrides.map((item) => item.toJson()).toList(),
    'deletedCardIds': deletedCardIds,
    'hiddenDeckIds': hiddenDeckIds,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory BackupData.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Versi backup tidak didukung.');
    }
    return BackupData(
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      progress: (json['progress'] as List<dynamic>)
          .map((item) => CardProgress.fromJson(item as Map<String, dynamic>))
          .toList(),
      streak: Streak.fromJson(json['streak'] as Map<String, dynamic>),
      history: (json['history'] as List<dynamic>)
          .map((item) => DailyLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      customDecks: _objectList(json['customDecks'], StudyDeck.fromJson),
      customCards: _objectList(json['customCards'], StudyCard.fromJson),
      cardOverrides: _objectList(json['cardOverrides'], StudyCard.fromJson),
      deletedCardIds: _stringList(json['deletedCardIds']),
      hiddenDeckIds: _stringList(json['hiddenDeckIds']),
    );
  }
}

List<T> _objectList<T>(
  Object? value,
  T Function(Map<String, dynamic>) parse,
) {
  if (value is! List) return <T>[];
  return [
    for (final item in value)
      if (item is Map) parse(Map<String, dynamic>.from(item)),
  ];
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is String) item,
  ];
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
