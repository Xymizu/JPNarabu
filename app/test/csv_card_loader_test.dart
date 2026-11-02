import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/data/sources/csv_card_loader.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';

void main() {
  const loader = CsvCardLoader();

  test('memetakan Kotoba menjadi teks depan dan Kanji', () {
    final cards = loader.parse(
      content: 'みます (見ます／診ます),"melihat, memeriksa"\n',
      category: CardCategory.kotoba,
      level: CardLevel.n4,
      sourceName: 'kotoba.csv',
    );

    expect(cards.single.front, 'みます');
    expect(cards.single.reading, '見ます／診ます');
    expect(cards.single.meaning, 'melihat, memeriksa');
    expect(cards.single.level, CardLevel.n4);
  });

  test('memetakan Kotoba N3 menjadi kana di depan dan kanji di bawahnya', () {
    final cards = loader.parse(
      content: '有る (ある),ada\n',
      category: CardCategory.kotoba,
      level: CardLevel.n3,
      sourceName: 'kotoba-n3.csv',
    );

    expect(cards.single.front, 'ある');
    expect(cards.single.reading, '有る');
    expect(cards.single.meaning, 'ada');
  });

  test('mempertahankan Kotoba N3 yang hanya memiliki kana', () {
    final cards = loader.parse(
      content: 'がっかりする,kecewa\n',
      category: CardCategory.kotoba,
      level: CardLevel.n3,
      sourceName: 'kotoba-n3.csv',
    );

    expect(cards.single.front, 'がっかりする');
    expect(cards.single.reading, isEmpty);
  });

  test('memetakan Kanji menjadi Kanji, kunyomi, dan arti', () {
    final cards = loader.parse(
      content: '一つ,ひとつ — 1 buah\n',
      category: CardCategory.kanji,
      level: CardLevel.n5,
      sourceName: 'kanji.csv',
    );

    expect(cards.single.front, '一つ');
    expect(cards.single.reading, 'ひとつ');
    expect(cards.single.meaning, '1 buah');
  });

  test('memakai deckId dan prefiks ID kustom', () {
    final cards = loader.parse(
      content: '猫 (ねこ),kucing\n犬 (いぬ),anjing\n',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      sourceName: 'kustom.csv',
      deckId: 'custom-1',
      idPrefix: 'custom-1',
    );

    expect(cards.map((card) => card.id), ['custom-1-0001', 'custom-1-0002']);
    expect(cards.every((card) => card.deckId == 'custom-1'), isTrue);
    expect(cards.first.resolvedDeckId, 'custom-1');
  });

  test('menolak baris dengan format kolom yang salah', () {
    expect(
      () => loader.parse(
        content: 'satu kolom saja\n',
        category: CardCategory.kotoba,
        level: CardLevel.n5,
        sourceName: 'kotoba.csv',
      ),
      throwsFormatException,
    );
  });
}
