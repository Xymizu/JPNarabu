import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.store,
    required this.themeController,
    super.key,
  });
  final StudyStore store;
  final ThemeController themeController;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.store.settings.nickname,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final count = widget.store.progress.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset semua progres?'),
        content: Text(
          '$count kartu akan terdampak. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.reset();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengaturan')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _name,
          maxLength: 20,
          decoration: const InputDecoration(labelText: 'Nama panggilan'),
          onSubmitted: (value) {
            widget.store.settings.nickname = value.trim();
            widget.store.save();
          },
        ),
        ListenableBuilder(
          listenable: widget.themeController,
          builder: (context, child) => SwitchListTile(
            title: const Text('Gunakan tema gelap'),
            value: widget.themeController.isDark,
            onChanged: (value) {
              widget.themeController.setMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
              widget.store.settings.theme = value
                  ? AppTheme.dark
                  : AppTheme.light;
              widget.store.save();
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Tampilkan onyomi'),
          value: widget.store.settings.showOnyomi,
          onChanged: (value) => setState(() {
            widget.store.settings.showOnyomi = value;
            widget.store.save();
          }),
        ),
        SwitchListTile(
          title: const Text('Tampilkan contoh kata'),
          value: widget.store.settings.showExamples,
          onChanged: (value) => setState(() {
            widget.store.settings.showExamples = value;
            widget.store.save();
          }),
        ),
        DropdownButtonFormField<int>(
          initialValue: widget.store.settings.dailyTarget,
          decoration: const InputDecoration(labelText: 'Target harian'),
          items: [5, 10, 20, 50]
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text('$value aktivitas'),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() {
            if (value != null) widget.store.settings.dailyTarget = value;
            widget.store.save();
          }),
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.backupRestore),
          child: const Text('Backup dan restore'),
        ),
        OutlinedButton(
          onPressed: _reset,
          child: const Text('Reset semua progres'),
        ),
        const SizedBox(height: 20),
        const Text('JPNarabu · MVP offline'),
        const SizedBox(height: 8),
        const Text(
          'Sumber data pengujian: daftar kanji N4, kotoba pelajaran '
          '26–50, dan PATOKAN N3 yang diberikan secara lokal. Status '
          'lisensi belum dikonfirmasi; data ini hanya untuk testing.',
        ),
      ],
    ),
  );
}
