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
