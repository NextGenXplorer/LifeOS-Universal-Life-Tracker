import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/gamification/achievement.dart';
import '../../services/gamification/level_system.dart';
import 'package:uuid/uuid.dart';

class AchievementEngine {
  static const _uuid = Uuid();

  static Future<List<Achievement>> getAllAchievements() async {
    final results = await DatabaseService.query(DatabaseConstants.achievementsTable);
    return results.map((map) => Achievement.fromMap(map)).toList();
  }

  static Future<Achievement?> getAchievement(String id) async {
    final results = await DatabaseService.query(
      DatabaseConstants.achievementsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return Achievement.fromMap(results.first);
  }

  static Future<List<UserAchievement>> getUserAchievements() async {
    final results = await DatabaseService.query(
      DatabaseConstants.userAchievementsTable,
      orderBy: 'unlocked_at DESC',
    );
    
    final List<UserAchievement> userAchievements = [];
    for (final map in results) {
      final achievement = await getAchievement(map['achievement_id'] as String);
      userAchievements.add(UserAchievement.fromMap(map, achievement: achievement));
    }
    
    return userAchievements;
  }

  static Future<UserAchievement?> getUserAchievement(String achievementId) async {
    final results = await DatabaseService.query(
      DatabaseConstants.userAchievementsTable,
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );
    if (results.isEmpty) return null;
    
    final achievement = await getAchievement(achievementId);
    return UserAchievement.fromMap(results.first, achievement: achievement);
  }

  static Future<UserAchievement> trackAchievement(String achievementId, int progress) async {
    var userAchievement = await getUserAchievement(achievementId);
    final achievement = await getAchievement(achievementId);
    
    if (userAchievement == null) {
      // Create new tracking
      userAchievement = UserAchievement(
        id: _uuid.v4(),
        achievementId: achievementId,
        progress: progress,
      );
      await DatabaseService.insert(
        DatabaseConstants.userAchievementsTable,
        userAchievement.toMap(),
      );
    } else {
      // Update progress
      userAchievement = userAchievement.copyWith(progress: progress);
      await DatabaseService.update(
        DatabaseConstants.userAchievementsTable,
        userAchievement.toMap(),
        where: 'id = ?',
        whereArgs: [userAchievement.id],
      );
    }

    // Check if achievement should be unlocked
    if (achievement != null && 
        progress >= achievement.requirementValue && 
        !userAchievement.isUnlocked) {
      return await unlockAchievement(achievementId);
    }

    return userAchievement.copyWith(achievement: achievement);
  }

  static Future<UserAchievement> unlockAchievement(String achievementId) async {
    final achievement = await getAchievement(achievementId);
    if (achievement == null) {
      throw Exception('Achievement not found');
    }

    var userAchievement = await getUserAchievement(achievementId);
    
    final unlockedAchievement = userAchievement?.copyWith(
      unlockedAt: DateTime.now(),
      progress: achievement.requirementValue,
    ) ?? UserAchievement(
      id: _uuid.v4(),
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
      progress: achievement.requirementValue,
    );

    if (userAchievement == null) {
      await DatabaseService.insert(
        DatabaseConstants.userAchievementsTable,
        unlockedAchievement.toMap(),
      );
    } else {
      await DatabaseService.update(
        DatabaseConstants.userAchievementsTable,
        unlockedAchievement.toMap(),
        where: 'id = ?',
        whereArgs: [userAchievement.id],
      );
    }

    // Award XP and coins
    if (achievement.xpReward > 0) {
      await LevelSystem.addXp(achievement.xpReward);
    }
    if (achievement.coinReward > 0) {
      await LevelSystem.addCoins(achievement.coinReward);
    }

    return unlockedAchievement.copyWith(achievement: achievement);
  }

  static Future<List<Achievement>> checkAndUnlockAchievements({
    required int habitsCompleted,
    required int tasksCompleted,
    required int expensesLogged,
    required int currentStreak,
    required int currentLevel,
    int? skillLevel,
  }) async {
    final achievements = await getAllAchievements();
    final List<Achievement> newlyUnlocked = [];

    for (final achievement in achievements) {
      final requirementType = achievement.requirementType;
      if (requirementType == null) continue;

      bool shouldUnlock = false;
      int progress = 0;

      switch (requirementType) {
        case 'habits_completed':
          progress = habitsCompleted;
          shouldUnlock = habitsCompleted >= achievement.requirementValue;
        case 'tasks_completed':
          progress = tasksCompleted;
          shouldUnlock = tasksCompleted >= achievement.requirementValue;
        case 'expenses_logged':
          progress = expensesLogged;
          shouldUnlock = expensesLogged >= achievement.requirementValue;
        case 'streak_days':
          progress = currentStreak;
          shouldUnlock = currentStreak >= achievement.requirementValue;
        case 'level':
          progress = currentLevel;
          shouldUnlock = currentLevel >= achievement.requirementValue;
        case 'skill_level':
          if (skillLevel != null) {
            progress = skillLevel;
            shouldUnlock = skillLevel >= achievement.requirementValue;
          }
        case 'perfect_day':
          progress = shouldUnlock ? 1 : 0;
      }

      // Track progress
      await trackAchievement(achievement.id, progress);

      // Unlock if ready
      final userAchievement = await getUserAchievement(achievement.id);
      if (shouldUnlock && (userAchievement == null || !userAchievement.isUnlocked)) {
        await unlockAchievement(achievement.id);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  static Future<int> getUnlockedCount() async {
    final results = await DatabaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.userAchievementsTable} WHERE unlocked_at IS NOT NULL',
    );
    return results.first['count'] as int? ?? 0;
  }

  static Future<int> getTotalAchievementsCount() async {
    final results = await DatabaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.achievementsTable}',
    );
    return results.first['count'] as int? ?? 0;
  }
}
