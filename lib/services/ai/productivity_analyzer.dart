import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import 'model_manager.dart';

class ProductivityAnalyzer {
  static final _random = Random();

  static Future<Map<String, dynamic>> analyzeProductivity() async {
    // Try TFLite model first
    if (ModelManager.isModelLoaded('productivity')) {
      final features = await _prepareProductivityFeatures();
      final prediction = await _runModelPrediction('productivity', features);
      if (prediction.isNotEmpty) {
        return _interpretProductivityScore(prediction[0]);
      }
    }

    // Fallback to algorithm
    return await _calculateProductivityAnalysis();
  }

  static Future<List<double>> _prepareProductivityFeatures() async {
    final now = DateTime.now();
    
    // Get task completion data
    final completedTasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
    );

    final totalTasks = await DatabaseService.query(DatabaseConstants.tasksTable);
    
    // Get habits
    final completedHabits = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
    );

    // Calculate features
    final completionRate = totalTasks.isNotEmpty 
        ? completedTasks.length / totalTasks.length 
        : 0.0;
    
    final dayOfWeek = now.weekday / 7.0;
    final hourOfDay = now.hour / 24.0;
    final habitCompletionRate = await _getHabitCompletionRate();

    return [
      completionRate,
      dayOfWeek,
      hourOfDay,
      habitCompletionRate,
      (now.hour >= 9 && now.hour <= 17) ? 1.0 : 0.0, // Work hours
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

  static Map<String, dynamic> _interpretProductivityScore(double score) {
    String rating;
    String message;
    
    if (score >= 0.8) {
      rating = 'Excellent';
      message = 'You\'re on fire! Keep up the great work!';
    } else if (score >= 0.6) {
      rating = 'Good';
      message = 'Solid productivity today. Keep it up!';
    } else if (score >= 0.4) {
      rating = 'Average';
      message = 'Room for improvement. Let\'s push harder!';
    } else {
      rating = 'Low';
      message = 'Consider breaking tasks into smaller steps.';
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'rating': rating,
      'message': message,
    };
  }

  static Future<Map<String, dynamic>> _calculateProductivityAnalysis() async {
    // Calculate task completion rate
    final allTasks = await DatabaseService.query(DatabaseConstants.tasksTable);
    final completedTasks = allTasks.where((t) => t['completed_at'] != null).length;
    
    final completionRate = allTasks.isNotEmpty 
        ? completedTasks / allTasks.length 
        : 0.0;

    // Calculate habits completion
    final habitRate = await _getHabitCompletionRate();

    // Weighted productivity score
    final score = (completionRate * 0.6) + (habitRate * 0.4);

    return _interpretProductivityScore(score);
  }

  static Future<double> _getHabitCompletionRate() async {
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    if (habits.isEmpty) return 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    int completedToday = 0;
    for (final habit in habits) {
      final completions = await DatabaseService.query(
        DatabaseConstants.habitCompletionsTable,
        where: 'habit_id = ? AND completed_at >= ?',
        whereArgs: [habit['id'], today],
      );
      if (completions.isNotEmpty) completedToday++;
    }

    return completedToday / habits.length;
  }

  static Future<List<Map<String, dynamic>>> getProductivityByDay() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
      orderBy: 'completed_at DESC',
      limit: 100,
    );

    final dayCounts = <int, int>{};
    for (final task in tasks) {
      final completedAt = DateTime.parse(task['completed_at'] as String);
      dayCounts[completedAt.weekday] = (dayCounts[completedAt.weekday] ?? 0) + 1;
    }

    return dayCounts.entries.map((e) {
      return {
        'day': e.key,
        'count': e.value,
        'label': _getDayLabel(e.key),
      };
    }).toList()
      ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  }

  static String _getDayLabel(int day) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day];
  }

  static Future<List<Map<String, dynamic>>> getProductivityByHour() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
    );

    final hourCounts = <int, int>{};
    for (final task in tasks) {
      final completedAt = DateTime.parse(task['completed_at'] as String);
      hourCounts[completedAt.hour] = (hourCounts[completedAt.hour] ?? 0) + 1;
    }

    return List.generate(24, (hour) {
      return {
        'hour': hour,
        'count': hourCounts[hour] ?? 0,
      };
    });
  }

  static Future<int> getTotalTasksCompleted() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
    );
    return tasks.length;
  }

  static Future<double> getAverageTasksPerDay() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
      orderBy: 'completed_at ASC',
    );

    if (tasks.isEmpty) return 0.0;

    final firstTask = DateTime.parse(tasks.first['completed_at'] as String);
    final lastTask = DateTime.parse(tasks.last['completed_at'] as String);
    final daysDiff = lastTask.difference(firstTask).inDays + 1;

    return tasks.length / daysDiff;
  }
}
