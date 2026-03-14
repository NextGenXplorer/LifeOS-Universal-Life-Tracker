class XpCalculator {
  int calculateHabitXp(dynamic habit) {
    int baseXp = habit.xpReward as int? ?? 10;
    
    // Streak bonus
    final streak = habit.currentStreak as int? ?? 0;
    double streakMultiplier = 1.0;
    
    if (streak >= 7) {
      streakMultiplier = 1.5;
    } else if (streak >= 30) {
      streakMultiplier = 2.0;
    } else if (streak >= 100) {
      streakMultiplier = 3.0;
    }
    
    return (baseXp * streakMultiplier).round();
  }

  int calculateTaskXp(dynamic task, {int? actualMinutes}) {
    int baseXp = task.xpReward as int? ?? 15;
    
    // Priority bonus
    final priority = task.priority as int? ?? 0;
    double priorityMultiplier = 1.0;
    
    switch (priority) {
      case 3: // urgent
        priorityMultiplier = 2.0;
        break;
      case 2: // high
        priorityMultiplier = 1.5;
        break;
      default:
        priorityMultiplier = 1.0;
    }
    
    // Time bonus (completing faster than estimated)
    if (actualMinutes != null) {
      final estimatedMinutes = task.estimatedMinutes as int? ?? 30;
      if (actualMinutes < estimatedMinutes) {
        final timeSaved = estimatedMinutes - actualMinutes;
        baseXp += (timeSaved / estimatedMinutes * 10).round();
      }
    }
    
    return (baseXp * priorityMultiplier).round();
  }

  int calculateStreakBonusXp(int streakDays) {
    if (streakDays >= 30) {
      return 100;
    } else if (streakDays >= 7) {
      return 50;
    } else if (streakDays >= 3) {
      return 25;
    }
    return 0;
  }

  int calculatePerfectDayBonus(int habitsCompleted, int totalHabits) {
    if (habitsCompleted >= totalHabits && totalHabits > 0) {
      return 100;
    }
    return 0;
  }

  int calculateDailyLoginBonus(int consecutiveDays) {
    if (consecutiveDays >= 30) {
      return 50;
    } else if (consecutiveDays >= 7) {
      return 25;
    } else if (consecutiveDays >= 3) {
      return 10;
    }
    return 5;
  }

  int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * (1.15 * (level - 1) - 1) / 0.15).round();
  }

  int xpToNextLevel(int currentLevel, int currentXp) {
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return nextLevelXp - currentXp;
  }

  double levelProgress(int currentLevel, int currentXp) {
    final levelStartXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return (currentXp - levelStartXp) / (nextLevelXp - levelStartXp);
  }
}
