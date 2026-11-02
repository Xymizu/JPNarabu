import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../widgets/method_guide_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onCompleted, super.key});
  final ValueChanged<String> onCompleted;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = TextEditingController();
  int _step = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    final name = _controller.text.trim();
    if (name.isEmpty || name.length > 20) return;
    widget.onCompleted(name);
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
      arguments: name,
    );
  }

  void _next() => setState(() => _step++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _step == 0
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text(_step == 1 ? 'Cara belajar' : 'Selamat datang'),
            ),
      body: SafeArea(
        child: switch (_step) {
          0 => _buildWelcome(context),
          1 => MethodGuideView(onContinue: _next),
          _ => _buildNameForm(context),
        },
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(
                      alpha: palette.isDark ? 0.28 : 0.12,
                    ),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RiLearn',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall,
                ),
                const SizedBox(height: 36),
                PrimaryButton(onPressed: _next, label: 'Get Started'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameForm(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Siapa nama panggilanmu?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nama ini akan muncul di dashboard.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      maxLength: 20,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _finish(),
                      decoration: const InputDecoration(
                        labelText: 'Nama panggilan',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    PrimaryButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : _finish,
                      label: 'Mulai',
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _step = 1),
                      child: const Text('Lupa method belajar? Klik disini'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
