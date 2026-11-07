import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/repositories/onboarding_repository.dart';
import 'data/repositories/study_store.dart';
import 'domain/models/card_models.dart' as models;
import 'presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  StudyStore? _store;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final store = StudyStore();
    await Future.wait([
      store.load(),
      Future<void>.delayed(const Duration(milliseconds: 1000)),
    ]);
    if (!mounted) return;
    setState(() => _store = store);
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store != null) return MyApp(store: store);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RiLearn',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.onboardingRepository, this.store});

  final OnboardingRepository? onboardingRepository;
  final StudyStore? store;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final OnboardingRepository _onboardingRepository =
      widget.onboardingRepository ?? InMemoryOnboardingRepository();
  late final StudyStore _store = widget.store ?? StudyStore();
  late final ThemeController _themeController = ThemeController(
    mode: _store.settings.theme == models.AppTheme.dark
        ? ThemeMode.dark
        : ThemeMode.light,
  );

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) => MaterialApp(
        title: 'RiLearn',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeController.mode,
        themeAnimationDuration: const Duration(milliseconds: 250),
        themeAnimationCurve: Curves.easeOutCubic,
        initialRoute:
            _onboardingRepository.isCompleted ||
                _store.settings.nickname != null
            ? AppRoutes.dashboard
            : AppRoutes.onboarding,
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
          settings,
          _onboardingRepository,
          _themeController,
          _store,
        ),
      ),
    );
  }
}
