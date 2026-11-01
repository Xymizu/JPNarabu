import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/data/repositories/study_store.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asset data offline memuat semua deck dengan ID unik', () async {
    final store = StudyStore(
      storageFile: File(
        '${Directory.systemTemp.path}/jpnarabu-asset-test.json',
      ),
    );
    await store.load();

    expect(store.cards.length, greaterThan(2400));
    expect(
      store.cards.map((card) => card.id).toSet().length,
      store.cards.length,
    );
    for (final deck in [
      (CardCategory.hiragana, CardLevel.basic),
      (CardCategory.katakana, CardLevel.basic),
      (CardCategory.kanji, CardLevel.n5),
      (CardCategory.kanji, CardLevel.n4),
      (CardCategory.kanji, CardLevel.n3),
      (CardCategory.kotoba, CardLevel.n5),
      (CardCategory.kotoba, CardLevel.n4),
      (CardCategory.kotoba, CardLevel.n3),
    ]) {
      expect(store.deck(deck.$1, deck.$2), isNotEmpty);
    }
  });
}
