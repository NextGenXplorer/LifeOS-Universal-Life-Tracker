import 'dart:math';
import 'package:lifeos/domain/repositories/habit_repository.dart';

class PatternRecognizer {
  List<Map<String, dynamic>> detectPatterns(List<DateTime> completionDates) {
    final patterns = <Map<String, dynamic>>[];
    
    if (completionDates.isEmpty) return patterns;
    
    // Sort dates
    completionDates.sort();
    
    // Detect weekly pattern
    final weeklyPattern = _detectWeeklyPattern(completionDates);
    if (weeklyPattern != null) {
      patterns.add(weeklyPattern);
    }
    
    // Detect time-of-day pattern
    final timePattern = _detectTimePattern(completionDates);
    if (timePattern != null) {
      patterns.add(timePattern);
    }
    
    // Detect consistency
    final consistency = _calculateConsistency(completionDates);
    patterns.add({
      'type': 'consistency',
      'score': consistency,
      'description': _getConsistencyDescription(consistency),
    });
    
    // Detect trend
    final trend = _detectTrend(completionDates);
    patterns.add({
      'type': 'trend',
      'direction': trend,
      'description': _getTrendDescription(trend),
    });
    
    return patterns;
  }

  Map<String, dynamic>? _detectWeeklyPattern(List<DateTime> dates) {
    if (dates.length < 7) return null;
    
    final dayCounts = <int, int>{};
    for (final date in dates) {
      final dayOfWeek = date.weekday;
      dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + 1;
    }
    
    // Find most frequent days
    final sortedDays = dayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedDays.isEmpty) return null;
    
    final maxCount = sortedDays.first.value;
    final mostFrequentDays = sortedDays
        .where((e) => e.value == maxCount)
        .map((e) => e.key)
        .toList();
    
    return {
      'type': 'weekly',
      'mostFrequentDays': mostFrequentDays,
      'description': 'Most productive on ${_formatDays(mostFrequentDays)}',
    };
  }

  String _formatDays(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (days.length == 7) return 'every day';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) return 'weekdays';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return 'weekends';
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  Map<String, dynamic>? _detectTimePattern(List<DateTime> dates) {
    if (dates.length < 5) return null;
    
    int morning = 0, afternoon = 0, evening = 0, night = 0;
    
    for (final date in dates) {
      final hour = date.hour;
      if (hour >= 5 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 17) {
        afternoon++;
      } else if (hour >= 17 && hour < 21) {
        evening++;
      } else {
        night++;
      }
    }
    
    final maxCount = [morning, afternoon, evening, night].reduce(max);
    String timeOfDay;
    
    if (maxCount == morning) {
      timeOfDay = 'morning';
    } else if (maxCount == afternoon) {
      timeOfDay = 'afternoon';
    } else if (maxCount == evening) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }
    
    return {
      'type': 'time_of_day',
      'preferredTime': timeOfDay,
      'description': 'Most active in the $timeOfDay',
    };
  }

  double _calculateConsistency(List<DateTime> dates) {
    if (dates.length < 2) return 1.0;
    
    // Calculate average gap between completions
    double totalGap = 0;
    int gapCount = 0;
    
    for (int i = 1; i < dates.length; i++) {
      final gap = dates[i].difference(dates[i - 1]).inDays;
      if (gap <= 7) {
        totalGap += gap;
        gapCount++;
      }
    }
    
    if (gapCount == 0) return 0.0;
    
    final avgGap = totalGap / gapCount;
    
    // Consistency score: 1.0 means perfect daily, 0.0 means very inconsistent
    return (1.0 - (avgGap / 7.0)).clamp(0.0, 1.0);
  }

  String _getConsistencyDescription(double score) {
    if (score >= 0.9) return 'Highly consistent - almost perfect!';
    if (score >= 0.7) return 'Very consistent';
    if (score >= 0.5) return 'Moderately consistent';
    if (score >= 0.3) return 'Somewhat inconsistent';
    return 'Needs improvement';
  }

  String _detectTrend(List<DateTime> dates) {
    if (dates.length < 7) return 'neutral';
    
    // Compare recent completions to older ones
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    
    final recentCount = dates.where((d) => d.isAfter(weekAgo)).length;
    final olderCount = dates.where((d) => d.isAfter(twoWeeksAgo) && d.isBefore(weekAgo)).length;
    
    if (recentCount > olderCount * 1.2) return 'improving';
    if (recentCount < olderCount * 0.8) return 'declining';
    return 'stable';
  }

  String _getTrendDescription(String trend) {
    switch (trend) {
      case 'improving':
        return 'Your performance is improving!';
      case 'declining':
        return 'Performance has declined recently';
      default:
        return 'Performance is stable';
    }
  }

  // Correlation detection between habits
  Map<String, double> findCorrelations(
    List<DateTime> habit1Dates,
    List<DateTime> habit2Dates,
  ) {
    final correlations = <String, double>{};
    
    // Simple correlation based on same-day completions
    int sameDayCount = 0;
    final habit2Days = habit2Dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    
    for (final date in habit1Dates) {
      final day = DateTime(date.year, date.month, date.day);
      if (habit2Days.contains(day)) {
        sameDayCount++;
      }
    }
    
    final correlation = habit1Dates.isNotEmpty 
        ? sameDayCount / habit1Dates.length 
        : 0.0;
    
    correlations['positive'] = correlation;
    correlations['negative'] = 1.0 - correlation;
    
    return correlations;
  }

  // Predict optimal time for a habit
  String predictOptimalTime(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 'evening';
    
    final timeCounts = <int, int>{};
    for (final date in completionDates) {
      final hour = (date.hour ~/ 3) * 3; // Group into 3-hour blocks
      timeCounts[hour] = (timeCounts[hour] ?? 0) + 1;
    }
    
    if (timeCounts.isEmpty) return 'evening';
    
    final optimalHour = timeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    if (optimalHour < 6) return 'early morning';
    if (optimalHour < 12) return 'morning';
    if (optimalHour < 15) return 'afternoon';
    if (optimalHour < 18) return 'late afternoon';
    if (optimalHour < 21) return 'evening';
    return 'night';
  }
}
