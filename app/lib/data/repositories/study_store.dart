import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/card_models.dart';
import '../sources/csv_card_loader.dart';

class StudyStore extends ChangeNotifier {
  StudyStore({this.storageFile});

  final File? storageFile;
  List<StudyCard> cards = [];
  final Map<String, CardProgress> progress = {};
  UserSettings settings = UserSettings();
  Streak streak = Streak();
  final List<DailyLog> history = [];
  DateTime? lastBackupAt;

  final List<StudyDeck> customDecks = [];
  final List<StudyCard> customCards = [];
  final Map<String, StudyCard> cardOverrides = {};
  final Set<String> deletedBuiltInCardIds = <String>{};
  final Set<String> hiddenDeckIds = <String>{};
  final Set<String> builtInCardIds = <String>{};

  static const List<StudyDeck> _builtInDecks = [
    StudyDeck(
      id: 'kotoba-n5',
      name: 'Kotoba N5',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      isBuiltIn: true,
    ),
    StudyDeck(
      id: 'kanji-n5',
      name: 'Kanji N5',
      category: CardCategory.kanji,
      level: CardLevel.n5,
      isBuiltIn: true,
    ),
    StudyDeck(
      id: 'kotoba-n4',
      name: 'Kotoba N4',
      category: CardCategory.kotoba,
      level: CardLevel.n4,
      isBuiltIn: true,
    ),
    StudyDeck(
      id: 'kanji-n4',
      name: 'Kanji N4',
      category: CardCategory.kanji,
      level: CardLevel.n4,
      isBuiltIn: true,
    ),
    StudyDeck(
      id: 'kotoba-n3',
      name: 'Kotoba N3',
      category: CardCategory.kotoba,
      level: CardLevel.n3,
      isBuiltIn: true,
    ),
    StudyDeck(
      id: 'kanji-n3',
      name: 'Kanji N3',
      category: CardCategory.kanji,
      level: CardLevel.n3,
      isBuiltIn: true,
    ),
  ];

  List<StudyDeck> get builtInDecks => _builtInDecks;

  List<StudyDeck> get visibleDecks => [
    ..._builtInDecks,
    ...customDecks,
  ].where((deck) => !hiddenDeckIds.contains(deck.id)).toList();

  List<StudyCard> get visibleCards => cards
      .where((card) => !hiddenDeckIds.contains(card.resolvedDeckId))
      .toList();

  int get totalVisibleCards => visibleCards.length;

  StudyDeck? deckById(String id) {
    for (final deck in _builtInDecks) {
      if (deck.id == id) return deck;
    }
    for (final deck in customDecks) {
      if (deck.id == id) return deck;
    }
    return null;
  }

  StudyDeck builtInDeck(CardCategory category, CardLevel level) =>
      _builtInDecks.firstWhere(
        (deck) => deck.category == category && deck.level == level,
        orElse: () => StudyDeck(
          id: '${category.name}-${level.name}',
          name: '${category.name} ${level.name.toUpperCase()}',
          category: category,
          level: level,
          isBuiltIn: true,
        ),
      );

  List<StudyCard> cardsForDeck(StudyDeck deck) =>
      cards.where((card) => card.resolvedDeckId == deck.id).toList();

  StudyCard? cardById(String id) {
    for (final card in cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  Future<List<StudyCard>> _parseBuiltInCards() async {
    const loader = CsvCardLoader();
    return [
      ...loader.parse(
        content: await rootBundle.loadString('assets/data/kotoba-n5.csv'),
        category: CardCategory.kotoba,
        level: CardLevel.n5,
        sourceName: 'kotoba-n5.csv',
      ),
      ...loader.parse(
        content: await rootBundle.loadString(
          'assets/data/kotoba-pelajaran-26-50.csv',
        ),
        category: CardCategory.kotoba,
        level: CardLevel.n4,
        sourceName: 'kotoba-pelajaran-26-50.csv',
      ),
      ...loader.parse(
        content: await rootBundle.loadString('assets/data/kanji-n5.csv'),
        category: CardCategory.kanji,
        level: CardLevel.n5,
        sourceName: 'kanji-n5.csv',
      ),
      ...loader.parse(
        content: await rootBundle.loadString('assets/data/kanji-n4.csv'),
        category: CardCategory.kanji,
        level: CardLevel.n4,
        sourceName: 'kanji-n4.csv',
      ),
      ...loader.parse(
        content: await rootBundle.loadString('assets/data/kotoba-n3.csv'),
        category: CardCategory.kotoba,
        level: CardLevel.n3,
        sourceName: 'kotoba-n3.csv',
      ),
      ...loader.parse(
        content: await rootBundle.loadString('assets/data/kanji-n3.csv'),
        category: CardCategory.kanji,
        level: CardLevel.n3,
        sourceName: 'kanji-n3.csv',
      ),
    ];
  }

  Future<File> _file() async =>
      storageFile ??
      File('${(await getApplicationDocumentsDirectory()).path}/jpnarabu.json');

  void _rebuildCards(List<StudyCard> base) {
    builtInCardIds
      ..clear()
      ..addAll(base.map((card) => card.id));
    cards = [
      for (final card in base)
        if (!deletedBuiltInCardIds.contains(card.id))
          cardOverrides[card.id] ?? card,
      ...customCards,
    ];
  }

  Future<void> load() async {
    final base = await _parseBuiltInCards();
    customDecks.clear();
    customCards.clear();
    cardOverrides.clear();
    deletedBuiltInCardIds.clear();
    hiddenDeckIds.clear();
    final file = await _file();
    if (await file.exists()) {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      customDecks.addAll(_objectList(data['customDecks'], StudyDeck.fromJson));
      customCards.addAll(_objectList(data['customCards'], StudyCard.fromJson));
      for (final card in _objectList(data['cardOverrides'], StudyCard.fromJson)) {
        cardOverrides[card.id] = card;
      }
      deletedBuiltInCardIds.addAll(_stringList(data['deletedCardIds']));
      hiddenDeckIds.addAll(_stringList(data['hiddenDeckIds']));
      settings = UserSettings.fromJson(
        data['settings'] as Map<String, dynamic>,
      );
      streak = Streak.fromJson(data['streak'] as Map<String, dynamic>);
      progress
        ..clear()
        ..addEntries(
          (data['progress'] as List<dynamic>)
              .map((item) => CardProgress.fromJson(item as Map<String, dynamic>))
              .map((item) => MapEntry(item.cardId, item)),
        );
      history
        ..clear()
        ..addAll(
          (data['history'] as List<dynamic>).map(
            (item) => DailyLog.fromJson(item as Map<String, dynamic>),
          ),
        );
      lastBackupAt = data['lastBackupAt'] == null
          ? null
          : DateTime.parse(data['lastBackupAt'] as String);
    }
    _rebuildCards(base);
    notifyListeners();
  }

  Future<void> save() async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      jsonEncode({
        'settings': settings.toJson(),
        'progress': progress.values.map((item) => item.toJson()).toList(),
        'streak': streak.toJson(),
        'history': history.map((item) => item.toJson()).toList(),
        'lastBackupAt': lastBackupAt?.toIso8601String(),
        'customDecks': customDecks.map((item) => item.toJson()).toList(),
        'customCards': customCards.map((item) => item.toJson()).toList(),
        'cardOverrides': cardOverrides.values
            .map((item) => item.toJson())
            .toList(),
        'deletedCardIds': deletedBuiltInCardIds.toList(),
        'hiddenDeckIds': hiddenDeckIds.toList(),
      }),
    );
    await temp.rename(file.path);
  }

  CardProgress progressFor(String cardId) =>
      progress.putIfAbsent(cardId, () => CardProgress(cardId: cardId));

  List<StudyCard> deck(CardCategory category, CardLevel level) =>
      cardsForDeck(builtInDeck(category, level));

  int memorizedCountFor(Iterable<StudyCard> deckCards) => deckCards
      .where((card) => progress[card.id]?.memorized ?? false)
      .length;

  Future<StudyDeck> importDeck({
    required String name,
    required CardCategory category,
    required CardLevel level,
    required String csvContent,
    required String sourceName,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Nama kategori tidak boleh kosong.');
    }
    final duplicate = [..._builtInDecks, ...customDecks].any(
      (deck) => deck.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw const FormatException('Nama kategori sudah digunakan.');
    }
    final deck = StudyDeck(
      id: _newId('custom'),
      name: trimmed,
      category: category,
      level: level,
      isBuiltIn: false,
    );
    final parsed = const CsvCardLoader().parse(
      content: csvContent,
      category: category,
      level: level,
      sourceName: sourceName,
      deckId: deck.id,
      idPrefix: deck.id,
    );
    customDecks.add(deck);
    customCards.addAll(parsed);
    cards.addAll(parsed);
    await save();
    notifyListeners();
    return deck;
  }

  Future<void> saveCard({
    required StudyDeck deck,
    StudyCard? original,
    required String front,
    required String reading,
    required String meaning,
    required String example,
  }) async {
    final trimmedFront = front.trim();
    final trimmedMeaning = meaning.trim();
    if (trimmedFront.isEmpty || trimmedMeaning.isEmpty) {
      throw const FormatException('Kata/kanji dan arti wajib diisi.');
    }
    final updated = original == null
        ? StudyCard(
            id: _newId('custom-${deck.id}'),
            category: deck.category,
            level: deck.level,
            front: trimmedFront,
            reading: reading.trim(),
            romaji: '',
            meaning: trimmedMeaning,
            example: example.trim(),
            order: _nextOrder(deck),
            deckId: deck.id,
          )
        : original.copyWith(
            category: deck.category,
            level: deck.level,
            front: trimmedFront,
            reading: reading.trim(),
            meaning: trimmedMeaning,
            example: example.trim(),
            deckId: deck.id,
          );
    if (original == null) {
      customCards.add(updated);
      cards.add(updated);
    } else {
      final customIndex = customCards.indexWhere(
        (card) => card.id == original.id,
      );
      if (customIndex >= 0) {
        customCards[customIndex] = updated;
      } else {
        cardOverrides[original.id] = updated;
      }
      final cardIndex = cards.indexWhere((card) => card.id == original.id);
      if (cardIndex >= 0) {
        cards[cardIndex] = updated;
      } else {
        cards.add(updated);
      }
    }
    await save();
    notifyListeners();
  }

  Future<void> deleteCard(StudyCard card) async {
    final customIndex = customCards.indexWhere((item) => item.id == card.id);
    if (customIndex >= 0) {
      customCards.removeAt(customIndex);
    } else {
      deletedBuiltInCardIds.add(card.id);
    }
    cardOverrides.remove(card.id);
    cards.removeWhere((item) => item.id == card.id);
    progress.remove(card.id);
    await save();
    notifyListeners();
  }

  Future<void> deleteDeck(StudyDeck deck) async {
    if (deck.isBuiltIn) {
      hiddenDeckIds.add(deck.id);
    } else {
      final ids = cardsForDeck(deck).map((card) => card.id).toSet();
      customDecks.removeWhere((item) => item.id == deck.id);
      customCards.removeWhere((card) => card.resolvedDeckId == deck.id);
      cardOverrides.removeWhere((id, _) => ids.contains(id));
      cards.removeWhere((card) => card.resolvedDeckId == deck.id);
      for (final id in ids) {
        progress.remove(id);
      }
      settings.lastFilters.remove(deck.id);
    }
    await save();
    notifyListeners();
  }

  Future<void> restoreHiddenDecks() async {
    hiddenDeckIds.clear();
    await save();
    notifyListeners();
  }

  int _nextOrder(StudyDeck deck) {
    var highest = 0;
    for (final card in cardsForDeck(deck)) {
      if (card.order > highest) highest = card.order;
    }
    return highest + 1;
  }

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-'
      '${Random().nextInt(1 << 31)}';

  void recordCard(StudyCard card) {
    final item = progressFor(card.id);
    item.timesSeen++;
    item.lastSeen = DateTime.now();
    _recordActivity(cards: 1);
    notifyListeners();
  }

  void _recordActivity({int cards = 0}) {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final log = history.firstWhere(
      (item) => _isSameDay(item.date, key),
      orElse: () {
        final value = DailyLog(date: key);
        history.add(value);
        return value;
      },
    );
    log.cards += cards;
    _updateStreak(key);
  }

  void _updateStreak(DateTime today) {
    final target = settings.dailyTarget;
    final log = history.firstWhere((item) => _isSameDay(item.date, today));
    if (log.total < target) return;
    if (_isSameDay(streak.lastCompleted, today)) return;
    final yesterday = today.subtract(const Duration(days: 1));
    streak.current = _isSameDay(streak.lastCompleted, yesterday)
        ? streak.current + 1
        : 1;
    streak.longest = streak.current > streak.longest
        ? streak.current
        : streak.longest;
    streak.lastCompleted = today;
  }

  bool _isSameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  int activityToday() {
    final today = DateTime.now();
    return history
        .where(
          (item) =>
              item.date.year == today.year &&
              item.date.month == today.month &&
              item.date.day == today.day,
        )
        .fold(0, (sum, item) => sum + item.total);
  }

  Future<void> applyBackup(BackupData backup) async {
    customDecks
      ..clear()
      ..addAll(backup.customDecks);
    customCards
      ..clear()
      ..addAll(backup.customCards);
    cardOverrides
      ..clear()
      ..addEntries(backup.cardOverrides.map((card) => MapEntry(card.id, card)));
    deletedBuiltInCardIds
      ..clear()
      ..addAll(backup.deletedCardIds);
    hiddenDeckIds
      ..clear()
      ..addAll(backup.hiddenDeckIds);
    _rebuildCards(await _parseBuiltInCards());
    final known = cards.map((card) => card.id).toSet();
    progress
      ..clear()
      ..addEntries(
        backup.progress
            .where((item) => known.contains(item.cardId))
            .map((item) => MapEntry(item.cardId, item)),
      );
    settings = backup.settings;
    streak = backup.streak;
    history
      ..clear()
      ..addAll(backup.history);
    lastBackupAt = backup.exportedAt;
    await save();
    notifyListeners();
  }

  Future<void> reset({CardCategory? category, CardLevel? level}) async {
    final ids = cards
        .where(
          (card) =>
              category == null ||
              (card.category == category &&
                  (level == null || card.level == level)),
        )
        .map((card) => card.id)
        .toSet();
    progress.removeWhere((key, _) => ids.contains(key));
    await save();
    notifyListeners();
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
