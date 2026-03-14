import 'package:lifeos/domain/entities/habit.dart';
import 'package:lifeos/domain/repositories/habit_repository.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';
import 'package:uuid/uuid.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _database;
  final XpCalculator _xpCalculator;
  final _uuid = const Uuid();

  HabitRepositoryImpl(this._database) : _xpCalculator = XpCalculator();

  @override
  Future<List<Habit>> getAllHabits() async {
    final db = await _database.database;
    final maps = await db.query('habits', orderBy: 'createdAt DESC');
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final db = await _database.database;
    final maps = await db.query(
      'habits',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    final db = await _database.database;
    final newHabit = habit.copyWith(
      id: habit.id.isEmpty ? _uuid.v4() : habit.id,
    );
    await db.insert('habits', newHabit.toMap());
    return newHabit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    final db = await _database.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    final db = await _database.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<HabitLog> completeHabit(String habitId) async {
    final db = await _database.database;
    final habit = await getHabitById(habitId);
    
    if (habit == null) {
      throw Exception('Habit not found');
    }

    final now = DateTime.now();
    final xpEarned = _xpCalculator.calculateHabitXp(habit);
    
    // Calculate streak
    int newStreak = habit.currentStreak;
    if (habit.lastCompletedAt != null) {
      final lastCompleted = habit.lastCompletedAt!;
      final daysDiff = now.difference(lastCompleted).inDays;
      
      if (daysDiff == 1) {
        newStreak += 1;
      } else if (daysDiff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // Update habit
    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      bestStreak: newStreak > habit.bestStreak ? newStreak : habit.bestStreak,
      totalCompletions: habit.totalCompletions + 1,
      lastCompletedAt: now,
    );

    await db.update(
      'habits',
      updatedHabit.toMap(),
      where: 'id = ?',
      whereArgs: [habitId],
    );

    // Create log
    final log = HabitLog(
      id: _uuid.v4(),
      habitId: habitId,
      completedAt: now,
      xpEarned: xpEarned,
    );

    await db.insert('habit_logs', log.toMap());

    return log;
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId, {int? limit}) async {
    final db = await _database.database;
    final maps = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completedAt DESC',
      limit: limit,
    );
    return maps.map((map) => HabitLog.fromMap(map)).toList();
  }

  @override
  Future<List<HabitLog>> getTodayLogs() async {
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'habit_logs',
      where: 'completedAt >= ? AND completedAt < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => HabitLog.fromMap(map)).toList();
  }

  @override
  Future<Map<String, int>> getCompletionStats(String habitId, int days) async {
    final db = await _database.database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final maps = await db.rawQuery('''
      SELECT DATE(completedAt) as date, COUNT(*) as count 
      FROM habit_logs 
      WHERE habitId = ? AND completedAt >= ?
      GROUP BY DATE(completedAt)
    ''', [habitId, startDate.toIso8601String()]);

    final stats = <String, int>{};
    for (final map in maps) {
      stats[map['date'] as String] = map['count'] as int;
    }
    return stats;
  }

  @override
  Future<int> getTotalCompletionsToday() async {
    final logs = await getTodayLogs();
    return logs.length;
  }

  @override
  Future<int> getCurrentStreak(String habitId) async {
    final habit = await getHabitById(habitId);
    return habit?.currentStreak ?? 0;
  }

  @override
  Future<int> getBestStreak(String habitId) async {
    final habit = await getHabitById(habitId);
    return habit?.bestStreak ?? 0;
  }
}
