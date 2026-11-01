import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../data/repositories/study_store.dart';
import '../../domain/models/card_models.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({required this.store, this.category, this.level, super.key});
  final StudyStore store;
  final CardCategory? category;
  final CardLevel? level;
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int index = 0;
  int score = 0;
  String? selected;
  late final List<StudyCard> questions;

  @override
  void initState() {
    super.initState();
    questions = widget.store.deck(
      widget.category ?? CardCategory.hiragana,
      widget.level ?? CardLevel.basic,
    )..shuffle(Random());
    if (questions.length > 10) {
      questions.removeRange(10, questions.length);
    }
  }

  void _answer(String answer) {
    if (selected != null) return;
    final correct = answer == questions[index].meaning;
    setState(() {
      selected = answer;
      if (correct) score++;
    });
    widget.store.recordQuestion();
    widget.store.save();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.length < 4) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis')),
        body: const Center(
          child: Text('Kuis membutuhkan minimal 4 kartu pada deck ini.'),
        ),
      );
    }
    if (index >= questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil kuis')),
        body: Center(child: Text('Skor Anda: $score / ${questions.length}')),
      );
    }
    final question = questions[index];
    final options = <String>{
      question.meaning,
      ...widget.store.cards
          .where(
            (card) =>
                card.category == question.category && card.id != question.id,
          )
          .map((card) => card.meaning),
    }.toList()..shuffle(Random());
    final visibleOptions = options.take(4).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Kuis ${index + 1}/${questions.length}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                Text(question.front, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                const Text('Pilih arti yang benar'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final option in visibleOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => _answer(option),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(option),
                ),
              ),
            ),
          if (selected != null)
            FilledButton(
              onPressed: () => setState(() {
                index++;
                selected = null;
              }),
              child: Text(
                index == questions.length - 1 ? 'Lihat hasil' : 'Berikutnya',
              ),
            ),
        ],
      ),
    );
  }
}
