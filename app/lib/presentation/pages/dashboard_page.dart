import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';
import '../widgets/deck_options_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.store, this.nickname, super.key});

  final StudyStore store;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, child) {
        final palette = AppPalette.of(context);
        final textTheme = Theme.of(context).textTheme;
        final visibleCards = store.visibleCards;
        final memorized = store.memorizedCountFor(visibleCards);
        final percent = visibleCards.isEmpty
            ? 0
            : (memorized * 100 ~/ visibleCards.length);
        final name = nickname ?? store.settings.nickname;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) SystemNavigator.pop();
          },
          child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(name == null ? 'Dashboard' : 'Halo, $name'),
          actions: [
            AppIconButton(
              icon: Icons.settings_outlined,
              label: 'Buka pengaturan',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progres hafalan',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$percent%', style: textTheme.displayMedium),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'dari ${visibleCards.length} kartu',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent / 100),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: palette.surface2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$memorized kartu sudah hafal',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.methodGuide),
                child: const Text('Lupa method belajar? Klik disini'),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Streak',
                    value: '${store.streak.current} hari',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    label: 'Target hari ini',
                    value:
                        '${store.activityToday()} / ${store.settings.dailyTarget}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Pilihan hafalan', style: textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.importCsv),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Impor CSV'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (store.visibleDecks.isEmpty)
              AppCard(
                child: Text(
                  'Belum ada kategori. Impor CSV untuk mulai menghafal.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            for (final deck in store.visibleDecks)
              _DeckTile(
                store: store,
                deck: deck,
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
          ],
        ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(value, style: textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.store,
    required this.deck,
    required this.onTap,
  });
  final StudyStore store;
  final StudyDeck deck;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final cards = store.cardsForDeck(deck);
    final done = store.memorizedCountFor(cards);
    final percent = cards.isEmpty ? 0 : done * 100 ~/ cards.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          title: Text(deck.name),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent% · $done/${cards.length} kartu',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: cards.isEmpty ? 0 : done / cards.length,
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      backgroundColor: palette.surface2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DeckOptionsButton(store: store, deck: deck),
              Icon(Icons.chevron_right, color: palette.textSecondary),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
