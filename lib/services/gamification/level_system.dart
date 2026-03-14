import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/gamification/user_stats.dart';
import 'package:uuid/uuid.dart';

class LevelSystem {
  static const int maxLevel = 100;
  static const _uuid = Uuid();

  static int calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    // Exponential curve: each level requires more XP
    return ((100 * pow(level - 1, 1.8)).round());
  }

  static int calculateLevelFromXp(int totalXp) {
    int level = 1;
    while (level < maxLevel && calculateXpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  static double calculateProgressToNextLevel(int totalXp) {
    int currentLevel = calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) return 1.0;

    int xpForCurrentLevel = calculateXpForLevel(currentLevel);
    int xpForNextLevel = calculateXpForLevel(currentLevel + 1);
    int xpInCurrentLevel = totalXp - xpForCurrentLevel;
    int xpNeededForNext = xpForNextLevel - xpForCurrentLevel;

    return (xpInCurrentLevel / xpNeededForNext).clamp(0.0, 1.0);
  }

  static int xpToNextLevel(int totalXp) {
    int currentLevel = calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) return 0;
    return calculateXpForLevel(currentLevel + 1) - totalXp;
  }

  static Future<UserStats> getOrCreateUserStats() async {
    final results = await DatabaseService.query(DatabaseConstants.userStatsTable);
    
    if (results.isNotEmpty) {
      return UserStats.fromMap(results.first);
    }

    // Create new user stats
    final now = DateTime.now();
    final stats = UserStats(
      id: _uuid.v4(),
      currentLevel: 1,
      totalXp: 0,
      coins: 0,
      streakDays: 0,
      longestStreak: 0,
      createdAt: now,
      updatedAt: now,
    );

    await DatabaseService.insert(DatabaseConstants.userStatsTable, stats.toMap());
    return stats;
  }

  static Future<UserStats> addXp(int amount) async {
    final stats = await getOrCreateUserStats();
    final newTotalXp = stats.totalXp + amount;
    final newLevel = calculateLevelFromXp(newTotalXp);
    final leveledUp = newLevel > stats.currentLevel;

    final updatedStats = stats.copyWith(
      totalXp: newTotalXp,
      currentLevel: newLevel,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.update(
      DatabaseConstants.userStatsTable,
      updatedStats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );

    return updatedStats;
  }

  static Future<UserStats> addCoins(int amount) async {
    final stats = await getOrCreateUserStats();
    final updatedStats = stats.copyWith(
      coins: stats.coins + amount,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.update(
      DatabaseConstants.userStatsTable,
      updatedStats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );

    return updatedStats;
  }

  static Future<UserStats> updateStreak() async {
    final stats = await getOrCreateUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreakDays = stats.streakDays;
    int newLongestStreak = stats.longestStreak;

    if (stats.lastActivityDate != null) {
      final lastActivity = DateTime(
        stats.lastActivityDate!.year,
        stats.lastActivityDate!.month,
        stats.lastActivityDate!.day,
      );
      final difference = today.difference(lastActivity).inDays;

      if (difference == 0) {
        // Same day, no change
      } else if (difference == 1) {
        // Consecutive day, increment streak
        newStreakDays++;
      } else {
        // Streak broken, reset
        newStreakDays = 1;
      }
    } else {
      newStreakDays = 1;
    }

    if (newStreakDays > newLongestStreak) {
      newLongestStreak = newStreakDays;
    }

    final updatedStats = stats.copyWith(
      streakDays: newStreakDays,
      longestStreak: newLongestStreak,
      lastActivityDate: now,
      updatedAt: now,
    );

    await DatabaseService.update(
      DatabaseConstants.userStatsTable,
      updatedStats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );

    return updatedStats;
  }

  static Future<void> resetStreak() async {
    final stats = await getOrCreateUserStats();
    final updatedStats = stats.copyWith(
      streakDays: 0,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.update(
      DatabaseConstants.userStatsTable,
      updatedStats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  static String getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Apprentice';
    if (level < 30) return 'Journeyman';
    if (level < 40) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 60) return 'Grandmaster';
    if (level < 70) return 'Legend';
    if (level < 80) return 'Mythic';
    if (level < 90) return 'Transcendent';
    return 'Divine';
  }
}
