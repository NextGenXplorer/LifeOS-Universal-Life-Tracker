import '../gamification/level_system.dart';
import '../gamification/skill_tree_manager.dart';
import '../gamification/xp_calculator.dart';

class RewardService {
  static Future<Map<String, dynamic>> awardHabitCompletionRewards({
    required int streakDays,
    bool isPerfectDay = false,
  }) async {
    final xp = XpCalculator.calculateHabitXp(
      streakDays: streakDays,
      isPerfectDay: isPerfectDay,
    );

    final stats = await LevelSystem.addXp(xp);
    await LevelSystem.addCoins(2);
    await LevelSystem.updateStreak();

    return {
      'xp': xp,
      'coins': 2,
      'newLevel': stats.currentLevel,
      'leveledUp': false, // Will be determined by caller
      'streakDays': stats.streakDays,
    };
  }

  static Future<Map<String, dynamic>> awardTaskCompletionRewards({
    required int priority,
    bool isOverdue = false,
  }) async {
    final xp = XpCalculator.calculateTaskXp(
      priority: priority,
      isOverdue: isOverdue,
    );

    final stats = await LevelSystem.addXp(xp);
    await LevelSystem.addCoins(3);

    return {
      'xp': xp,
      'coins': 3,
      'newLevel': stats.currentLevel,
    };
  }

  static Future<Map<String, dynamic>> awardExpenseLogRewards() async {
    await LevelSystem.addXp(5);
    final stats = await LevelSystem.addCoins(1);

    return {
      'xp': 5,
      'coins': 1,
    };
  }

  static Future<Map<String, dynamic>> awardSkillUpgradeRewards(String skillTreeId) async {
    final xp = 25;
    final coins = 5;

    await LevelSystem.addXp(xp);
    await LevelSystem.addCoins(coins);

    return {
      'xp': xp,
      'coins': coins,
    };
  }

  static Future<Map<String, dynamic>> claimDailyBonus() async {
    final streak = await LevelSystem.getOrCreateUserStats();
    int xp = 20;
    int coins = 10;

    // Streak bonus
    if (streak.streakDays > 7) {
      xp += 10;
      coins += 5;
    }
    if (streak.streakDays > 30) {
      xp += 30;
      coins += 15;
    }

    await LevelSystem.addXp(xp);
    await LevelSystem.addCoins(coins);

    return {
      'xp': xp,
      'coins': coins,
      'streakDays': streak.streakDays,
    };
  }

  static String getRewardEmoji(int coins) {
    if (coins >= 100) return '💎';
    if (coins >= 50) return '🏆';
    if (coins >= 25) return '⭐';
    if (coins >= 10) return '✨';
    return '🌟';
  }

  static List<Map<String, String>> getAvailablePowerUps() {
    return [
      {'id': 'xp_boost', 'name': 'XP Boost', 'description': 'Double XP for next hour', 'cost': '50'},
      {'id': 'streak_shield', 'name': 'Streak Shield', 'description': 'Protect streak for one miss', 'cost': '100'},
      {'id': 'task_skip', 'name': 'Task Skip', 'description': 'Skip one task without penalty', 'cost': '30'},
      {'id': 'mystery_box', 'name': 'Mystery Box', 'description': 'Random reward (10-100 coins)', 'cost': '75'},
    ];
  }

  static Future<bool> purchasePowerUp(String powerUpId, int cost) async {
    final stats = await LevelSystem.getOrCreateUserStats();
    
    if (stats.coins < cost) {
      return false;
    }

    // Deduct coins
    final updatedStats = stats.copyWith(
      coins: stats.coins - cost,
      updatedAt: DateTime.now(),
    );

    await LevelSystem.addCoins(-cost); // Negative to subtract
    
    return true;
  }
}
