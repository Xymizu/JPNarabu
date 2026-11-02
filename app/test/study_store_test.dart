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
            category: CardCategory.kotoba,
            level: CardLevel.n5,
            front: '猫',
            reading: 'ねこ',
            romaji: 'a',
            meaning: 'kucing',
            example: '',
            order: 1,
          ),
        ];
      var changes = 0;
      store.addListener(() => changes++);

      store.recordCard(store.cards.single);
      store.recordCard(store.cards.single);
      expect(store.activityToday(), 2);
      expect(changes, 2);
      expect(store.memorizedCountFor(store.cards), 0);
      expect(store.streak.current, 1);
      expect(store.streak.longest, 1);

      store.progressFor('test-1').memorized = true;
      store.progressFor('stale-card').memorized = true;
      expect(store.memorizedCountFor(store.cards), 1);

      await store.save();
      final restored = StudyStore(storageFile: file)..cards = store.cards;
      await restored.load();
      expect(restored.progressFor('test-1').timesSeen, 2);
      expect(restored.streak.current, 1);
    },
  );

  test('importDeck membuat kategori kustom beserta kartunya', () async {
    final file = File(
      '${Directory.systemTemp.path}/jpnarabu-import-test.json',
    );
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final store = StudyStore(storageFile: file);

    final deck = await store.importDeck(
      name: 'Kotoba Bab 1',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      csvContent: '猫 (ねこ),kucing\n犬 (いぬ),anjing\n',
      sourceName: 'bab1.csv',
    );

    expect(deck.isBuiltIn, isFalse);
    expect(store.customDecks.single.id, deck.id);
    final cards = store.cardsForDeck(deck);
    expect(cards, hasLength(2));
    expect(cards.first.deckId, deck.id);
    expect(cards.first.resolvedDeckId, deck.id);
    expect(cards.first.id, '${deck.id}-0001');
    expect(cards.last.id, '${deck.id}-0002');
    expect(store.visibleDecks, contains(deck));

    expect(
      () => store.importDeck(
        name: 'kotoba bab 1',
        category: CardCategory.kotoba,
        level: CardLevel.n5,
        csvContent: '猫 (ねこ),kucing\n',
        sourceName: 'bab1.csv',
      ),
      throwsFormatException,
    );

    final reloaded = StudyStore(storageFile: file);
    await reloaded.load();
    expect(reloaded.customDecks.single.name, 'Kotoba Bab 1');
    expect(reloaded.cardsForDeck(reloaded.customDecks.single), hasLength(2));
  });

  test('edit dan hapus kartu bawaan memakai override tanpa ubah CSV', () async {
    final file = File(
      '${Directory.systemTemp.path}/jpnarabu-override-test.json',
    );
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final store = StudyStore(storageFile: file);
    await store.load();
    final deck = store.builtInDecks.first;
    final original = store.cardsForDeck(deck).first;

    await store.saveCard(
      deck: deck,
      original: original,
      front: '変更',
      reading: 'へんこう',
      meaning: 'ubah',
      example: '',
    );

    expect(store.cardById(original.id)?.front, '変更');
    expect(store.customCards, isEmpty);
    expect(store.cardOverrides[original.id]?.front, '変更');

    await store.deleteCard(store.cardById(original.id)!);
    expect(store.cardById(original.id), isNull);
    expect(store.deletedBuiltInCardIds, contains(original.id));

    final restored = StudyStore(storageFile: file);
    await restored.load();
    expect(restored.cardById(original.id), isNull);
  });

  test('tambah kartu ke deck bawaan tersimpan setelah reload', () async {
    final file = File(
      '${Directory.systemTemp.path}/jpnarabu-add-builtin-test.json',
    );
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final store = StudyStore(storageFile: file);
    await store.load();
    final deck = store.builtInDecks.first;

    await store.saveCard(
      deck: deck,
      front: '追加',
      reading: 'ついか',
      meaning: 'tambahan',
      example: '',
    );

    final added = store.cardsForDeck(deck).last;
    expect(added.front, '追加');
    expect(added.deckId, deck.id);
    expect(store.customCards, contains(added));

    final reloaded = StudyStore(storageFile: file);
    await reloaded.load();
    expect(
      reloaded.cardsForDeck(deck).any((card) => card.front == '追加'),
      isTrue,
    );
  });

  test('hapus kategori bawaan menyembunyikan, kategori kustom permanen', () async {
    final file = File(
      '${Directory.systemTemp.path}/jpnarabu-delete-deck-test.json',
    );
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final store = StudyStore(storageFile: file);
    await store.load();
    final builtIn = store.builtInDecks.first;

    await store.deleteDeck(builtIn);
    expect(store.hiddenDeckIds, contains(builtIn.id));
    expect(
      store.visibleDecks.any((deck) => deck.id == builtIn.id),
      isFalse,
    );
    expect(
      store.visibleCards.any((card) => card.resolvedDeckId == builtIn.id),
      isFalse,
    );

    await store.restoreHiddenDecks();
    expect(store.hiddenDeckIds, isEmpty);
    expect(
      store.visibleDecks.any((deck) => deck.id == builtIn.id),
      isTrue,
    );

    final custom = await store.importDeck(
      name: 'Kotoba Hapus',
      category: CardCategory.kotoba,
      level: CardLevel.n5,
      csvContent: '猫 (ねこ),kucing\n',
      sourceName: 'hapus.csv',
    );
    final card = store.cardsForDeck(custom).single;
    store.progressFor(card.id).memorized = true;

    await store.deleteDeck(custom);
    expect(store.deckById(custom.id), isNull);
    expect(store.customDecks, isEmpty);
    expect(store.cardsForDeck(custom), isEmpty);
    expect(store.progress.containsKey(card.id), isFalse);
  });
}
