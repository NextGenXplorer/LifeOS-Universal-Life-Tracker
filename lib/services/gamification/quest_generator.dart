import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/gamification/quest.dart';
import 'package:uuid/uuid.dart';

class QuestGenerator {
  static const _uuid = Uuid();
  static final _random = Random();

  static final List<Map<String, dynamic>> _questTemplates = [
    {'title': 'Complete 3 Habits', 'description': 'Finish three habits today', 'quest_type': 'habit_completion', 'target_value': 3, 'xp_reward': 30, 'coin_reward': 10},
    {'title': 'Complete 5 Tasks', 'description': 'Finish five tasks today', 'quest_type': 'task_completion', 'target_value': 5, 'xp_reward': 50, 'coin_reward': 15},
    {'title': 'Log an Expense', 'description': 'Track your spending', 'quest_type': 'expense_log', 'target_value': 1, 'xp_reward': 10, 'coin_reward': 5},
    {'title': 'Stay Focused', 'description': 'Complete 2 hours of focused work', 'quest_type': 'focus_time', 'target_value': 120, 'xp_reward': 40, 'coin_reward': 10},
    {'title': 'Early Bird', 'description': 'Complete a habit before 9 AM', 'quest_type': 'early_completion', 'target_value': 1, 'xp_reward': 25, 'coin_reward': 10},
    {'title': 'Consistency King', 'description': 'Maintain your streak', 'quest_type': 'streak_maintain', 'target_value': 1, 'xp_reward': 20, 'coin_reward': 5},
    {'title': 'Task Master', 'description': 'Complete 10 tasks this week', 'quest_type': 'weekly_tasks', 'target_value': 10, 'xp_reward': 100, 'coin_reward': 30},
    {'title': 'Habit Builder', 'description': 'Complete all daily habits', 'quest_type': 'all_habits', 'target_value': 1, 'xp_reward': 75, 'coin_reward': 25},
  ];

  static Future<List<DailyQuest>> generateDailyQuests() async {
    // Clean up expired quests
    await _cleanupExpiredQuests();

    // Check if we already have quests for today
    final existingQuests = await _getTodayQuests();
    if (existingQuests.isNotEmpty) {
      return existingQuests;
    }

    // Generate new quests
    final shuffled = List<Map<String, dynamic>>.from(_questTemplates)..shuffle(_random);
    final selected = shuffled.take(3).toList();

    final quests = <DailyQuest>[];
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    for (final template in selected) {
      final quest = DailyQuest(
        id: _uuid.v4(),
        title: template['title'] as String,
        description: template['description'] as String,
        questType: template['quest_type'] as String,
        targetValue: template['target_value'] as int,
        xpReward: template['xp_reward'] as int,
        coinReward: template['coin_reward'] as int,
        expiresAt: endOfDay,
      );

      await DatabaseService.insert(DatabaseConstants.dailyQuestsTable, quest.toMap());
      
      // Create user quest tracking
      final userQuest = UserQuest(
        id: _uuid.v4(),
        questId: quest.id,
      );
      await DatabaseService.insert(DatabaseConstants.userQuestsTable, userQuest.toMap());

      quests.add(quest);
    }

    return quests;
  }

  static Future<void> _cleanupExpiredQuests() async {
    final now = DateTime.now().toIso8601String();
    await DatabaseService.delete(
      DatabaseConstants.dailyQuestsTable,
      where: 'expires_at < ?',
      whereArgs: [now],
    );
    await DatabaseService.delete(
      DatabaseConstants.userQuestsTable,
      where: 'quest_id NOT IN (SELECT id FROM ${DatabaseConstants.dailyQuestsTable})',
    );
  }

  static Future<List<DailyQuest>> _getTodayQuests() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final results = await DatabaseService.query(
      DatabaseConstants.dailyQuestsTable,
      where: 'expires_at >= ? AND expires_at <= ?',
      whereArgs: [startOfDay, endOfDay],
    );

    return results.map((map) => DailyQuest.fromMap(map)).toList();
  }

  static Future<List<UserQuest>> getUserQuestsWithDetails() async {
    final quests = await _getTodayQuests();
    final List<UserQuest> userQuests = [];

    for (final quest in quests) {
      final results = await DatabaseService.query(
        DatabaseConstants.userQuestsTable,
        where: 'quest_id = ?',
        whereArgs: [quest.id],
      );

      if (results.isNotEmpty) {
        userQuests.add(UserQuest.fromMap(results.first, quest: quest));
      } else {
        userQuests.add(UserQuest(questId: quest.id, quest: quest));
      }
    }

    return userQuests;
  }

  static Future<UserQuest> updateQuestProgress(String questId, int progress) async {
    final results = await DatabaseService.query(
      DatabaseConstants.userQuestsTable,
      where: 'quest_id = ?',
      whereArgs: [questId],
    );

    if (results.isEmpty) {
      throw Exception('Quest not found');
    }

    final questResult = await DatabaseService.query(
      DatabaseConstants.dailyQuestsTable,
      where: 'id = ?',
      whereArgs: [questId],
    );

    final quest = questResult.isNotEmpty ? DailyQuest.fromMap(questResult.first) : null;
    var userQuest = UserQuest.fromMap(results.first, quest: quest);

    userQuest = userQuest.copyWith(progress: progress);

    await DatabaseService.update(
      DatabaseConstants.userQuestsTable,
      userQuest.toMap(),
      where: 'id = ?',
      whereArgs: [userQuest.id],
    );

    // Check if quest is complete
    if (quest != null && progress >= quest.targetValue && !userQuest.completed) {
      return await completeQuest(questId);
    }

    return userQuest;
  }

  static Future<UserQuest> completeQuest(String questId) async {
    final results = await DatabaseService.query(
      DatabaseConstants.userQuestsTable,
      where: 'quest_id = ?',
      whereArgs: [questId],
    );

    if (results.isEmpty) {
      throw Exception('Quest not found');
    }

    final questResult = await DatabaseService.query(
      DatabaseConstants.dailyQuestsTable,
      where: 'id = ?',
      whereArgs: [questId],
    );

    final quest = questResult.isNotEmpty ? DailyQuest.fromMap(questResult.first) : null;
    var userQuest = UserQuest.fromMap(results.first, quest: quest);

    userQuest = userQuest.copyWith(
      completed: true,
      completedAt: DateTime.now(),
      progress: quest?.targetValue ?? userQuest.progress,
    );

    await DatabaseService.update(
      DatabaseConstants.userQuestsTable,
      userQuest.toMap(),
      where: 'id = ?',
      whereArgs: [userQuest.id],
    );

    return userQuest;
  }

  static Future<int> getCompletedQuestsCount() async {
    final results = await DatabaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.userQuestsTable} WHERE completed = 1',
    );
    return results.first['count'] as int? ?? 0;
  }
}
