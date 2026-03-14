import 'package:lifeos/services/pattern_recognition/pattern_recognizer.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';

class PredictionService {
  final PatternRecognizer _patternRecognizer;
  final AppDatabase _database;

  PredictionService(this._patternRecognizer, this._database);

  Future<Map<String, dynamic>> predictCompletionRate() async {
    final db = await _database.database;
    final habits = await db.query('habits', where: 'isActive = ?', whereArgs: [1]);
    
    final predictions = <String, dynamic>{};
    
    for (final habit in habits) {
      final habitId = habit['id'] as String;
      final logs = await db.query(
        'habit_logs',
        where: 'habitId = ?',
        whereArgs: [habitId],
        orderBy: 'completedAt DESC',
        limit: 30,
      );
      
      if (logs.isEmpty) {
        predictions[habitId] = {
          'predictedRate': 0.5,
          'confidence': 'low',
        };
        continue;
      }
      
      // Simple prediction based on recent trends
      final dates = logs.map((l) => DateTime.parse(l['completedAt'] as String)).toList();
      final patterns = _patternRecognizer.detectPatterns(dates);
      
      // Find consistency score
      final consistency = patterns.firstWhere(
        (p) => p['type'] == 'consistency',
        orElse: () => {'score': 0.5},
      )['score'] as double;
      
      // Find trend
      final trend = patterns.firstWhere(
        (p) => p['type'] == 'trend',
        orElse: () => {'direction': 'stable'},
      )['direction'] as String;
      
      double predictedRate = consistency;
      
      // Adjust for trend
      if (trend == 'improving') {
        predictedRate = (predictedRate + 0.1).clamp(0.0, 1.0);
      } else if (trend == 'declining') {
        predictedRate = (predictedRate - 0.1).clamp(0.0, 1.0);
      }
      
      predictions[habitId] = {
        'predictedRate': predictedRate,
        'confidence': logs.length >= 14 ? 'high' : (logs.length >= 7 ? 'medium' : 'low'),
        'trend': trend,
      };
    }
    
    return predictions;
  }

  Future<String> predictEnergyLevel() async {
    final db = await _database.database;
    
    // Get today's completions
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final todayLogs = await db.query(
      'habit_logs',
      where: 'completedAt >= ?',
      whereArgs: [startOfDay.toIso8601String()],
    );
    
    // Get yesterday's completions
    final yesterday = startOfDay.subtract(const Duration(days: 1));
    final yesterdayLogs = await db.query(
      'habit_logs',
      where: 'completedAt >= ? AND completedAt < ?',
      whereArgs: [yesterday.toIso8601String(), startOfDay.toIso8601String()],
    );
    
    // Calculate morning completions (before noon)
    final morningCutoff = DateTime(now.year, now.month, now.day, 12);
    final morningToday = todayLogs.where(
      (l) => DateTime.parse(l['completedAt'] as String).isBefore(morningCutoff),
    ).length;
    
    final morningYesterday = yesterdayLogs.where(
      (l) => DateTime.parse(l['completedAt'] as String).isBefore(morningCutoff),
    ).length;
    
    // Predict energy level
    if (morningToday >= 3 || (morningToday > morningYesterday && todayLogs.length >= 3)) {
      return 'high';
    } else if (morningToday >= 1 || todayLogs.length >= 2) {
      return 'medium';
    }
    return 'low';
  }

  Future<Map<String, dynamic>> predictProductivity() async {
    final db = await _database.database;
    
    // Get completed tasks from last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final completedTasks = await db.query(
      'tasks',
      where: 'status = ? AND completedAt >= ?',
      whereArgs: [2, weekAgo.toIso8601String()],
    );
    
    // Calculate average tasks per day
    final avgTasksPerDay = completedTasks.length / 7.0;
    
    // Get average completion time
    int totalMinutes = 0;
    int tasksWithTime = 0;
    
    for (final task in completedTasks) {
      if (task['actualMinutes'] != null && task['actualMinutes'] > 0) {
        totalMinutes += task['actualMinutes'] as int;
        tasksWithTime++;
      }
    }
    
    final avgCompletionTime = tasksWithTime > 0 ? totalMinutes / tasksWithTime : 30;
    
    String productivityLevel;
    if (avgTasksPerDay >= 5) {
      productivityLevel = 'high';
    } else if (avgTasksPerDay >= 2) {
      productivityLevel = 'medium';
    } else {
      productivityLevel = 'low';
    }
    
    return {
      'level': productivityLevel,
      'avgTasksPerDay': avgTasksPerDay,
      'avgCompletionMinutes': avgCompletionTime.round(),
      'totalCompleted': completedTasks.length,
    };
  }

  Future<List<Map<String, dynamic>>> generatePredictions() async {
    final predictions = <Map<String, dynamic>>[];
    
    // Habit completion predictions
    final completionPredictions = await predictCompletionRate();
    for (final entry in completionPredictions.entries) {
      predictions.add({
        'type': 'habit_completion',
        'targetId': entry.key,
        'prediction': entry.value,
      });
    }
    
    // Energy prediction
    final energyLevel = await predictEnergyLevel();
    predictions.add({
      'type': 'energy',
      'prediction': energyLevel,
    });
    
    // Productivity prediction
    final productivity = await predictProductivity();
    predictions.add({
      'type': 'productivity',
      'prediction': productivity,
    });
    
    return predictions;
  }
}
