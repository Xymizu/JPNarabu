import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/data/repositories/study_store.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'target harian tercapai menaikkan streak dan menyimpan progres',
    () async {
      final file = File(
        '${Directory.systemTemp.path}/jpnarabu-store-test.json',
      );
      addTearDown(() async {
        if (await file.exists()) await file.delete();
      });
      final store = StudyStore(storageFile: file)
        ..settings.dailyTarget = 2
        ..cards = [
          const StudyCard(
            id: 'test-1',
            category: CardCategory.hiragana,
            level: CardLevel.basic,
            front: 'あ',
            reading: 'あ',
            romaji: 'a',
            meaning: 'a',
            example: '',
            order: 1,
          ),
        ];

      store.recordCard(store.cards.single);
      store.recordCard(store.cards.single);
      expect(store.activityToday(), 2);
      expect(store.streak.current, 1);
      expect(store.streak.longest, 1);

      await store.save();
      final restored = StudyStore(storageFile: file)..cards = store.cards;
      await restored.load();
      expect(restored.progressFor('test-1').timesSeen, 2);
      expect(restored.streak.current, 1);
    },
  );
}
