import 'package:lifeos/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<List<Habit>> getActiveHabits();
  Future<Habit?> getHabitById(String id);
  Future<Habit> createHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<HabitLog> completeHabit(String habitId);
  Future<List<HabitLog>> getHabitLogs(String habitId, {int? limit});
  Future<List<HabitLog>> getTodayLogs();
  Future<Map<String, int>> getCompletionStats(String habitId, int days);
  Future<int> getTotalCompletionsToday();
  Future<int> getCurrentStreak(String habitId);
  Future<int> getBestStreak(String habitId);
}
