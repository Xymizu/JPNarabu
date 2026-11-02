import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({required this.store, super.key});
  final StudyStore store;
  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _controller = TextEditingController();
  String? message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final backup = BackupData(
      exportedAt: DateTime.now(),
      settings: widget.store.settings,
      progress: widget.store.progress.values.toList(),
      streak: widget.store.streak,
      history: widget.store.history,
    );
    _controller.text = backup.encode();
    await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan backup RiLearn',
      fileName: 'jpnarabu-backup.json',
      bytes: utf8.encode(_controller.text),
    );
    widget.store.lastBackupAt = backup.exportedAt;
    await widget.store.save();
    setState(() => message = 'Backup dibuat. Salin JSON ini ke file lokal.');
  }

  Future<void> _pickBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result?.files.single.bytes == null) return;
    _controller.text = utf8.decode(result!.files.single.bytes!);
    setState(() => message = 'File backup siap direstore.');
  }

  Future<void> _restore() async {
    try {
      final backup = BackupData.fromJson(
        jsonDecode(_controller.text) as Map<String, dynamic>,
      );
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Timpa data saat ini?'),
          content: Text(
            'Backup dari ${backup.exportedAt.toLocal()} akan diterapkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Timpa'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      final known = widget.store.cards.map((card) => card.id).toSet();
      final ignored = backup.progress
          .where((item) => !known.contains(item.cardId))
          .length;
      await widget.store.applyBackup(backup);
      setState(
        () => message =
            'Restore berhasil. $ignored ID kartu tidak dikenal diabaikan.',
      );
    } on FormatException catch (error) {
      setState(() => message = 'Backup ditolak: ${error.message}');
    } on Object {
      setState(
        () => message = 'Backup ditolak karena format file tidak valid.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final rejected = message?.contains('ditolak') ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Backup dan restore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.schedule, color: palette.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Backup terakhir: '
                    '${widget.store.lastBackupAt?.toLocal() ?? 'Belum ada'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
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
                  child: FilledButton(
                    onPressed: _export,
                    child: const Text('Buat backup JSON'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _pickBackup,
                    child: const Text('Pilih file backup'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data backup', style: textTheme.titleSmall),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  minLines: 8,
                  maxLines: 16,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(labelText: 'JSON backup'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.warning,
                      side: BorderSide(
                        color: palette.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    onPressed: _restore,
                    child: const Text('Restore (Timpa)'),
                  ),
                ),
              ],
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            AppCard(
              variant: AppCardVariant.inset,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    rejected ? Icons.error_outline : Icons.check_circle_outline,
                    color: rejected ? palette.danger : palette.success,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message!,
                      style: textTheme.bodySmall?.copyWith(
                        color: rejected
                            ? palette.danger
                            : palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
