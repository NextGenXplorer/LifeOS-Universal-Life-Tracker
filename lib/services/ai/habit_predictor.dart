import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import 'model_manager.dart';

class HabitPredictor {
  static final _random = Random();

  static Future<double> predictCompletionProbability(String habitId) async {
    // Try TFLite model first
    if (ModelManager.isModelLoaded('habitPredictor')) {
      final features = await _prepareHabitFeatures(habitId);
      final prediction = await _runModelPrediction('habitPredictor', features);
      if (prediction.isNotEmpty) {
        return prediction[0].clamp(0.0, 1.0);
      }
    }

    // Fallback to algorithm-based prediction
    return await _calculateCompletionProbability(habitId);
  }

  static Future<List<double>> _prepareHabitFeatures(String habitId) async {
    // Get habit completion history
    final completions = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
      limit: 30,
    );

    // Calculate features
    final now = DateTime.now();
    final recentCompletions = completions.where((c) {
      final completedAt = DateTime.parse(c['completed_at'] as String);
      return now.difference(completedAt).inDays <= 7;
    }).length;

    final streakFeature = _calculateCurrentStreak(habitId);
    final timeOfDayFeature = now.hour / 24.0;
    final dayOfWeekFeature = now.weekday / 7.0;

    return [
      recentCompletions.toDouble() / 7.0,
      streakFeature / 30.0,
      timeOfDayFeature,
      dayOfWeekFeature,
    ];
  }

  static Future<List<double>> _runModelPrediction(String modelName, List<double> features) async {
    final result = <double>[];
    await ModelManager.runInference(
      modelName: modelName,
      input: features,
      callback: (output) {
        result.addAll(output);
      },
    );
    return result;
  }

  static Future<double> _calculateCompletionProbability(String habitId) async {
    // Get habit details
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'id = ?',
      whereArgs: [habitId],
    );

    if (habits.isEmpty) return 0.5;

    // Get completion history
    final completions = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
      limit: 30,
    );

    if (completions.isEmpty) return 0.3;

    // Calculate base probability from history
    final last7Days = completions.where((c) {
      final completedAt = DateTime.parse(c['completed_at'] as String);
      return DateTime.now().difference(completedAt).inDays <= 7;
    }).length;

    final baseProbability = last7Days / 7.0;

    // Adjust for time of day
    final hour = DateTime.now().hour;
    double timeMultiplier = 1.0;
    if (hour >= 6 && hour <= 9) {
      timeMultiplier = 1.2; // Morning people
    } else if (hour >= 20 && hour <= 22) {
      timeMultiplier = 1.1; // Evening habit
    }

    // Adjust for current streak
    final streak = _calculateCurrentStreak(habitId);
    double streakMultiplier = 1.0 + (streak * 0.02);

    return (baseProbability * timeMultiplier * streakMultiplier).clamp(0.0, 1.0);
  }

  static int _calculateCurrentStreak(String habitId) {
    // Simplified streak calculation
    return 0; // Will be calculated by level system
  }

  static Future<Map<String, double>> predictAllHabits() async {
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    final predictions = <String, double>{};
    for (final habit in habits) {
      predictions[habit['id'] as String] = await predictCompletionProbability(habit['id'] as String);
    }

    return predictions;
  }

  static Future<List<Map<String, dynamic>>> getBestTimeToComplete(String habitId) async {
    // Analyze completion times
    final completions = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );

    if (completions.isEmpty) {
      return [
        {'hour': 8, 'probability': 0.7},
        {'hour': 12, 'probability': 0.6},
        {'hour': 20, 'probability': 0.8},
      ];
    }

    // Group by hour
    final hourCounts = <int, int>{};
    for (final completion in completions) {
      final completedAt = DateTime.parse(completion['completed_at'] as String);
      hourCounts[completedAt.hour] = (hourCounts[completedAt.hour] ?? 0) + 1;
    }

    // Calculate probabilities
    final total = completions.length;
    final bestTimes = hourCounts.entries.map((e) {
      return {
        'hour': e.key,
        'probability': e.value / total,
      };
    }).toList();

    bestTimes.sort((a, b) => (b['probability'] as double).compareTo(a['probability'] as double));
    
    return bestTimes.take(5).toList();
  }
}
