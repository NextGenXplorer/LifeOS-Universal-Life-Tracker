import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/database_constants.dart';

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Activities Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.activitiesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        category TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Habits Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.habitsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color INTEGER,
        frequency TEXT NOT NULL,
        target_count INTEGER DEFAULT 1,
        reminder_time TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Habit Completions Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.habitCompletionsTable} (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (habit_id) REFERENCES ${DatabaseConstants.habitsTable}(id) ON DELETE CASCADE
      )
    ''');

    // Tasks Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tasksTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER DEFAULT 1,
        due_date TEXT,
        completed_at TEXT,
        category_id TEXT,
        tags TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_rule TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.expensesTable} (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT,
        is_income INTEGER DEFAULT 0,
        receipt_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Expense Categories Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.expenseCategoriesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        budget_limit REAL,
        is_income_category INTEGER DEFAULT 0
      )
    ''');

    // Goals Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.goalsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        target_value REAL NOT NULL,
        current_value REAL DEFAULT 0,
        unit TEXT,
        deadline TEXT,
        category TEXT,
        color INTEGER,
        milestone_ids TEXT,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Milestones Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.milestonesTable} (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        target_value REAL,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES ${DatabaseConstants.goalsTable}(id) ON DELETE CASCADE
      )
    ''');

    // Schedule/Events Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.scheduleTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        is_all_day INTEGER DEFAULT 0,
        location TEXT,
        recurrence_rule TEXT,
        color INTEGER,
        reminder_minutes INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Activity Logs Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.activityLogsTable} (
        id TEXT PRIMARY KEY,
        activity_id TEXT,
        habit_id TEXT,
        task_id TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_minutes INTEGER,
        note TEXT,
        mood INTEGER,
        energy_level INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Templates Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.templatesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        data TEXT NOT NULL,
        is_builtin INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.settingsTable} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // === GAMIFICATION TABLES ===

    // User Stats Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.userStatsTable} (
        id TEXT PRIMARY KEY,
        current_level INTEGER DEFAULT 1,
        total_xp INTEGER DEFAULT 0,
        coins INTEGER DEFAULT 0,
        streak_days INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_activity_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Skill Trees Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.skillTreesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT,
        color INTEGER,
        max_level INTEGER DEFAULT 10,
        description TEXT,
        branches TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // User Skills Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.userSkillsTable} (
        id TEXT PRIMARY KEY,
        skill_tree_id TEXT NOT NULL,
        current_level INTEGER DEFAULT 0,
        xp_in_skill INTEGER DEFAULT 0,
        unlocked_perks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (skill_tree_id) REFERENCES ${DatabaseConstants.skillTreesTable}(id)
      )
    ''');

    // Achievements Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.achievementsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        category TEXT,
        xp_reward INTEGER DEFAULT 0,
        coin_reward INTEGER DEFAULT 0,
        requirement_type TEXT,
        requirement_value INTEGER DEFAULT 0,
        is_secret INTEGER DEFAULT 0
      )
    ''');

    // User Achievements Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.userAchievementsTable} (
        id TEXT PRIMARY KEY,
        achievement_id TEXT NOT NULL,
        unlocked_at TEXT,
        progress INTEGER DEFAULT 0,
        FOREIGN KEY (achievement_id) REFERENCES ${DatabaseConstants.achievementsTable}(id)
      )
    ''');

    // Daily Quests Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.dailyQuestsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        quest_type TEXT NOT NULL,
        target_value INTEGER DEFAULT 1,
        xp_reward INTEGER DEFAULT 0,
        coin_reward INTEGER DEFAULT 0,
        expires_at TEXT NOT NULL,
        is_daily INTEGER DEFAULT 1
      )
    ''');

    // User Quests Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.userQuestsTable} (
        id TEXT PRIMARY KEY,
        quest_id TEXT NOT NULL,
        progress INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (quest_id) REFERENCES ${DatabaseConstants.dailyQuestsTable}(id)
      )
    ''');

    // === AUTOMATION TABLES ===

    // Automation Rules Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.automationRulesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        trigger_type TEXT NOT NULL,
        trigger_config TEXT,
        condition_type TEXT,
        condition_config TEXT,
        action_type TEXT NOT NULL,
        action_config TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Automation Logs Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.automationLogsTable} (
        id TEXT PRIMARY KEY,
        rule_id TEXT NOT NULL,
        triggered_at TEXT NOT NULL,
        executed INTEGER DEFAULT 0,
        result TEXT,
        FOREIGN KEY (rule_id) REFERENCES ${DatabaseConstants.automationRulesTable}(id)
      )
    ''');

    // === AI INSIGHTS TABLES ===

    // AI Insights Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.aiInsightsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        insight_type TEXT NOT NULL,
        confidence REAL DEFAULT 0.0,
        data TEXT,
        created_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');

    // Pattern Logs Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.patternLogsTable} (
        id TEXT PRIMARY KEY,
        pattern_type TEXT NOT NULL,
        data TEXT,
        recorded_at TEXT NOT NULL
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
  }

  static Future<void> _insertDefaultData(Database db) async {
    // Insert default expense categories
    final defaultCategories = [
      {'id': 'food', 'name': 'Food & Dining', 'icon': 'restaurant', 'color': 0xFFFF6584},
      {'id': 'transport', 'name': 'Transportation', 'icon': 'directions_car', 'color': 0xFF42A5F5},
      {'id': 'shopping', 'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFF6C63FF},
      {'id': 'entertainment', 'name': 'Entertainment', 'icon': 'movie', 'color': 0xFFFFA726},
      {'id': 'bills', 'name': 'Bills & Utilities', 'icon': 'receipt', 'color': 0xFFEF5350},
      {'id': 'health', 'name': 'Health & Fitness', 'icon': 'favorite', 'color': 0xFF00BFA6},
      {'id': 'education', 'name': 'Education', 'icon': 'school', 'color': 0xFFAB47BC},
      {'id': 'salary', 'name': 'Salary', 'icon': 'attach_money', 'color': 0xFF4CAF50, 'is_income_category': 1},
    ];

    for (final category in defaultCategories) {
      await db.insert(DatabaseConstants.expenseCategoriesTable, category);
    }

    // Insert default skill trees
    final defaultSkillTrees = [
      {'id': 'health', 'name': 'Health', 'category': 'health', 'icon': 'favorite', 'color': 0xFF00BFA6, 'description': 'Physical and mental well-being', 'branches': 'Exercise,Sleep,Nutrition,Mental Health'},
      {'id': 'productivity', 'name': 'Productivity', 'category': 'productivity', 'icon': 'speed', 'color': 0xFF6C63FF, 'description': 'Efficiency and time management', 'branches': 'Focus,Time Management,Organization,Efficiency'},
      {'id': 'learning', 'name': 'Learning', 'category': 'learning', 'icon': 'school', 'color': 0xFFFFA726, 'description': 'Knowledge and skill development', 'branches': 'Reading,Skills,Knowledge,Memory'},
      {'id': 'social', 'name': 'Social', 'category': 'social', 'icon': 'people', 'color': 0xFF4CAF50, 'description': 'Relationships and networking', 'branches': 'Networking,Communication,Relationships,Leadership'},
      {'id': 'creativity', 'name': 'Creativity', 'category': 'creativity', 'icon': 'palette', 'color': 0xFFAB47BC, 'description': 'Innovation and artistic expression', 'branches': 'Art,Writing,Innovation,Problem Solving'},
    ];

    for (final tree in defaultSkillTrees) {
      await db.insert(DatabaseConstants.skillTreesTable, tree);
    }

    // Insert default achievements
    final defaultAchievements = [
      {'id': 'first_habit', 'title': 'First Step', 'description': 'Complete your first habit', 'icon': 'emoji_events', 'category': 'habit', 'xp_reward': 50, 'coin_reward': 10, 'requirement_type': 'habits_completed', 'requirement_value': 1},
      {'id': 'streak_7', 'title': 'Week Warrior', 'description': 'Maintain a 7-day streak', 'icon': 'local_fire_department', 'category': 'streak', 'xp_reward': 100, 'coin_reward': 25, 'requirement_type': 'streak_days', 'requirement_value': 7},
      {'id': 'streak_30', 'title': 'Monthly Master', 'description': 'Maintain a 30-day streak', 'icon': 'whatshot', 'category': 'streak', 'xp_reward': 500, 'coin_reward': 100, 'requirement_type': 'streak_days', 'requirement_value': 30},
      {'id': 'level_10', 'title': 'Rising Star', 'description': 'Reach level 10', 'icon': 'star', 'category': 'level', 'xp_reward': 200, 'coin_reward': 50, 'requirement_type': 'level', 'requirement_value': 10},
      {'id': 'level_50', 'title': 'Veteran', 'description': 'Reach level 50', 'icon': 'military_tech', 'category': 'level', 'xp_reward': 1000, 'coin_reward': 250, 'requirement_type': 'level', 'requirement_value': 50},
      {'id': 'first_task', 'title': 'Task Initiator', 'description': 'Complete your first task', 'icon': 'task_alt', 'category': 'task', 'xp_reward': 30, 'coin_reward': 5, 'requirement_type': 'tasks_completed', 'requirement_value': 1},
      {'id': 'tasks_100', 'title': 'Productive Pro', 'description': 'Complete 100 tasks', 'icon': 'verified', 'category': 'task', 'xp_reward': 300, 'coin_reward': 75, 'requirement_type': 'tasks_completed', 'requirement_value': 100},
      {'id': 'first_expense', 'title': 'Money Mindful', 'description': 'Log your first expense', 'icon': 'account_balance_wallet', 'category': 'expense', 'xp_reward': 25, 'coin_reward': 5, 'requirement_type': 'expenses_logged', 'requirement_value': 1},
      {'id': 'skill_tree_1', 'title': 'Specialist', 'description': 'Unlock your first skill', 'icon': 'psychology', 'category': 'skill', 'xp_reward': 75, 'coin_reward': 15, 'requirement_type': 'skill_level', 'requirement_value': 1},
      {'id': 'perfect_day', 'title': 'Perfect Day', 'description': 'Complete all habits and tasks in a day', 'icon': 'diamond', 'category': 'daily', 'xp_reward': 150, 'coin_reward': 30, 'requirement_type': 'perfect_day', 'requirement_value': 1},
    ];

    for (final achievement in defaultAchievements) {
      await db.insert(DatabaseConstants.achievementsTable, achievement);
    }
  }

  // CRUD Helper Methods
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<void> execute(String sql, [List<dynamic>? args]) async {
    final db = await database;
    await db.execute(sql, args);
  }

  static Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
