import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onCompleted, super.key});
  final ValueChanged<String> onCompleted;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Selamat datang')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mulai belajar bahasa Jepang',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text('Siapkan perjalanan belajar Anda melalui JPNarabu.'),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLength: 20,
                decoration: const InputDecoration(labelText: 'Nama panggilan'),
                onChanged: (_) => setState(() {}),
              ),
              PrimaryButton(onPressed: _finish, label: 'Mulai'),
            ],
          ),
        ),
      ),
    ),
  );
}
