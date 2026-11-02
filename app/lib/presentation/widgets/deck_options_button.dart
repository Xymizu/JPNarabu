import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class DeckOptionsButton extends StatelessWidget {
  const DeckOptionsButton({
    required this.store,
    required this.deck,
    super.key,
  });

  final StudyStore store;
  final StudyDeck deck;

  Future<void> _delete(BuildContext context) async {
    final builtIn = deck.isBuiltIn;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          builtIn
              ? 'Sembunyikan kategori "${deck.name}"?'
              : 'Hapus kategori "${deck.name}"?',
        ),
        content: Text(
          builtIn
              ? 'Kategori bawaan akan disembunyikan dari daftar. '
                    'Kamu bisa memulihkannya di Pengaturan.'
              : 'Semua kartu dan progres di kategori ini akan dihapus '
                    'permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(builtIn ? 'Sembunyikan' : 'Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await store.deleteDeck(deck);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          builtIn
              ? 'Kategori "${deck.name}" disembunyikan.'
              : 'Kategori "${deck.name}" dihapus.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opsi kategori',
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.pushNamed(
            context,
            AppRoutes.deckEditor,
            arguments: {'deckId': deck.id},
          );
        } else if (value == 'delete') {
          _delete(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Kelola kartu'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 10),
              Text('Hapus kategori'),
            ],
          ),
        ),
      ],
    );
  }
}
