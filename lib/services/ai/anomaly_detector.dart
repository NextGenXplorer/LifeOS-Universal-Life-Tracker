import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import 'model_manager.dart';

class AnomalyDetector {
  static const double _threshold = 0.3; // 30% deviation considered anomaly

  static Future<List<Map<String, dynamic>>> detectAnomalies() async {
    final anomalies = <Map<String, dynamic>>[];

    // Check habit completion anomalies
    final habitAnomalies = await _detectHabitAnomalies();
    anomalies.addAll(habitAnomalies);

    // Check spending anomalies
    final spendingAnomalies = await _detectSpendingAnomalies();
    anomalies.addAll(spendingAnomalies);

    // Check task completion anomalies
    final taskAnomalies = await _detectTaskAnomalies();
    anomalies.addAll(taskAnomalies);

    // Check sleep/activity anomalies
    final activityAnomalies = await _detectActivityAnomalies();
    anomalies.addAll(activityAnomalies);

    return anomalies;
  }

  static Future<List<Map<String, dynamic>>> _detectHabitAnomalies() async {
    final anomalies = <Map<String, dynamic>>[];
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    for (final habit in habits) {
      // Get last 14 days of data
      final completions = await _getHabitCompletionsRange(
        habit['id'] as String,
        14,
      );

      if (completions.length < 7) continue;

      // Calculate expected vs actual
      final expectedRate = completions.length / 14.0;
      final recentRate = completions.take(3).length / 3.0;

      // Significant drop
      if (expectedRate - recentRate > _threshold) {
        anomalies.add({
          'type': 'habit_drop',
          'severity': 'high',
          'title': 'Habit Completion Drop',
          'description': 'You\'ve missed ${habit['title']} more than usual recently.',
          'data': {
            'habitId': habit['id'],
            'habitTitle': habit['title'],
            'expectedRate': expectedRate,
            'recentRate': recentRate,
          },
          'suggestion': 'Try setting a reminder for ${habit['title']}',
        });
      }

      // Unusually high completion
      if (recentRate - expectedRate > _threshold) {
        anomalies.add({
          'type': 'habit_surge',
          'severity': 'positive',
          'title': 'Great Progress!',
          'description': 'You\'ve been very consistent with ${habit['title']}!',
          'data': {
            'habitId': habit['id'],
            'habitTitle': habit['title'],
            'recentRate': recentRate,
          },
        });
      }
    }

    return anomalies;
  }

  static Future<List<Map<String, dynamic>>> _detectSpendingAnomalies() async {
    final anomalies = <Map<String, dynamic>>[];
    
    // Get last 30 days of expenses
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final expenses = await DatabaseService.query(
      DatabaseConstants.expensesTable,
      where: 'date >= ? AND is_income = 0',
      whereArgs: [thirtyDaysAgo.toIso8601String()],
      orderBy: 'date ASC',
    );

    if (expenses.length < 14) return anomalies;

    // Calculate daily average
    final dailyAverages = _calculateDailyAverages(expenses);
    final overallAverage = dailyAverages.values.reduce((a, b) => a + b) / dailyAverages.length;

    // Check recent spending
    final recentDays = dailyAverages.entries.skip(dailyAverages.length - 3);
    final recentAverage = recentDays.map((e) => e.value).reduce((a, b) => a + b) / 3;

    // Unusually high spending
    if (recentAverage > overallAverage * 1.5) {
      anomalies.add({
        'type': 'spending_spike',
        'severity': 'warning',
        'title': 'Spending Spike Detected',
        'description': 'Your recent spending is 50% higher than usual.',
        'data': {
          'recentAverage': recentAverage,
          'normalAverage': overallAverage,
        },
        'suggestion': 'Review recent expenses in the Expenses tab',
      });
    }

    return anomalies;
  }

  static Future<List<Map<String, dynamic>>> _detectTaskAnomalies() async {
    final anomalies = <Map<String, dynamic>>[];
    
    final tasks = await DatabaseService.query(DatabaseConstants.tasksTable);
    final completedTasks = tasks.where((t) => t['completed_at'] != null).length;
    final overdueTasks = tasks.where((t) {
      if (t['completed_at'] != null) return false;
      if (t['due_date'] == null) return false;
      final dueDate = DateTime.parse(t['due_date'] as String);
      return dueDate.isBefore(DateTime.now());
    }).length;

    // High overdue ratio
    if (tasks.isNotEmpty && overdueTasks / tasks.length > 0.3) {
      anomalies.add({
        'type': 'overdue_buildup',
        'severity': 'warning',
        'title': 'Tasks Building Up',
        'description': 'You have $overdueTasks overdue tasks.',
        'data': {
          'totalTasks': tasks.length,
          'completedTasks': completedTasks,
          'overdueTasks': overdueTasks,
        },
        'suggestion': 'Prioritize completing overdue tasks',
      });
    }

    return anomalies;
  }

  static Future<List<Map<String, dynamic>>> _detectActivityAnomalies() async {
    final anomalies = <Map<String, dynamic>>[];

    // Check for consistent late nights
    final recentActivities = await DatabaseService.query(
      DatabaseConstants.activityLogsTable,
      orderBy: 'created_at DESC',
      limit: 50,
    );

    if (recentActivities.isEmpty) return anomalies;

    // Count late night activities
    int lateNightCount = 0;
    for (final activity in recentActivities) {
      if (activity['start_time'] != null) {
        final startTime = DateTime.parse(activity['start_time'] as String);
        if (startTime.hour >= 23 || startTime.hour < 5) {
          lateNightCount++;
        }
      }
    }

    if (lateNightCount > recentActivities.length * 0.5) {
      anomalies.add({
        'type': 'late_night_pattern',
        'severity': 'warning',
        'title': 'Late Night Pattern',
        'description': 'You\'ve been active late at night frequently.',
        'data': {
          'lateNightCount': lateNightCount,
          'totalActivities': recentActivities.length,
        },
        'suggestion': 'Consider getting more sleep for better productivity',
      });
    }

    return anomalies;
  }

  static Future<List<DateTime>> _getHabitCompletionsRange(String habitId, int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final completions = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ? AND completed_at >= ?',
      whereArgs: [habitId, startDate.toIso8601String()],
    );

    return completions.map((c) => DateTime.parse(c['completed_at'] as String)).toList();
  }

  static Map<String, double> _calculateDailyAverages(List<Map<String, dynamic>> expenses) {
    final dailyTotals = <String, double>{};
    
    for (final expense in expenses) {
      final date = (expense['date'] as String).substring(0, 10);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + (expense['amount'] as num).toDouble();
    }

    return dailyTotals;
  }

  static Future<void> logAnomalyPattern(String type, Map<String, dynamic> data) async {
    // Save detected anomaly pattern for future reference
    await DatabaseService.insert(DatabaseConstants.patternLogsTable, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'pattern_type': type,
      'data': data.toString(),
      'recorded_at': DateTime.now().toIso8601String(),
    });
  }
}
