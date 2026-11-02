import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class DeckEditorPage extends StatefulWidget {
  const DeckEditorPage({required this.store, this.deckId, super.key});

  final StudyStore store;
  final String? deckId;

  @override
  State<DeckEditorPage> createState() => _DeckEditorPageState();
}

class _DeckEditorPageState extends State<DeckEditorPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openEditor(StudyDeck deck, StudyCard? card) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.cardEditor,
      arguments: {'deckId': deck.id, 'cardId': card?.id},
    );
  }

  Future<void> _confirmDelete(StudyDeck deck, StudyCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kartu?'),
        content: Text('Kartu "${card.front}" akan dihapus dari kategori ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.deleteCard(card);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final deck = widget.deckId == null
        ? null
        : widget.store.deckById(widget.deckId!);
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelola kartu')),
        body: const Center(child: Text('Kategori tidak ditemukan.')),
      );
    }
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, child) {
        final query = _query.trim().toLowerCase();
        final cards = widget.store.cardsForDeck(deck).where((card) {
          if (query.isEmpty) return true;
          return card.front.toLowerCase().contains(query) ||
              card.reading.toLowerCase().contains(query) ||
              card.meaning.toLowerCase().contains(query);
        }).toList();
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kelola "${deck.name}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                Text(
                  '${cards.length} kartu',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(deck, null),
            icon: const Icon(Icons.add),
            label: const Text('Tambah kartu'),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          labelText: 'Cari kartu',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${cards.length} kartu',
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: cards.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  query.isEmpty
                                      ? 'Belum ada kartu di kategori ini.'
                                      : 'Kartu tidak ditemukan.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => _openEditor(deck, null),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah kartu'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AppCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    8,
                                    8,
                                  ),
                                  title: Text(
                                    card.front,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      [
                                        if (card.reading.isNotEmpty)
                                          card.reading,
                                        card.meaning,
                                      ].join(' · '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Hapus kartu',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        _confirmDelete(deck, card),
                                  ),
                                  onTap: () => _openEditor(deck, card),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
