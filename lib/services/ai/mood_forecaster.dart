import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import 'model_manager.dart';

class MoodForecaster {
  static Future<Map<String, dynamic>> forecastMood() async {
    // Try TFLite model first
    if (ModelManager.isModelLoaded('mood')) {
      final features = await _prepareMoodFeatures();
      final prediction = await _runModelPrediction('mood', features);
      if (prediction.isNotEmpty) {
        return _interpretMoodPrediction(prediction[0]);
      }
    }

    // Fallback to algorithm
    return await _calculateMoodForecast();
  }

  static Future<List<double>> _prepareMoodFeatures() async {
    final now = DateTime.now();
    
    // Get habit completion rate
    final habitRate = await _getHabitCompletionRate();
    
    // Get sleep hours (would come from a sleep tracker)
    final sleepHours = 7.0; // Placeholder
    
    // Get exercise minutes
    final exerciseMinutes = await _getTodayExerciseMinutes();
    
    // Get social interactions count
    final socialInteractions = await _getTodaySocialInteractions();

    return [
      habitRate,
      sleepHours / 12.0,
      exerciseMinutes / 60.0,
      socialInteractions / 10.0,
      now.hour / 24.0,
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

  static Map<String, dynamic> _interpretMoodPrediction(double score) {
    String mood;
    String emoji;
    List<String> suggestions;

    if (score >= 0.8) {
      mood = 'Excellent';
      emoji = '😄';
      suggestions = [
        'Keep up the great work!',
        'You\'re in a great flow state.',
        'This is the perfect time for challenging tasks.',
      ];
    } else if (score >= 0.6) {
      mood = 'Good';
      emoji = '🙂';
      suggestions = [
        'You\'re doing well!',
        'Stay consistent with your habits.',
        'Consider a short break to recharge.',
      ];
    } else if (score >= 0.4) {
      mood = 'Neutral';
      emoji = '😐';
      suggestions = [
        'Take a moment to practice gratitude.',
        'A short walk might help boost your mood.',
        'Try completing a quick task for momentum.',
      ];
    } else if (score >= 0.2) {
      mood = 'Low';
      emoji = '😔';
      suggestions = [
        'Remember: tomorrow is a new day.',
        'Consider reaching out to someone.',
        'Take care of yourself - that\'s most important.',
      ];
    } else {
      mood = 'Struggling';
      emoji = '😢';
      suggestions = [
        'It\'s okay to have hard days.',
        'Consider talking to someone you trust.',
        'Focus on one small thing at a time.',
      ];
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'mood': mood,
      'emoji': emoji,
      'suggestions': suggestions,
    };
  }

  static Future<Map<String, dynamic>> _calculateMoodForecast() async {
    final habitRate = await _getHabitCompletionRate();
    final sleepQuality = await _getSleepQuality();
    final exerciseToday = await _getTodayExerciseMinutes();

    // Calculate mood score
    double score = 0.5;
    score += (habitRate - 0.5) * 0.3;
    score += (sleepQuality - 0.5) * 0.3;
    score += (exerciseToday / 30.0).clamp(-0.2, 0.2);

    return _interpretMoodPrediction(score.clamp(0.0, 1.0));
  }

  static Future<double> _getHabitCompletionRate() async {
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    if (habits.isEmpty) return 0.5;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    int completed = 0;
    for (final habit in habits) {
      final completions = await DatabaseService.query(
        DatabaseConstants.habitCompletionsTable,
        where: 'habit_id = ? AND completed_at >= ?',
        whereArgs: [habit['id'], today],
      );
      if (completions.isNotEmpty) completed++;
    }

    return completed / habits.length;
  }

  static Future<double> _getSleepQuality() async {
    // Placeholder - would integrate with sleep tracking
    return 0.7;
  }

  static Future<int> _getTodayExerciseMinutes() async {
    // Placeholder - would integrate with pedometer/health data
    return 30;
  }

  static Future<int> _getTodaySocialInteractions() async {
    // Placeholder - would count social activities
    return 3;
  }

  static Future<List<Map<String, dynamic>>> getMoodHistory({int days = 7}) async {
    final now = DateTime.now();
    final history = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day).toIso8601String();
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      // Get habits completed that day
      final habits = await DatabaseService.query(DatabaseConstants.habitsTable);
      int completed = 0;
      
      for (final habit in habits) {
        final completions = await DatabaseService.query(
          DatabaseConstants.habitCompletionsTable,
          where: 'habit_id = ? AND completed_at >= ? AND completed_at <= ?',
          whereArgs: [habit['id'], dayStart, dayEnd],
        );
        if (completions.isNotEmpty) completed++;
      }

      final rate = habits.isNotEmpty ? completed / habits.length : 0.0;
      
      history.add({
        'date': dayStart,
        'completionRate': rate,
        'mood': _rateToMood(rate),
      });
    }

    return history;
  }

  static String _rateToMood(double rate) {
    if (rate >= 0.8) return 'Great';
    if (rate >= 0.6) return 'Good';
    if (rate >= 0.4) return 'Okay';
    if (rate >= 0.2) return 'Low';
    return 'Struggling';
  }
}
