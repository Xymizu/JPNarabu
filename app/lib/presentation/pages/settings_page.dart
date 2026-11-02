import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart' as theme;
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_card.dart';
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
  Widget build(BuildContext context) {
    final palette = theme.AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _name,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Nama panggilan'),
              onSubmitted: (value) {
                widget.store.settings.nickname = value.trim();
                widget.store.save();
              },
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
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
                Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Tampilkan onyomi'),
                  value: widget.store.settings.showOnyomi,
                  onChanged: (value) => setState(() {
                    widget.store.settings.showOnyomi = value;
                    widget.store.save();
                  }),
                ),
                Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Tampilkan contoh kata'),
                  value: widget.store.settings.showExamples,
                  onChanged: (value) => setState(() {
                    widget.store.settings.showExamples = value;
                    widget.store.save();
                  }),
                ),
              ],
            ),
          ),
          if (widget.store.hiddenDeckIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori disembunyikan', style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.store.hiddenDeckIds.length} kategori bawaan '
                    'sedang disembunyikan.',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await widget.store.restoreHiddenDecks();
                        if (mounted) setState(() {});
                      },
                      child: const Text('Pulihkan kategori bawaan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ukuran teks flashcard', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<FlashcardTextSize>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: FlashcardTextSize.kecil,
                        label: Text('Kecil'),
                      ),
                      ButtonSegment(
                        value: FlashcardTextSize.sedang,
                        label: Text('Sedang'),
                      ),
                      ButtonSegment(
                        value: FlashcardTextSize.besar,
                        label: Text('Besar'),
                      ),
                    ],
                    selected: {widget.store.settings.flashcardTextSize},
                    onSelectionChanged: (selection) => setState(() {
                      widget.store.settings.flashcardTextSize = selection.first;
                      widget.store.save();
                    }),
                  ),
                ),
                const SizedBox(height: 20),
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
                    if (value != null) {
                      widget.store.settings.dailyTarget = value;
                    }
                    widget.store.save();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.backupRestore),
                    child: const Text('Backup dan restore'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.danger,
                      side: BorderSide(
                        color: palette.danger.withValues(alpha: 0.5),
                      ),
                    ),
                    onPressed: _reset,
                    child: const Text('Reset semua progres'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _AboutCard(),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final palette = theme.AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tentang aplikasi', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'RiLearn adalah aplikasi hafalan kosakata dan kanji Jepang yang '
            'bisa dipakai offline. Belajar dengan flashcard, tandai kartu '
            'yang sudah hafal atau masih susah, dan impor daftar hafalanmu '
            'sendiri lewat CSV.',
            style: textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dibuat oleh Xymizu / Arif M Fahri',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Versi 1.0.0',
            style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
