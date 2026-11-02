import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../widgets/deck_options_button.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({required this.store, super.key});
  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, child) {
        final palette = AppPalette.of(context);
        final textTheme = Theme.of(context).textTheme;
        final decks = store.visibleDecks;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar deck'),
            actions: [
              IconButton(
                tooltip: 'Impor CSV',
                icon: const Icon(Icons.upload_file),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.importCsv),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (decks.isEmpty)
                AppCard(
                  child: Text(
                    'Belum ada kategori. Impor CSV untuk mulai menghafal.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              for (final deck in decks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      title: Text(deck.name),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${store.cardsForDeck(deck).length} kartu',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DeckOptionsButton(store: store, deck: deck),
                          Icon(
                            Icons.chevron_right,
                            color: palette.textSecondary,
                          ),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.flashcard,
                        arguments: {
                          'category': deck.category,
                          'level': deck.level,
                          'deckId': deck.id,
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
