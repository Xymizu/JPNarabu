import 'package:flutter/material.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';
import '../theme/theme_controller.dart';
import '../../presentation/pages/backup_restore_page.dart';
import '../../presentation/pages/card_editor_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/deck_editor_page.dart';
import '../../presentation/pages/decks_page.dart';
import '../../presentation/pages/flashcard_page.dart';
import '../../presentation/pages/import_csv_page.dart';
import '../../presentation/pages/method_guide_page.dart';
import '../../presentation/pages/onboarding_page.dart';
import '../../presentation/pages/placeholder_page.dart';
import '../../presentation/pages/settings_page.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const decks = '/decks';
  static const flashcard = '/flashcard';
  static const settings = '/settings';
  static const backupRestore = '/backup-restore';
  static const methodGuide = '/method-guide';
  static const importCsv = '/import-csv';
  static const deckEditor = '/deck-editor';
  static const cardEditor = '/card-editor';
}

abstract final class AppRouter {
  static Route<void>? onGenerateRoute(
    RouteSettings settings,
    OnboardingRepository onboardingRepository,
    ThemeController themeController,
    StudyStore store,
  ) {
    final builder = switch (settings.name) {
      AppRoutes.onboarding => (_) => OnboardingPage(
        onCompleted: (nickname) {
          onboardingRepository.complete();
          store.settings.nickname = nickname;
          store.save();
        },
      ),
      AppRoutes.dashboard => (_) => DashboardPage(
        store: store,
        nickname: settings.arguments as String?,
      ),
      AppRoutes.decks => (_) => DecksPage(store: store),
      AppRoutes.flashcard => (_) => FlashcardPage(
        store: store,
        category: (settings.arguments as Map?)?['category'] as CardCategory?,
        level: (settings.arguments as Map?)?['level'] as CardLevel?,
        deckId: (settings.arguments as Map?)?['deckId'] as String?,
      ),
      AppRoutes.settings => (_) => SettingsPage(
        store: store,
        themeController: themeController,
      ),
      AppRoutes.backupRestore => (_) => BackupRestorePage(store: store),
      AppRoutes.methodGuide => (_) => const MethodGuidePage(),
      AppRoutes.importCsv => (_) => ImportCsvPage(store: store),
      AppRoutes.deckEditor => (_) => DeckEditorPage(
        store: store,
        deckId: (settings.arguments as Map?)?['deckId'] as String?,
      ),
      AppRoutes.cardEditor => (_) => CardEditorPage(
        store: store,
        deckId: (settings.arguments as Map?)?['deckId'] as String?,
        cardId: (settings.arguments as Map?)?['cardId'] as String?,
      ),
      _ => (_) => const PlaceholderPage(
        title: 'Halaman tidak ditemukan',
        description: 'Rute yang diminta tidak tersedia.',
      ),
    };

    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }
}
