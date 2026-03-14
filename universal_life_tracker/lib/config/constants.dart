class AppConstants {
  // App Info
  static const String appName = 'LifeOS';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'lifeos.db';
  static const int databaseVersion = 1;
  
  // Gamification
  static const int maxLevel = 100;
  static const int baseXpPerLevel = 100;
  static const double xpMultiplier = 1.15;
  static const int dailyXpBonus = 50;
  static const int streakBonusXp = 25;
  static const int perfectDayBonus = 100;
  
  // Skill Trees
  static const List<String> skillTreeNames = [
    'Health',
    'Productivity',
    'Learning',
    'Social',
    'Creativity',
  ];
  
  // Achievement Categories
  static const List<String> achievementCategories = [
    'Habits',
    'Tasks',
    'Streaks',
    'Skills',
    'XP',
    'Special',
  ];
  
  // Automation
  static const int maxAutomationRules = 50;
  static const int automationCheckIntervalMinutes = 15;
  
  // AI/ML
  static const int minDataPointsForPrediction = 7;
  static const int predictionDaysAhead = 7;
  static const int insightRefreshHours = 6;
  
  // UI
  static const double borderRadius = 20.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Notification Channels
  static const String habitReminderChannel = 'habit_reminders';
  static const String taskDueChannel = 'task_due';
  static const String achievementChannel = 'achievements';
  static const String automationChannel = 'automation';
  
  // Shared Preferences Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserId = 'user_id';
  static const String keyDarkMode = 'dark_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyLastSync = 'last_sync';
  static const String keyDailyXpClaimed = 'daily_xp_claimed';
  static const String keyDailyXpDate = 'daily_xp_date';
  
  // Voice Commands
  static const List<String> voiceCommandPatterns = [
    'add habit',
    'complete habit',
    'add task',
    'complete task',
    'show stats',
    'show achievements',
  ];
}
