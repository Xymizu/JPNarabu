import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class CardEditorPage extends StatefulWidget {
  const CardEditorPage({
    required this.store,
    this.deckId,
    this.cardId,
    super.key,
  });

  final StudyStore store;
  final String? deckId;
  final String? cardId;

  @override
  State<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends State<CardEditorPage> {
  late final StudyCard? _original;
  late final TextEditingController _front;
  late final TextEditingController _reading;
  late final TextEditingController _meaning;
  late final TextEditingController _example;
  String? _error;
  bool _busy = false;

  StudyDeck? get _deck => widget.deckId == null
      ? null
      : widget.store.deckById(widget.deckId!);

  @override
  void initState() {
    super.initState();
    _original = widget.cardId == null
        ? null
        : widget.store.cardById(widget.cardId!);
    _front = TextEditingController(text: _original?.front ?? '');
    _reading = TextEditingController(text: _original?.reading ?? '');
    _meaning = TextEditingController(text: _original?.meaning ?? '');
    _example = TextEditingController(text: _original?.example ?? '');
  }

  @override
  void dispose() {
    _front.dispose();
    _reading.dispose();
    _meaning.dispose();
    _example.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final deck = _deck;
    if (deck == null) return;
    final front = _front.text.trim();
    final meaning = _meaning.text.trim();
    if (front.isEmpty || meaning.isEmpty) {
      setState(() => _error = 'Kata/kanji dan arti wajib diisi.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.store.saveCard(
        deck: deck,
        original: _original,
        front: front,
        reading: _reading.text,
        meaning: meaning,
        example: _example.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
        _error = 'Kartu gagal disimpan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final deck = _deck;
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kartu')),
        body: const Center(child: Text('Kategori tidak ditemukan.')),
      );
    }
    final isKanji = deck.category == CardCategory.kanji;
    return Scaffold(
      appBar: AppBar(
        title: Text(_original == null ? 'Tambah kartu' : 'Edit kartu'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _front,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isKanji ? 'Kanji' : 'Kata / kana',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reading,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isKanji ? 'Bacaan' : 'Kanji (opsional)',
                    helperText: isKanji
                        ? 'Pisahkan onyomi dan kunyomi dengan "/". '
                              'Contoh: kin / kane'
                        : null,
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _meaning,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Arti'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _example,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: isKanji
                        ? 'Contoh (opsional)'
                        : 'Contoh kalimat (opsional)',
                  ),
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
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: _busy ? null : _save,
            label: _busy ? 'Menyimpan…' : 'Simpan',
          ),
        ],
      ),
    );
  }
}
