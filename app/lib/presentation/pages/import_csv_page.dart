import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/study_store.dart';
import '../../data/sources/csv_card_loader.dart';
import '../../domain/models/card_models.dart';

class ImportCsvPage extends StatefulWidget {
  const ImportCsvPage({required this.store, super.key});

  final StudyStore store;

  @override
  State<ImportCsvPage> createState() => _ImportCsvPageState();
}

class _ImportCsvPageState extends State<ImportCsvPage> {
  final _name = TextEditingController();
  CardCategory _category = CardCategory.kotoba;
  CardLevel _level = CardLevel.n5;
  String? _fileName;
  String? _content;
  List<StudyCard> _preview = [];
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      _showError('File tidak bisa dibaca. Coba pilih file lain.');
      return;
    }
    if (bytes.length > 5 * 1024 * 1024) {
      _showError('Ukuran file melebihi 5 MB. Pecah file lalu impor ulang.');
      return;
    }
    try {
      final content = utf8.decode(bytes);
      setState(() {
        _fileName = file.name;
        _content = content;
        _preview = [];
        _error = null;
      });
      _previewCsv();
    } on FormatException {
      _showError('File harus berformat teks UTF-8.');
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _preview = [];
    });
  }

  void _previewCsv() {
    final content = _content;
    if (content == null) {
      _showError('Pilih file CSV terlebih dahulu.');
      return;
    }
    if (content.trim().isEmpty) {
      _showError('File CSV tidak berisi data.');
      return;
    }
    try {
      final cards = const CsvCardLoader().parse(
        content: content,
        category: _category,
        level: _level,
        sourceName: _fileName ?? 'file.csv',
      );
      setState(() {
        _preview = cards;
        _error = null;
      });
    } on FormatException catch (error) {
      _showError(error.message);
    }
  }

  Future<void> _import() async {
    final name = _name.text.trim();
    final content = _content;
    if (content == null) {
      _showError('Pilih file CSV terlebih dahulu.');
      return;
    }
    if (name.isEmpty) {
      _showError('Nama kategori wajib diisi.');
      return;
    }
    if (_preview.isEmpty) {
      _previewCsv();
      if (_preview.isEmpty) return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impor kategori?'),
        content: Text(
          'Kategori "$name" akan dibuat dengan ${_preview.length} kartu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Impor'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final deck = await widget.store.importDeck(
        name: name,
        category: _category,
        level: _level,
        csvContent: content,
        sourceName: _fileName ?? 'file.csv',
      );
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Kategori "${deck.name}" berhasil diimpor '
            '(${_preview.length} kartu).',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Import gagal. Periksa file lalu coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Impor CSV')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File CSV', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? 'Belum ada file dipilih.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pilih file CSV'),
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
                TextField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Nama kategori',
                    hintText: 'Contoh: Kotoba Bab 1',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<CardCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: const [
                    DropdownMenuItem(
                      value: CardCategory.kotoba,
                      child: Text('Kotoba'),
                    ),
                    DropdownMenuItem(
                      value: CardCategory.kanji,
                      child: Text('Kanji'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                    if (_content != null) _previewCsv();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CardLevel>(
                  initialValue: _level,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: const [
                    DropdownMenuItem(value: CardLevel.n5, child: Text('N5')),
                    DropdownMenuItem(value: CardLevel.n4, child: Text('N4')),
                    DropdownMenuItem(value: CardLevel.n3, child: Text('N3')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _level = value);
                    if (_content != null) _previewCsv();
                  },
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AppCard(
              variant: AppCardVariant.inset,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: palette.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_preview.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_preview.length} kartu terdeteksi',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final card in _preview.take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        [
                          card.front,
                          if (card.reading.isNotEmpty) card.reading,
                          card.meaning,
                        ].join(' · '),
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  if (_preview.length > 5)
                    Text(
                      'dan ${_preview.length - 5} kartu lainnya…',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: _busy ? null : _import,
            label: _busy ? 'Mengimpor…' : 'Impor',
          ),
          const SizedBox(height: 16),
          Text(
            'Format CSV sama seperti file bawaan: dua kolom tanpa header. '
            'Kotoba: kata (kanji),arti. Kanji: kanji,bacaan — arti. '
            'Simpan file sebagai UTF-8.',
            style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
