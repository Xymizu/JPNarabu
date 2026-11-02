import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';

void main() {
  test('backup serialisasi mempertahankan data progres dan pengaturan', () {
    final backup = BackupData(
      exportedAt: DateTime(2026, 10, 31),
      settings: UserSettings(nickname: 'Fahri'),
      progress: [CardProgress(cardId: 'hiragana-a', memorized: true)],
      streak: Streak(current: 2, longest: 4),
      history: [DailyLog(date: DateTime(2026, 10, 31), cards: 3)],
    );

    final restored = BackupData.fromJson(backup.toJson());
    expect(restored.settings.nickname, 'Fahri');
    expect(restored.progress.single.memorized, isTrue);
    expect(restored.streak.current, 2);
    expect(restored.history.single.cards, 3);
  });

  test('backup mempertahankan kategori kustom dan edit kartu', () {
    const deck = StudyDeck(
      id: 'custom-1',
      name: 'Kotoba Bab 1',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      isBuiltIn: false,
    );
    const customCard = StudyCard(
      id: 'custom-1-0001',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      front: '猫',
      reading: 'ねこ',
      romaji: '',
      meaning: 'kucing',
      example: '',
      order: 1,
      deckId: 'custom-1',
    );
    final backup = BackupData(
      exportedAt: DateTime(2026, 10, 31),
      settings: UserSettings(),
      progress: const [],
      streak: Streak(),
      history: const [],
      customDecks: const [deck],
      customCards: const [customCard],
      cardOverrides: const [customCard],
      deletedCardIds: const ['kotoba-n5-0001'],
      hiddenDeckIds: const ['kanji-n5'],
    );

    final restored = BackupData.fromJson(backup.toJson());
    expect(restored.customDecks.single.name, 'Kotoba Bab 1');
    expect(restored.customCards.single.deckId, 'custom-1');
    expect(restored.cardOverrides.single.id, 'custom-1-0001');
    expect(restored.deletedCardIds, ['kotoba-n5-0001']);
    expect(restored.hiddenDeckIds, ['kanji-n5']);
  });

  test('backup lama tanpa data kustom tetap bisa dibaca', () {
    final restored = BackupData.fromJson({
      'schemaVersion': 1,
      'exportedAt': DateTime(2026, 10, 31).toIso8601String(),
      'settings': UserSettings().toJson(),
      'progress': const [],
      'streak': Streak().toJson(),
      'history': const [],
    });

    expect(restored.customDecks, isEmpty);
    expect(restored.customCards, isEmpty);
    expect(restored.cardOverrides, isEmpty);
    expect(restored.deletedCardIds, isEmpty);
    expect(restored.hiddenDeckIds, isEmpty);
  });

  test('card dengan ID kosong ditolak', () {
    expect(
      () => StudyCard.fromJson({
        'id': '',
        'category': 'hiragana',
        'level': 'basic',
        'front': 'あ',
        'meaning': 'a',
        'order': 1,
      }),
      throwsFormatException,
    );
  });
}
