import '../../core/constants/database_constants.dart';
import '../../domain/entities/gamification/user_stats.dart';

class XpCalculator {
  // Base XP values for different actions
  static const int habitCompletionXp = 10;
  static const int taskCompletionXp = 15;
  static const int streakBonusXp = 5;
  static const int perfectDayXp = 50;
  static const int goalMilestoneXp = 100;
  static const int firstActionXp = 25;

  // Multipliers
  static const double streakMultiplier = 1.5;
  static const double priorityMultiplier = 2.0;

  static int calculateHabitXp({
    required int streakDays,
    bool isPerfectDay = false,
  }) {
    int xp = habitCompletionXp;

    // Apply streak bonus
    if (streakDays > 0) {
      xp += (streakDays * streakBonusXp).clamp(0, 50);
    }

    // Perfect day bonus
    if (isPerfectDay) {
      xp += perfectDayXp;
    }

    return xp;
  }

  static int calculateTaskXp({
    required int priority,
    bool isOverdue = false,
  }) {
    int xp = taskCompletionXp;

    // Priority bonus
    switch (priority) {
      case 3: // urgent
        xp = (xp * priorityMultiplier).round();
      case 2: // high
        xp = (xp * 1.5).round();
      case 1: // medium
      default:
        break;
    }

    // Overdue penalty (no bonus)
    if (isOverdue) {
      xp = (xp * 0.8).round();
    }

    return xp;
  }

  static int calculateStreakXp(int streakDays) {
    if (streakDays < 7) return streakDays * 2;
    if (streakDays < 30) return 14 + ((streakDays - 7) * 3);
    return 84 + ((streakDays - 30) * 5);
  }

  static int calculateLevelUpXp(int fromLevel, int toLevel) {
    int totalXp = 0;
    for (int i = fromLevel; i <= toLevel; i++) {
      totalXp += UserStats._calculateXpForLevel(i);
    }
    return totalXp;
  }

  static Map<String, int> calculateAllRewards({
    required int habitsCompleted,
    required int tasksCompleted,
    required int currentStreak,
    bool isPerfectDay = false,
  }) {
    int totalXp = 0;
    int totalCoins = 0;

    // Habit XP
    totalXp += habitsCompleted * habitCompletionXp;
    totalCoins += habitsCompleted * 2;

    // Task XP
    totalXp += tasksCompleted * taskCompletionXp;
    totalCoins += tasksCompleted * 3;

    // Streak XP and coins
    totalXp += calculateStreakXp(currentStreak);
    totalCoins += (currentStreak ~/ 7) * 10;

    // Perfect day bonus
    if (isPerfectDay) {
      totalXp += perfectDayXp;
      totalCoins += 20;
    }

    return {
      'xp': totalXp,
      'coins': totalCoins,
    };
  }
}
