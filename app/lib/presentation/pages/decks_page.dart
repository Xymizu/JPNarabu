import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({required this.store, super.key});
  final StudyStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar deck')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final deck in _decks)
          ListTile(
            title: Text(deck.label),
            subtitle: Text(
              '${store.deck(deck.category, deck.level).length} kartu',
            ),
            trailing: const Icon(Icons.chevron_right),
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
