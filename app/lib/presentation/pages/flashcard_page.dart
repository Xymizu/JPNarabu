import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({
    required this.store,
    this.category,
    this.level,
    super.key,
  });
  final StudyStore store;
  final CardCategory? category;
  final CardLevel? level;
  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  CardFilter filter = CardFilter.all;
  bool random = true;
  bool flipped = false;
  int index = 0;
  late List<StudyCard> cards;

  CardCategory get category => widget.category ?? CardCategory.hiragana;
  CardLevel get level => widget.level ?? CardLevel.basic;

  @override
  void initState() {
    super.initState();
    filter =
        widget.store.settings.lastFilters['${category.name}-${level.name}'] ??
        CardFilter.all;
    _refresh();
  }

  void _refresh() {
    final all = widget.store.deck(category, level);
    cards = all.where((card) {
      final item = widget.store.progressFor(card.id);
      return switch (filter) {
        CardFilter.all => true,
        CardFilter.unseen => !item.memorized,
        CardFilter.memorized => item.memorized,
        CardFilter.difficult => item.difficult,
      };
    }).toList();
    if (random) cards.shuffle(Random());
    index = 0;
    flipped = false;
  }

  void _setFilter(CardFilter value) {
    setState(() {
      filter = value;
      widget.store.settings.lastFilters['${category.name}-${level.name}'] =
          value;
      _refresh();
    });
    widget.store.save();
  }

  void _mark({bool? memorized, bool? difficult}) {
    if (cards.isEmpty) return;
    final item = widget.store.progressFor(cards[index].id);
    setState(() {
      if (memorized != null) item.memorized = memorized;
      if (difficult != null) item.difficult = difficult;
    });
    widget.store.recordCard(cards[index]);
    widget.store.save();
  }

  @override
  Widget build(BuildContext context) {
    final current = cards.isEmpty ? null : cards[index];
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} ${level.name}'),
        actions: [
          Switch(
            value: random,
            onChanged: (value) => setState(() {
              random = value;
              _refresh();
            }),
          ),
          Semantics(label: 'Acak', child: const Icon(Icons.shuffle)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final item in CardFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(item)),
                  selected: filter == item,
                  onSelected: (_) => _setFilter(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (current == null)
            AppCard(child: const Text('Belum ada kartu pada filter ini.'))
          else ...[
            Text('${index + 1} / ${cards.length}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => flipped = !flipped),
              child: AppCard(
                color: AppColors.periwinkle,
                child: SizedBox(
                  height: 260,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: flipped
                          ? Column(
                              key: const ValueKey('back'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  current.meaning,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (widget.store.settings.showOnyomi &&
                                    current.reading.isNotEmpty)
                                  Text(
                                    current.reading,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                    ),
                                  ),
                                if (widget.store.settings.showExamples &&
                                    current.example.isNotEmpty)
                                  Text(
                                    current.example,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                    ),
                                  ),
                              ],
                            )
                          : Text(
                              current.front,
                              key: const ValueKey('front'),
                              style: const TextStyle(
                                fontSize: 72,
                                color: AppColors.ink,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _mark(
                      difficult: !widget.store
                          .progressFor(current.id)
                          .difficult,
                    ),
                    child: const Text('Susah'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _mark(
                      memorized: !widget.store
                          .progressFor(current.id)
                          .memorized,
                    ),
                    child: Text(
                      widget.store.progressFor(current.id).memorized
                          ? 'Batalkan hafal'
                          : 'Sudah hafal',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: index == 0
                      ? null
                      : () => setState(() {
                          index--;
                          flipped = false;
                        }),
                  child: const Text('Sebelumnya'),
                ),
                TextButton(
                  onPressed: index == cards.length - 1
                      ? null
                      : () => setState(() {
                          index++;
                          flipped = false;
                        }),
                  child: const Text('Berikutnya'),
                ),
              ],
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.quiz,
                arguments: {'category': category, 'level': level},
              ),
              child: const Text('Mulai kuis'),
            ),
          ],
        ],
      ),
    );
  }

  String _filterLabel(CardFilter value) => switch (value) {
    CardFilter.all => 'Semua',
    CardFilter.unseen => 'Belum hafal',
    CardFilter.memorized => 'Sudah hafal',
    CardFilter.difficult => 'Susah',
  };
}
