import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpnarabu_app/data/repositories/onboarding_repository.dart';
import 'package:jpnarabu_app/data/repositories/study_store.dart';
import 'package:jpnarabu_app/main.dart';
import 'package:jpnarabu_app/presentation/pages/dashboard_page.dart';

void main() {
  testWidgets('onboarding memvalidasi nama dan membuka dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mulai belajar bahasa Jepang'), findsOneWidget);
    await tester.tap(find.text('Mulai'));
    await tester.pump();
    expect(find.text('Mulai belajar bahasa Jepang'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Fahri');
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.text('Halo, Fahri'), findsNWidgets(2));
  });

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
}
