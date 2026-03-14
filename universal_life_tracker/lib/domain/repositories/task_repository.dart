import 'package:lifeos/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getTasksByStatus(TaskStatus status);
  Future<List<Task>> getPendingTasks();
  Future<List<Task>> getTodayTasks();
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<Task> completeTask(String taskId, {int? actualMinutes});
  Future<List<Task>> getOverdueTasks();
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end);
  Future<Map<TaskStatus, int>> getTaskStats();
  Future<int> getCompletedTasksCountToday();
}
