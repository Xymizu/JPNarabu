import 'dart:convert';

enum CardCategory { hiragana, katakana, kanji, kotoba }

enum CardLevel { basic, n5, n4, n3 }

enum CardFilter { all, unseen, memorized, difficult }

enum AppTheme { light, dark }

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
    Map<String, CardFilter>? lastFilters,
  }) : lastFilters = lastFilters ?? {};

  AppTheme theme;
  int dailyTarget;
  String? nickname;
  bool showOnyomi;
  bool showExamples;
  final Map<String, CardFilter> lastFilters;

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'dailyTarget': dailyTarget,
    'nickname': nickname,
    'showOnyomi': showOnyomi,
    'showExamples': showExamples,
    'lastFilters': lastFilters.map((key, value) => MapEntry(key, value.name)),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    theme: AppTheme.values.byName(json['theme'] as String? ?? 'dark'),
    dailyTarget: json['dailyTarget'] as int? ?? 10,
    nickname: json['nickname'] as String?,
    showOnyomi: json['showOnyomi'] as bool? ?? true,
    showExamples: json['showExamples'] as bool? ?? true,
    lastFilters: (json['lastFilters'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, CardFilter.values.byName(value as String)),
    ),
  );
}

class BackupData {
  BackupData({
    required this.exportedAt,
    required this.settings,
    required this.progress,
    required this.streak,
    required this.history,
    this.schemaVersion = 1,
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final UserSettings settings;
  final List<CardProgress> progress;
  final Streak streak;
  final List<DailyLog> history;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'settings': settings.toJson(),
    'progress': progress.map((item) => item.toJson()).toList(),
    'streak': streak.toJson(),
    'history': history.map((item) => item.toJson()).toList(),
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
    );
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
