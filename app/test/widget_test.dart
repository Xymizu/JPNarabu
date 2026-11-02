import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/data/repositories/onboarding_repository.dart';
import 'package:jpnarabu_app/data/repositories/study_store.dart';
import 'package:jpnarabu_app/domain/models/card_models.dart';
import 'package:jpnarabu_app/main.dart';
import 'package:jpnarabu_app/presentation/pages/dashboard_page.dart';

void main() {
  testWidgets(
    'onboarding menampilkan welcome, panduan, lalu membuka dashboard',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MyApp());

      expect(find.text('RiLearn'), findsOneWidget);
      expect(find.text('by Xymizu / Ri'), findsNothing);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Cara belajar'), findsOneWidget);
      expect(
        find.text('Jangan skip ini, ini method belajarnya.'),
        findsOneWidget,
      );
      expect(find.text('Pilih apa yang mau kamu hafal.'), findsOneWidget);

      await tester.tap(find.text('Mengerti, lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Siapa nama panggilanmu?'), findsOneWidget);
      expect(find.byTooltip('Kembali'), findsNothing);

      await tester.tap(find.text('Mulai'));
      await tester.pump();
      expect(find.text('Siapa nama panggilanmu?'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Fahri');
      await tester.pump();

      await tester.tap(find.text('Lupa method belajar? Klik disini'));
      await tester.pumpAndSettle();
      expect(find.text('Cara belajar'), findsOneWidget);

      await tester.tap(find.text('Mengerti, lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Siapa nama panggilanmu?'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'Fahri',
      );

      await tester.tap(find.text('Mulai'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.text('Halo, Fahri'), findsOneWidget);

      await tester.tap(find.text('Lupa method belajar? Klik disini'));
      await tester.pumpAndSettle();
      expect(find.text('Cara belajar'), findsOneWidget);
    },
  );

  testWidgets('tema dapat diubah tanpa restart aplikasi', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryOnboardingRepository()..complete();
    final store = StudyStore();
    await tester.pumpWidget(
      MyApp(onboardingRepository: repository, store: store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buka pengaturan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    expect(find.text('Gunakan tema gelap'), findsOneWidget);
  });

  testWidgets('pengaturan menampilkan tentang aplikasi dan credit', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = InMemoryOnboardingRepository()..complete();
    final store = StudyStore();
    await tester.pumpWidget(
      MyApp(onboardingRepository: repository, store: store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buka pengaturan'));
    await tester.pumpAndSettle();

    expect(find.text('Tentang aplikasi'), findsOneWidget);
    expect(find.text('Dibuat oleh Xymizu / Arif M Fahri'), findsOneWidget);
  });

  testWidgets('dashboard memperbarui progress saat store berubah', (
    WidgetTester tester,
  ) async {
    final store = StudyStore();
    store.cards = [
      const StudyCard(
        id: 'kotoba-n5-0001',
        category: CardCategory.kotoba,
        level: CardLevel.n5,
        front: '勉強',
        reading: 'べんきょう',
        romaji: 'benkyou',
        meaning: 'belajar',
        example: '',
        order: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: DashboardPage(store: store)),
    );
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 kartu sudah hafal'), findsOneWidget);

    store.progressFor(store.cards.single.id).memorized = true;
    store.notifyListeners();
    await tester.pump();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('1 kartu sudah hafal'), findsOneWidget);
  });
}
