import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.store, this.nickname, super.key});

  final StudyStore store;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    final memorized = store.progress.values
        .where((item) => item.memorized)
        .length;
    final percent = store.cards.isEmpty
        ? 0
        : (memorized * 100 ~/ store.cards.length);
    final name = nickname ?? store.settings.nickname;
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null ? 'Dashboard' : 'Halo, $name'),
        actions: [
          IconButton(
            tooltip: 'Buka pengaturan',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            name == null ? 'Selamat belajar!' : 'Halo, $name',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          AppCard(
            color: AppColors.periwinkle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progres hafalan',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '$percent%',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(color: AppColors.ink),
                ),
                Text(
                  '$memorized / ${store.cards.length} kartu',
                  style: const TextStyle(color: AppColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
          Text(
            'Pilihan hafalan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          for (final deck in _decks)
            _DeckTile(
              store: store,
              deck: deck,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.flashcard,
                arguments: {'category': deck.category, 'level': deck.level},
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => AppCard(
    color: AppColors.sun,
    radius: 28,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.ink)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.store,
    required this.deck,
    required this.onTap,
  });
  final StudyStore store;
  final ({String label, CardCategory category, CardLevel level}) deck;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cards = store.deck(deck.category, deck.level);
    final done = cards
        .where((card) => store.progressFor(card.id).memorized)
        .length;
    final percent = cards.isEmpty ? 0 : done * 100 ~/ cards.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        radius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(deck.label),
          subtitle: Text('$percent% · $done/${cards.length} kartu'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

const _decks = [
  (label: 'Hiragana', category: CardCategory.hiragana, level: CardLevel.basic),
  (label: 'Katakana', category: CardCategory.katakana, level: CardLevel.basic),
  (label: 'Kanji N5', category: CardCategory.kanji, level: CardLevel.n5),
  (label: 'Kanji N4', category: CardCategory.kanji, level: CardLevel.n4),
  (label: 'Kanji N3', category: CardCategory.kanji, level: CardLevel.n3),
  (label: 'Kotoba N5', category: CardCategory.kotoba, level: CardLevel.n5),
  (label: 'Kotoba N4', category: CardCategory.kotoba, level: CardLevel.n4),
  (label: 'Kotoba N3', category: CardCategory.kotoba, level: CardLevel.n3),
];
