import 'dart:math';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';

class CorrelationEngine {
  static Future<Map<String, double>> findHabitCorrelations() async {
    final correlations = <String, double>{};
    final habits = await DatabaseService.query(
      DatabaseConstants.habitsTable,
      where: 'is_active = ?',
      whereArgs: [1],
    );

    if (habits.length < 2) return correlations;

    // Get completions for each habit
    final habitCompletions = <String, List<DateTime>>{};
    for (final habit in habits) {
      habitCompletions[habit['id'] as String] = await _getCompletionsForHabit(habit['id'] as String);
    }

    // Calculate correlations between all habit pairs
    for (int i = 0; i < habits.length; i++) {
      for (int j = i + 1; j < habits.length; j++) {
        final habit1 = habits[i];
        final habit2 = habits[j];
        
        final correlation = _calculateCorrelation(
          habitCompletions[habit1['id']]!,
          habitCompletions[habit2['id']]!,
        );

        final key = '${habit1['title']}_${habit2['title']}';
        correlations[key] = correlation;
      }
    }

    return correlations;
  }

  static Future<List<DateTime>> _getCompletionsForHabit(String habitId) async {
    final completions = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
      limit: 60,
    );

    return completions.map((c) => DateTime.parse(c['completed_at'] as String)).toList();
  }

  static double _calculateCorrelation(List<DateTime> dates1, List<DateTime> dates2) {
    if (dates1.isEmpty || dates2.isEmpty) return 0.0;

    // Convert to binary arrays (completed or not for each day)
    final days = 30;
    final array1 = _createBinaryArray(dates1, days);
    final array2 = _createBinaryArray(dates2, days);

    // Calculate Pearson correlation
    return _pearsonCorrelation(array1, array2);
  }

  static List<int> _createBinaryArray(List<DateTime> dates, int days) {
    final now = DateTime.now();
    final array = List<int>.filled(days, 0);

    for (final date in dates) {
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < days) {
        array[days - 1 - diff] = 1;
      }
    }

    return array;
  }

  static double _pearsonCorrelation(List<int> x, List<int> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((e) => e * e).reduce((a, b) => a + b);
    final sumY2 = y.map((e) => e * e).reduce((a, b) => a + b);

    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

    if (denominator == 0) return 0.0;
    return numerator / denominator;
  }

  static Future<List<Map<String, dynamic>>> findProductivityPatterns() async {
    final patterns = <Map<String, dynamic>>[];

    // Analyze by day of week
    final dayPatterns = await _analyzeDayOfWeekPatterns();
    if (dayPatterns.isNotEmpty) {
      patterns.add({
        'type': 'day_of_week',
        'title': 'Weekly Productivity Pattern',
        'description': 'Your most productive days are ${dayPatterns.join(", ")}',
        'data': dayPatterns,
      });
    }

    // Analyze by time of day
    final timePatterns = await _analyzeTimePatterns();
    if (timePatterns != null) {
      patterns.add({
        'type': 'time_of_day',
        'title': 'Daily Energy Pattern',
        'description': 'You\'re most productive around ${timePatterns['peakHour']}:00',
        'data': timePatterns,
      });
    }

    return patterns;
  }

  static Future<List<String>> _analyzeDayOfWeekPatterns() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
    );

    if (tasks.isEmpty) return [];

    final dayCounts = <int, int>{};
    for (final task in tasks) {
      final completedAt = DateTime.parse(task['completed_at'] as String);
      dayCounts[completedAt.weekday] = (dayCounts[completedAt.weekday] ?? 0) + 1;
    }

    if (dayCounts.isEmpty) return [];

    // Find days above average
    final avg = dayCounts.values.reduce((a, b) => a + b) / dayCounts.length;
    final days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return dayCounts.entries
        .where((e) => e.value > avg * 1.2)
        .map((e) => days[e.key])
        .toList();
  }

  static Future<Map<String, dynamic>?> _analyzeTimePatterns() async {
    final tasks = await DatabaseService.query(
      DatabaseConstants.tasksTable,
      where: 'completed_at IS NOT NULL',
    );

    if (tasks.isEmpty) return null;

    final hourCounts = <int, int>{};
    for (final task in tasks) {
      final completedAt = DateTime.parse(task['completed_at'] as String);
      hourCounts[completedAt.hour] = (hourCounts[completedAt.hour] ?? 0) + 1;
    }

    if (hourCounts.isEmpty) return null;

    // Find peak hour
    int peakHour = 0;
    int maxCount = 0;
    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        peakHour = hour;
      }
    });

    return {
      'peakHour': peakHour,
      'peakCount': maxCount,
      'distribution': hourCounts,
    };
  }

  static Future<Map<String, double>> getOptimalTaskScheduling() async {
    final patterns = await findProductivityPatterns();
    
    final schedule = <String, double>{
      'morning': 0.3,
      'afternoon': 0.4,
      'evening': 0.3,
    };

    for (final pattern in patterns) {
      if (pattern['type'] == 'time_of_day') {
        final data = pattern['data'] as Map<String, dynamic>;
        final peakHour = data['peakHour'] as int;

        if (peakHour >= 6 && peakHour < 12) {
          schedule['morning'] = 0.6;
          schedule['afternoon'] = 0.3;
          schedule['evening'] = 0.1;
        } else if (peakHour >= 12 && peakHour < 18) {
          schedule['morning'] = 0.3;
          schedule['afternoon'] = 0.5;
          schedule['evening'] = 0.2;
        } else {
          schedule['morning'] = 0.2;
          schedule['afternoon'] = 0.3;
          schedule['evening'] = 0.5;
        }
      }
    }

    return schedule;
  }
}
