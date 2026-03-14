import 'package:lifeos/domain/repositories/insights_repository.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:lifeos/services/pattern_recognition/pattern_recognizer.dart';
import 'package:lifeos/services/prediction/prediction_service.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final AppDatabase _database;
  final PatternRecognizer _patternRecognizer;
  final PredictionService _predictionService;

  InsightsRepositoryImpl(this._database, this._patternRecognizer, this._predictionService);

  @override
  Future<Map<String, dynamic>> getInsights() async {
    return {
      'habitInsights': await getHabitInsights(),
      'productivityInsights': await getProductivityInsights(),
      'weeklySummary': await getWeeklySummary(),
      'predictions': await getPredictions(),
      'recommendations': await getRecommendations(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getHabitInsights() async {
    final db = await _database.database;
    final insights = <Map<String, dynamic>>[];
    
    // Get all habits with their completion rates
    final habits = await db.query('habits', where: 'isActive = ?', whereArgs: [1]);
    
    for (final habit in habits) {
      final habitId = habit['id'] as String;
      final logs = await db.query(
        'habit_logs',
        where: 'habitId = ?',
        whereArgs: [habitId],
        orderBy: 'completedAt DESC',
        limit: 30,
      );
      
      if (logs.isNotEmpty) {
        // Calculate completion rate
        final completionRate = logs.length / 30.0;
        
        // Detect patterns
        final patterns = _patternRecognizer.detectPatterns(
          logs.map((l) => DateTime.parse(l['completedAt'] as String)).toList(),
        );
        
        insights.add({
          'habitId': habitId,
          'habitName': habit['name'],
          'completionRate': completionRate,
          'currentStreak': habit['currentStreak'],
          'bestStreak': habit['bestStreak'],
          'patterns': patterns,
          'totalCompletions': habit['totalCompletions'],
        });
      }
    }
    
    return insights;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductivityInsights() async {
    final db = await _database.database;
    final insights = <Map<String, dynamic>>[];
    
    // Get completed tasks
    final completedTasks = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [2], // TaskStatus.completed.index
      orderBy: 'completedAt DESC',
      limit: 50,
    );
    
    if (completedTasks.isNotEmpty) {
      // Calculate average completion time
      int totalMinutes = 0;
      int tasksWithTime = 0;
      
      for (final task in completedTasks) {
        if (task['actualMinutes'] != null && task['actualMinutes'] > 0) {
          totalMinutes += task['actualMinutes'] as int;
          tasksWithTime++;
        }
      }
      
      final avgCompletionTime = tasksWithTime > 0 ? totalMinutes / tasksWithTime : 0;
      
      // Get priority distribution
      final priorityCounts = <int, int>{};
      for (final task in completedTasks) {
        final priority = task['priority'] as int;
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
      }
      
      insights.add({
        'type': 'completion_time',
        'averageMinutes': avgCompletionTime.round(),
        'totalTasks': completedTasks.length,
      });
      
      insights.add({
        'type': 'priority_distribution',
        'data': priorityCounts,
      });
    }
    
    // Get overdue tasks
    final now = DateTime.now().toIso8601String();
    final overdueTasks = await db.query(
      'tasks',
      where: 'dueDate < ? AND status = ?',
      whereArgs: [now, 0], // TaskStatus.pending.index
    );
    
    if (overdueTasks.isNotEmpty) {
      insights.add({
        'type': 'overdue',
        'count': overdueTasks.length,
      });
    }
    
    return insights;
  }

  @override
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final db = await _database.database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    // Get habit completions this week
    final habitLogs = await db.query(
      'habit_logs',
      where: 'completedAt >= ?',
      whereArgs: [weekAgo.toIso8601String()],
    );
    
    // Get completed tasks this week
    final completedTasks = await db.query(
      'tasks',
      where: 'status = ? AND completedAt >= ?',
      whereArgs: [2, weekAgo.toIso8601String()],
    );
    
    // Get total XP earned
    int totalXp = 0;
    for (final log in habitLogs) {
      totalXp += log['xpEarned'] as int? ?? 0;
    }
    
    return {
      'habitsCompleted': habitLogs.length,
      'tasksCompleted': completedTasks.length,
      'xpEarned': totalXp,
      'dateRange': {
        'start': weekAgo.toIso8601String(),
        'end': now.toIso8601String(),
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getPredictions() async {
    final predictions = await _predictionService.predictCompletionRate();
    final energyPrediction = await _predictionService.predictEnergyLevel();
    
    return {
      'completionRate': predictions,
      'energyLevel': energyPrediction,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    final recommendations = <Map<String, dynamic>>[];
    
    // Get habit insights
    final habitInsights = await getHabitInsights();
    
    for (final insight in habitInsights) {
      final completionRate = insight['completionRate'] as double;
      final currentStreak = insight['currentStreak'] as int;
      
      if (completionRate < 0.5) {
        recommendations.add({
          'type': 'habit',
          'priority': 'high',
          'title': 'Boost ${insight['habitName']}',
          'description': 'Your completion rate is ${(completionRate * 100).toStringAsFixed(0)}%. Try setting reminders.',
          'habitId': insight['habitId'],
        });
      }
      
      if (currentStreak >= 7 && currentStreak < 30) {
        recommendations.add({
          'type': 'streak',
          'priority': 'medium',
          'title': 'Keep the streak going!',
          'description': 'You\'re on a ${currentStreak}-day streak with ${insight['habitName']}. Don\'t break it!',
          'habitId': insight['habitId'],
        });
      }
    }
    
    // Check for perfect day opportunity
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final habits = await db.query('habits', where: 'isActive = ?', whereArgs: [1]);
    final todayLogs = await db.query(
      'habit_logs',
      where: 'completedAt >= ?',
      whereArgs: [startOfDay.toIso8601String()],
    );
    
    if (habits.isNotEmpty && todayLogs.length >= habits.length * 0.7) {
      recommendations.add({
        'type': 'perfect_day',
        'priority': 'high',
        'title': 'Almost a perfect day!',
        'description': 'You\'re ${todayLogs.length}/${habits.length} habits away from a perfect day.',
      });
    }
    
    return recommendations;
  }
}
