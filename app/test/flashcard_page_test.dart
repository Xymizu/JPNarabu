import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/core/navigation/app_router.dart';
import 'package:jpnarabu_app/core/theme/app_theme.dart' as theme;
import 'package:jpnarabu_app/data/repositories/study_store.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';
import 'package:jpnarabu_app/presentation/pages/card_editor_page.dart';
import 'package:jpnarabu_app/presentation/pages/flashcard_page.dart';

const longKotoba = '[ちょっと] おねがいが あるんですが。（[ちょっと] お願いが あるんですが。）';

class _MemoryStudyStore extends StudyStore {
  @override
  Future<void> save() async {}
}

StudyCard _card({
  String id = 'test-1',
  CardCategory category = CardCategory.kotoba,
  String front = '猫',
  String reading = 'ねこ',
  String meaning = 'kucing',
  String example = '猫がいます。',
}) => StudyCard(
  id: id,
  category: category,
  level: category == CardCategory.kanji ? CardLevel.n5 : CardLevel.n5,
  front: front,
  reading: reading,
  romaji: '',
  meaning: meaning,
  example: example,
  order: 1,
);

Widget _app(StudyStore store, {CardCategory? category}) => MaterialApp(
  home: FlashcardPage(store: store, category: category),
);

Widget _appWithEditor(StudyStore store) => MaterialApp(
  home: FlashcardPage(store: store, category: CardCategory.kotoba),
  onGenerateRoute: (settings) {
    if (settings.name == AppRoutes.cardEditor) {
      final args = settings.arguments as Map?;
      return MaterialPageRoute<void>(
        builder: (_) => CardEditorPage(
          store: store,
          deckId: args?['deckId'] as String?,
          cardId: args?['cardId'] as String?,
        ),
      );
    }
    return null;
  },
);

void main() {
  testWidgets('teks kotoba panjang tampil utuh tanpa overflow', (tester) async {
    final store = StudyStore()
      ..cards = [
        _card(front: longKotoba, reading: longKotoba, meaning: 'permisi'),
      ];
    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(longKotoba), findsNWidgets(2));
  });

  testWidgets('sisi belakang kanji menampilkan bacaan, kanji, dan arti', (
    tester,
  ) async {
    final store = StudyStore()
      ..cards = [
        _card(
          id: 'kanji-kin',
          category: CardCategory.kanji,
          front: '金',
          reading: 'kin / kane',
          meaning: 'uang',
          example: 'お金',
        ),
      ];
    await tester.pumpWidget(_app(store, category: CardCategory.kanji));
    await tester.pumpAndSettle();

    await tester.tap(find.text('金'));
    await tester.pumpAndSettle();

    expect(find.text('Kunyomi'), findsOneWidget);
    expect(find.text('kane'), findsOneWidget);
    expect(find.text('Onyomi'), findsOneWidget);
    expect(find.text('kin'), findsOneWidget);
    expect(find.text('uang'), findsOneWidget);
    expect(find.text('お金'), findsOneWidget);
    expect(find.text('金'), findsOneWidget);
  });

  testWidgets('ukuran teks kartu mengikuti pengaturan', (tester) async {
    final store = StudyStore()..cards = [_card()];

    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();
    final normal = tester.widget<Text>(find.text('猫')).style?.fontSize;

    store.settings.flashcardTextSize = FlashcardTextSize.besar;
    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();
    final large = tester.widget<Text>(find.text('猫')).style?.fontSize;

    expect(normal, isNotNull);
    expect(large, greaterThan(normal!));
  });

  testWidgets('tombol navigasi berada di bottom bar dan berfungsi', (
    tester,
  ) async {
    final store = StudyStore()
      ..cards = [
        _card(id: 'a', front: '猫'),
        _card(id: 'b', front: '水', reading: 'みず', meaning: 'air'),
      ];
    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNothing);
    expect(find.text('Acak'), findsOneWidget);
    expect(find.text('Sebelumnya'), findsOneWidget);
    expect(find.text('Berikutnya'), findsOneWidget);

    await tester.tap(find.text('Berikutnya'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('layout tetap rapi di layar kecil 320 dp', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = StudyStore()
      ..cards = [
        _card(
          id: 'kanji-kin',
          category: CardCategory.kanji,
          front: '金',
          reading: 'kin / kane',
          meaning: 'uang',
          example: 'お金',
        ),
      ];
    await tester.pumpWidget(_app(store, category: CardCategory.kanji));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sebelumnya'), findsOneWidget);
    expect(find.text('Berikutnya'), findsOneWidget);

    await tester.tap(find.text('金'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('uang'), findsOneWidget);
  });

  testWidgets('sisi belakang kotoba hanya menampilkan arti', (tester) async {
    final store = StudyStore()
      ..cards = [
        _card(front: '猫', reading: 'ねこ', meaning: 'kucing', example: '猫がいます。'),
      ];
    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();

    await tester.tap(find.text('猫'));
    await tester.pumpAndSettle();

    expect(find.text('kucing'), findsOneWidget);
    expect(find.text('ねこ'), findsNothing);
    expect(find.text('猫がいます。'), findsNothing);
    expect(find.text('Cara baca'), findsNothing);
    expect(find.text('猫'), findsNothing);
  });

  testWidgets('menekan Acak tidak menampilkan SnackBar', (tester) async {
    final store = StudyStore()..cards = [_card()];
    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acak'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Urutan diacak'), findsNothing);
  });

  testWidgets('menandai hafal melepas tanda susah', (tester) async {
    final file = File(
      '${Directory.systemTemp.path}/jpnarabu-flashcard-test.json',
    );
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final store = StudyStore(storageFile: file)
      ..cards = [
        _card(id: 'a', front: '猫'),
        _card(id: 'b', front: '水', reading: 'みず', meaning: 'air'),
      ];
    store.progressFor('a').difficult = true;

    await tester.pumpWidget(_app(store, category: CardCategory.kotoba));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Susah'));
    await tester.pumpAndSettle();
    expect(find.text('猫'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sudah hafal'));
    await tester.pumpAndSettle();

    expect(store.progressFor('a').difficult, isFalse);
    expect(store.progressFor('a').memorized, isTrue);
    expect(find.text('Belum ada kartu pada filter ini.'), findsOneWidget);
  });

  testWidgets('tombol edit kartu langsung mengedit kartu aktif', (tester) async {
    final store = _MemoryStudyStore()..cards = [_card(id: 'a', front: '猫')];
    await tester.pumpWidget(_appWithEditor(store));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit kartu'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit kartu'));
    await tester.pumpAndSettle();

    expect(find.byType(CardEditorPage), findsOneWidget);
    expect(find.text('Edit kartu'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '変更');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(store.cardById('a')?.front, '変更');

    expect(find.byType(CardEditorPage), findsNothing);
    expect(find.byType(FlashcardPage), findsOneWidget);
    expect(find.text('変更'), findsOneWidget);
  });

  testWidgets('smoke: tema baru membuka dan membalik kartu tanpa exception', (
    tester,
  ) async {
    final store = StudyStore()..cards = [_card()];
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.AppTheme.dark(),
        home: FlashcardPage(store: store, category: CardCategory.kotoba),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('猫'));
    await tester.pumpAndSettle();

    expect(find.text('kucing'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('kucing'));
    await tester.pumpAndSettle();

    expect(find.text('猫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
