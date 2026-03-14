import 'package:lifeos/domain/repositories/habit_repository.dart';
import 'package:lifeos/domain/repositories/task_repository.dart';
import 'package:lifeos/domain/repositories/gamification_repository.dart';

abstract class InsightsRepository {
  Future<Map<String, dynamic>> getInsights();
  Future<List<Map<String, dynamic>>> getHabitInsights();
  Future<List<Map<String, dynamic>>> getProductivityInsights();
  Future<Map<String, dynamic>> getWeeklySummary();
  Future<Map<String, dynamic>> getPredictions();
  Future<List<Map<String, dynamic>>> getRecommendations();
}
