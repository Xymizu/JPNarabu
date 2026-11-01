import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/card_models.dart';

class StudyStore {
  StudyStore({this.storageFile});

  final File? storageFile;
  List<StudyCard> cards = [];
  final Map<String, CardProgress> progress = {};
  UserSettings settings = UserSettings();
  Streak streak = Streak();
  final List<DailyLog> history = [];
  DateTime? lastBackupAt;

  Future<void> load() async {
    final rawCards = await rootBundle.loadString('assets/data/cards.json');
    cards = (jsonDecode(rawCards) as List<dynamic>)
        .map((item) => StudyCard.fromJson(item as Map<String, dynamic>))
        .toList();
    final file =
        storageFile ??
        File(
          '${(await getApplicationDocumentsDirectory()).path}/jpnarabu.json',
        );
    if (!await file.exists()) return;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    settings = UserSettings.fromJson(data['settings'] as Map<String, dynamic>);
    streak = Streak.fromJson(data['streak'] as Map<String, dynamic>);
    progress
      ..clear()
      ..addEntries(
        (data['progress'] as List<dynamic>)
            .map((item) => CardProgress.fromJson(item as Map<String, dynamic>))
            .map((item) => MapEntry(item.cardId, item)),
      );
    history
      ..clear()
      ..addAll(
        (data['history'] as List<dynamic>).map(
          (item) => DailyLog.fromJson(item as Map<String, dynamic>),
        ),
      );
    lastBackupAt = data['lastBackupAt'] == null
        ? null
        : DateTime.parse(data['lastBackupAt'] as String);
  }

  Future<void> save() async {
    final file =
        storageFile ??
        File(
          '${(await getApplicationDocumentsDirectory()).path}/jpnarabu.json',
        );
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      jsonEncode({
        'settings': settings.toJson(),
        'progress': progress.values.map((item) => item.toJson()).toList(),
        'streak': streak.toJson(),
        'history': history.map((item) => item.toJson()).toList(),
        'lastBackupAt': lastBackupAt?.toIso8601String(),
      }),
    );
    await temp.rename(file.path);
  }

  CardProgress progressFor(String cardId) =>
      progress.putIfAbsent(cardId, () => CardProgress(cardId: cardId));

  List<StudyCard> deck(CardCategory category, CardLevel level) => cards
      .where((card) => card.category == category && card.level == level)
      .toList();

  void recordCard(StudyCard card) {
    final item = progressFor(card.id);
    item.timesSeen++;
    item.lastSeen = DateTime.now();
    _recordActivity(cards: 1);
  }

  void recordQuestion() => _recordActivity(questions: 1);

  void _recordActivity({int cards = 0, int questions = 0}) {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final log = history.firstWhere(
      (item) => item.date == key,
      orElse: () {
        final value = DailyLog(date: key);
        history.add(value);
        return value;
      },
    );
    log.cards += cards;
    log.questions += questions;
    _updateStreak(key);
  }

  void _updateStreak(DateTime today) {
    final target = settings.dailyTarget;
    final log = history.firstWhere((item) => item.date == today);
    if (log.total < target) return;
    if (streak.lastCompleted == today) return;
    final yesterday = today.subtract(const Duration(days: 1));
    streak.current = streak.lastCompleted == yesterday ? streak.current + 1 : 1;
    streak.longest = streak.current > streak.longest
        ? streak.current
        : streak.longest;
    streak.lastCompleted = today;
  }

  int activityToday() {
    final today = DateTime.now();
    return history
        .where(
          (item) =>
              item.date.year == today.year &&
              item.date.month == today.month &&
              item.date.day == today.day,
        )
        .fold(0, (sum, item) => sum + item.total);
  }

  Future<void> applyBackup(BackupData backup) async {
    final known = cards.map((card) => card.id).toSet();
    progress
      ..clear()
      ..addEntries(
        backup.progress
            .where((item) => known.contains(item.cardId))
            .map((item) => MapEntry(item.cardId, item)),
      );
    settings = backup.settings;
    streak = backup.streak;
    history
      ..clear()
      ..addAll(backup.history);
    lastBackupAt = backup.exportedAt;
    await save();
  }

  Future<void> reset({CardCategory? category, CardLevel? level}) async {
    final ids = cards
        .where(
          (card) =>
              category == null ||
              (card.category == category &&
                  (level == null || card.level == level)),
        )
        .map((card) => card.id)
        .toSet();
    progress.removeWhere((key, _) => ids.contains(key));
    await save();
  }
}
