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
