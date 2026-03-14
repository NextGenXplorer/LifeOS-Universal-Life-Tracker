import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lifeos/config/constants.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        currentXp INTEGER DEFAULT 0,
        totalXp INTEGER DEFAULT 0,
        coins INTEGER DEFAULT 0,
        totalHabitsCompleted INTEGER DEFAULT 0,
        totalTasksCompleted INTEGER DEFAULT 0,
        currentDayStreak INTEGER DEFAULT 0,
        bestDayStreak INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastActiveAt TEXT NOT NULL,
        avatarId TEXT DEFAULT 'default',
        skillLevels TEXT DEFAULT '',
        skillXp TEXT DEFAULT ''
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        colorIndex INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        weekDays TEXT,
        targetPerWeek INTEGER,
        currentStreak INTEGER DEFAULT 0,
        bestStreak INTEGER DEFAULT 0,
        totalCompletions INTEGER DEFAULT 0,
        xpReward INTEGER DEFAULT 10,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastCompletedAt TEXT,
        iconName TEXT,
        skillTree TEXT NOT NULL
      )
    ''');

    // Habit logs table
    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PRIMARY KEY,
        habitId TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        xpEarned INTEGER DEFAULT 0,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL,
        status INTEGER DEFAULT 0,
        dueDate TEXT,
        reminderTime TEXT,
        estimatedMinutes INTEGER DEFAULT 30,
        actualMinutes INTEGER DEFAULT 0,
        xpReward INTEGER DEFAULT 15,
        parentTaskId TEXT,
        tags TEXT DEFAULT '',
        isRecurring INTEGER DEFAULT 0,
        recurrencePattern TEXT,
        skillTree TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        streak INTEGER DEFAULT 0,
        FOREIGN KEY (parentTaskId) REFERENCES tasks (id) ON DELETE SET NULL
      )
    ''');

    // Achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        xpReward INTEGER DEFAULT 50,
        coinReward INTEGER DEFAULT 10,
        iconName TEXT NOT NULL,
        isUnlocked INTEGER DEFAULT 0,
        unlockedAt TEXT,
        progress REAL DEFAULT 0.0,
        target INTEGER DEFAULT 1
      )
    ''');

    // Skills table
    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        treeName TEXT NOT NULL,
        description TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        currentXp INTEGER DEFAULT 0,
        xpToNextLevel INTEGER DEFAULT 100,
        maxLevel INTEGER DEFAULT 10,
        isUnlocked INTEGER DEFAULT 1,
        iconName TEXT NOT NULL,
        prerequisiteSkills TEXT DEFAULT '',
        unlockedRecipes TEXT DEFAULT ''
      )
    ''');

    // Automation rules table
    await db.execute('''
      CREATE TABLE automation_rules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        triggerType TEXT NOT NULL,
        triggerConfig TEXT NOT NULL,
        conditionType TEXT,
        conditionConfig TEXT,
        actionType TEXT NOT NULL,
        actionConfig TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastTriggered TEXT
      )
    ''');

    // Journal entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT NOT NULL,
        mood INTEGER,
        energyLevel INTEGER,
        tags TEXT DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Insights table
    await db.execute('''
      CREATE TABLE insights (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        data TEXT,
        createdAt TEXT NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_habit_logs_habitId ON habit_logs (habitId)');
    await db.execute('CREATE INDEX idx_habit_logs_completedAt ON habit_logs (completedAt)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks (status)');
    await db.execute('CREATE INDEX idx_tasks_dueDate ON tasks (dueDate)');
    await db.execute('CREATE INDEX idx_journal_createdAt ON journal_entries (createdAt)');

    // Insert default achievements
    await _insertDefaultAchievements(db);
    
    // Insert default skills
    await _insertDefaultSkills(db);
    
    // Insert default user
    await _insertDefaultUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> _insertDefaultAchievements(Database db) async {
    final achievements = [
      {'id': 'first_habit', 'name': 'First Step', 'description': 'Create your first habit', 'category': 'Habits', 'xpReward': 25, 'coinReward': 5, 'iconName': 'star', 'target': 1},
      {'id': 'habit_10', 'name': 'Habit Builder', 'description': 'Create 10 habits', 'category': 'Habits', 'xpReward': 100, 'coinReward': 25, 'iconName': 'list', 'target': 10},
      {'id': 'streak_7', 'name': 'Week Warrior', 'description': 'Maintain a 7-day streak', 'category': 'Streaks', 'xpReward': 75, 'coinReward': 20, 'iconName': 'local_fire_department', 'target': 7},
      {'id': 'streak_30', 'name': 'Monthly Master', 'description': 'Maintain a 30-day streak', 'category': 'Streaks', 'xpReward': 300, 'coinReward': 100, 'iconName': 'whatshot', 'target': 30},
      {'id': 'streak_100', 'name': 'Unstoppable', 'description': 'Maintain a 100-day streak', 'category': 'Streaks', 'xpReward': 1000, 'coinReward': 500, 'iconName': 'military_tech', 'target': 100},
      {'id': 'first_task', 'name': 'Task Initiate', 'description': 'Complete your first task', 'category': 'Tasks', 'xpReward': 25, 'coinReward': 5, 'iconName': 'check_circle', 'target': 1},
      {'id': 'tasks_50', 'name': 'Productivity Pro', 'description': 'Complete 50 tasks', 'category': 'Tasks', 'xpReward': 200, 'coinReward': 50, 'iconName': 'done_all', 'target': 50},
      {'id': 'tasks_100', 'name': 'Task Master', 'description': 'Complete 100 tasks', 'category': 'Tasks', 'xpReward': 500, 'coinReward': 150, 'iconName': 'emoji_events', 'target': 100},
      {'id': 'level_10', 'name': 'Rising Star', 'description': 'Reach level 10', 'category': 'XP', 'xpReward': 200, 'coinReward': 50, 'iconName': 'trending_up', 'target': 10},
      {'id': 'level_25', 'name': 'XP Hunter', 'description': 'Reach level 25', 'category': 'XP', 'xpReward': 500, 'coinReward': 150, 'iconName': 'diamond', 'target': 25},
      {'id': 'level_50', 'name': 'Elite', 'description': 'Reach level 50', 'category': 'XP', 'xpReward': 1000, 'coinReward': 300, 'iconName': 'workspace_premium', 'target': 50},
      {'id': 'first_skill', 'name': 'Skill Seeker', 'description': 'Unlock your first skill', 'category': 'Skills', 'xpReward': 50, 'coinReward': 10, 'iconName': 'bolt', 'target': 1},
      {'id': 'skill_10', 'name': 'Skillful', 'description': 'Reach level 10 in any skill', 'category': 'Skills', 'xpReward': 300, 'coinReward': 75, 'iconName': 'psychology', 'target': 10},
      {'id': 'all_skills', 'name': 'Jack of All Trades', 'description': 'Unlock all 5 skill trees', 'category': 'Skills', 'xpReward': 500, 'coinReward': 200, 'iconName': 'auto_awesome', 'target': 5},
      {'id': 'perfect_day', 'name': 'Perfect Day', 'description': 'Complete all habits in a day', 'category': 'Special', 'xpReward': 100, 'coinReward': 25, 'iconName': 'verified', 'target': 1},
      {'id': 'week_perfect', 'name': 'Perfect Week', 'description': 'Have 7 perfect days', 'category': 'Special', 'xpReward': 500, 'coinReward': 150, 'iconName': 'calendar_month', 'target': 7},
      {'id': 'early_bird', 'name': 'Early Bird', 'description': 'Complete a habit before 7 AM', 'category': 'Special', 'xpReward': 50, 'coinReward': 15, 'iconName': 'wb_sunny', 'target': 1},
      {'id': 'night_owl', 'name': 'Night Owl', 'description': 'Complete a habit after 10 PM', 'category': 'Special', 'xpReward': 50, 'coinReward': 15, 'iconName': 'nightlight', 'target': 1},
    ];

    for (final achievement in achievements) {
      await db.insert('achievements', achievement);
    }
  }

  Future<void> _insertDefaultSkills(Database db) async {
    // Health Skill Tree
    final healthSkills = [
      {'id': 'health_1', 'name': 'Vitality', 'treeName': 'Health', 'description': 'Increases XP from health habits by 10%', 'iconName': 'favorite', 'xpToNextLevel': 100},
      {'id': 'health_2', 'name': 'Endurance', 'treeName': 'Health', 'description': 'Increases streak bonus XP by 15%', 'iconName': 'fitness_center', 'prerequisiteSkills': 'health_1', 'xpToNextLevel': 200},
      {'id': 'health_3', 'name': 'Discipline', 'treeName': 'Health', 'description': 'Unlocks habit templates', 'iconName': 'self_improvement', 'prerequisiteSkills': 'health_2', 'xpToNextLevel': 300},
      {'id': 'health_4', 'name': 'Resilience', 'treeName': 'Health', 'description': 'Reduces streak loss on missed days', 'iconName': 'shield', 'prerequisiteSkills': 'health_3', 'xpToNextLevel': 400},
      {'id': 'health_5', 'name': 'Enlightenment', 'treeName': 'Health', 'description': 'Mastery of health habits', 'iconName': 'spa', 'prerequisiteSkills': 'health_4', 'xpToNextLevel': 500},
    ];

    // Productivity Skill Tree
    final productivitySkills = [
      {'id': 'prod_1', 'name': 'Focus', 'treeName': 'Productivity', 'description': 'Increases task XP by 10%', 'iconName': 'center_focus_strong', 'xpToNextLevel': 100},
      {'id': 'prod_2', 'name': 'Efficiency', 'treeName': 'Productivity', 'description': 'Completing tasks faster gives bonus XP', 'iconName': 'speed', 'prerequisiteSkills': 'prod_1', 'xpToNextLevel': 200},
      {'id': 'prod_3', 'name': 'Time Management', 'treeName': 'Productivity', 'description': 'Unlocks time blocking features', 'iconName': 'schedule', 'prerequisiteSkills': 'prod_2', 'xpToNextLevel': 300},
      {'id': 'prod_4', 'name': 'Flow State', 'treeName': 'Productivity', 'description': 'Combo bonus for consecutive tasks', 'iconName': 'all_inclusive', 'prerequisiteSkills': 'prod_3', 'xpToNextLevel': 400},
      {'id': 'prod_5', 'name': 'Mastery', 'treeName': 'Productivity', 'description': 'Productivity mastery', 'iconName': 'star', 'prerequisiteSkills': 'prod_4', 'xpToNextLevel': 500},
    ];

    // Learning Skill Tree
    final learningSkills = [
      {'id': 'learn_1', 'name': 'Curiosity', 'treeName': 'Learning', 'description': 'Unlocks journal features', 'iconName': 'lightbulb', 'xpToNextLevel': 100},
      {'id': 'learn_2', 'name': 'Knowledge', 'treeName': 'Learning', 'description': 'Better AI insights', 'iconName': 'school', 'prerequisiteSkills': 'learn_1', 'xpToNextLevel': 200},
      {'id': 'learn_3', 'name': 'Wisdom', 'treeName': 'Learning', 'description': 'Pattern recognition boost', 'iconName': 'psychology', 'prerequisiteSkills': 'learn_2', 'xpToNextLevel': 300},
      {'id': 'learn_4', 'name': 'Insight', 'treeName': 'Learning', 'description': 'Unlock advanced predictions', 'iconName': 'visibility', 'prerequisiteSkills': 'learn_3', 'xpToNextLevel': 400},
      {'id': 'learn_5', 'name': 'Transcendence', 'treeName': 'Learning', 'description': 'Learning mastery', 'iconName': 'auto_awesome', 'prerequisiteSkills': 'learn_4', 'xpToNextLevel': 500},
    ];

    // Social Skill Tree
    final socialSkills = [
      {'id': 'social_1', 'name': 'Connection', 'treeName': 'Social', 'description': 'Friend system preparation', 'iconName': 'people', 'xpToNextLevel': 100},
      {'id': 'social_2', 'name': 'Influence', 'treeName': 'Social', 'description': 'Share achievements', 'iconName': 'share', 'prerequisiteSkills': 'social_1', 'xpToNextLevel': 200},
      {'id': 'social_3', 'name': 'Community', 'treeName': 'Social', 'description': 'Team challenges', 'iconName': 'groups', 'prerequisiteSkills': 'social_2', 'xpToNextLevel': 300},
      {'id': 'social_4', 'name': 'Leadership', 'treeName': 'Social', 'description': 'Mentor system', 'iconName': 'emoji_people', 'prerequisiteSkills': 'social_3', 'xpToNextLevel': 400},
      {'id': 'social_5', 'name': 'Legacy', 'treeName': 'Social', 'description': 'Social mastery', 'iconName': 'military_tech', 'prerequisiteSkills': 'social_4', 'xpToNextLevel': 500},
    ];

    // Creativity Skill Tree
    final creativitySkills = [
      {'id': 'create_1', 'name': 'Imagination', 'treeName': 'Creativity', 'description': 'Custom habit icons', 'iconName': 'brush', 'xpToNextLevel': 100},
      {'id': 'create_2', 'name': 'Expression', 'treeName': 'Creativity', 'description': 'Journal templates', 'iconName': 'palette', 'prerequisiteSkills': 'create_1', 'xpToNextLevel': 200},
      {'id': 'create_3', 'name': 'Innovation', 'treeName': 'Creativity', 'description': 'Custom themes', 'iconName': 'extension', 'prerequisiteSkills': 'create_2', 'xpToNextLevel': 300},
      {'id': 'create_4', 'name': 'Artistry', 'treeName': 'Creativity', 'description': 'Advanced customization', 'iconName': 'auto_fix_high', 'prerequisiteSkills': 'create_3', 'xpToNextLevel': 400},
      {'id': 'create_5', 'name': 'Genius', 'treeName': 'Creativity', 'description': 'Creativity mastery', 'iconName': 'toll', 'prerequisiteSkills': 'create_4', 'xpToNextLevel': 500},
    ];

    final allSkills = [...healthSkills, ...productivitySkills, ...learningSkills, ...socialSkills, ...creativitySkills];

    for (final skill in allSkills) {
      await db.insert('skills', {
        ...skill,
        'level': 1,
        'currentXp': 0,
        'maxLevel': 10,
        'isUnlocked': skill['prerequisiteSkills'] == null ? 1 : 0,
      });
    }
  }

  Future<void> _insertDefaultUser(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'id': 'default_user',
      'username': 'LifeOS User',
      'level': 1,
      'currentXp': 0,
      'totalXp': 0,
      'coins': 0,
      'totalHabitsCompleted': 0,
      'totalTasksCompleted': 0,
      'currentDayStreak': 0,
      'bestDayStreak': 0,
      'createdAt': now,
      'lastActiveAt': now,
      'avatarId': 'default',
      'skillLevels': 'Health:1,Productivity:1,Learning:1,Social:1,Creativity:1',
      'skillXp': 'Health:0,Productivity:0,Learning:0,Social:0,Creativity:0',
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
