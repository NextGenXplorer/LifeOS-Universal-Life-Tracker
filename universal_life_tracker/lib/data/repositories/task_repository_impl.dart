import 'package:lifeos/domain/entities/task.dart';
import 'package:lifeos/domain/repositories/task_repository.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:lifeos/services/gamification/xp_calculator.dart';
import 'package:uuid/uuid.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;
  final XpCalculator _xpCalculator;
  final _uuid = const Uuid();

  TaskRepositoryImpl(this._database) : _xpCalculator = XpCalculator();

  @override
  Future<List<Task>> getAllTasks() async {
    final db = await _database.database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await _database.database;
    final maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'dueDate ASC, priority DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<List<Task>> getPendingTasks() async {
    return getTasksByStatus(TaskStatus.pending);
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'tasks',
      where: '(dueDate >= ? AND dueDate < ?) OR status = ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String(), TaskStatus.pending.index],
      orderBy: 'priority DESC, dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  @override
  Future<Task> createTask(Task task) async {
    final db = await _database.database;
    final newTask = task.copyWith(
      id: task.id.isEmpty ? _uuid.v4() : task.id,
    );
    await db.insert('tasks', newTask.toMap());
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await _database.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _database.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Task> completeTask(String taskId, {int? actualMinutes}) async {
    final db = await _database.database;
    final task = await getTaskById(taskId);
    
    if (task == null) {
      throw Exception('Task not found');
    }

    final completedTask = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      actualMinutes: actualMinutes ?? task.actualMinutes,
    );

    await db.update(
      'tasks',
      completedTask.toMap(),
      where: 'id = ?',
      whereArgs: [taskId],
    );

    return completedTask;
  }

  @override
  Future<List<Task>> getOverdueTasks() async {
    final db = await _database.database;
    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      'tasks',
      where: 'dueDate < ? AND status = ?',
      whereArgs: [now, TaskStatus.pending.index],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) async {
    final db = await _database.database;
    final maps = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<Map<TaskStatus, int>> getTaskStats() async {
    final db = await _database.database;
    final stats = <TaskStatus, int>{};
    
    for (final status in TaskStatus.values) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE status = ?',
        [status.index],
      );
      stats[status] = result.first['count'] as int;
    }
    
    return stats;
  }

  @override
  Future<int> getCompletedTasksCountToday() async {
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE status = ? AND completedAt >= ? AND completedAt < ?',
      [TaskStatus.completed.index, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['count'] as int;
  }
}
