import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/ai/ai_insight.dart';
import 'anomaly_detector.dart';
import 'correlation_engine.dart';
import 'habit_predictor.dart';
import 'mood_forecaster.dart';
import 'productivity_analyzer.dart';

class InsightGenerator {
  static const _uuid = Uuid();

  static Future<List<AiInsight>> generateAllInsights() async {
    final insights = <AiInsight>[];

    // Generate habit prediction insights
    final habitInsights = await _generateHabitInsights();
    insights.addAll(habitInsights);

    // Generate productivity insights
    final productivityInsights = await _generateProductivityInsights();
    insights.addAll(productivityInsights);

    // Generate mood insights
    final moodInsights = await _generateMoodInsights();
    insights.addAll(moodInsights);

    // Generate anomaly insights
    final anomalyInsights = await _generateAnomalyInsights();
    insights.addAll(anomalyInsights);

    // Generate correlation insights
    final correlationInsights = await _generateCorrelationInsights();
    insights.addAll(correlationInsights);

    // Save insights to database
    for (final insight in insights) {
      await _saveInsight(insight);
    }

    return insights;
  }

  static Future<List<AiInsight>> _generateHabitInsights() async {
    final insights = <AiInsight>[];
    final predictions = await HabitPredictor.predictAllHabits();

    for (final entry in predictions.entries) {
      final probability = entry.value;
      String title;
      String description;
      double confidence = probability;

      if (probability > 0.8) {
        title = 'Great ${_getHabitName(entry.key)} Day!';
        description = 'You\'re likely to complete your habits today. Keep the momentum going!';
      } else if (probability > 0.5) {
        title = 'Moderate ${_getHabitName(entry.key)} Day';
        description = 'Complete one habit early to build momentum for the rest of the day.';
      } else if (probability > 0.3) {
        title = 'Challenge Ahead for ${_getHabitName(entry.key)}';
        description = 'Consider simplifying your habits today or setting a reminder.';
      } else {
        title = 'Focus Needed on ${_getHabitName(entry.key)}';
        description = 'Your habits might slip today. Try completing the easiest one first.';
        confidence = 1 - probability;
      }

      insights.add(AiInsight(
        id: _uuid.v4(),
        title: title,
        description: description,
        insightType: InsightType.habitPrediction,
        confidence: confidence,
        data: {'habitId': entry.key, 'probability': probability},
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  static Future<List<AiInsight>> _generateProductivityInsights() async {
    final insights = <AiInsight>[];
    final analysis = await ProductivityAnalyzer.analyzeProductivity();

    final score = analysis['score'] as double;
    final rating = analysis['rating'] as String;

    insights.add(AiInsight(
      id: _uuid.v4(),
      title: 'Productivity: $rating',
      description: analysis['message'] as String,
      insightType: InsightType.productivity,
      confidence: score,
      data: analysis,
      createdAt: DateTime.now(),
    ));

    // Add scheduling suggestion
    final schedule = await CorrelationEngine.getOptimalTaskScheduling();
    String scheduleSuggestion;
    if ((schedule['morning'] ?? 0) >= (schedule['evening'] ?? 0)) {
      scheduleSuggestion = 'Schedule important tasks in the morning for best results.';
    } else {
      scheduleSuggestion = 'You\'re most productive in the evening. Save big tasks for then.';
    }

    insights.add(AiInsight(
      id: _uuid.v4(),
      title: 'Optimal Scheduling',
      description: scheduleSuggestion,
      insightType: InsightType.suggestion,
      confidence: 0.7,
      data: schedule,
      createdAt: DateTime.now(),
    ));

    return insights;
  }

  static Future<List<AiInsight>> _generateMoodInsights() async {
    final insights = <AiInsight>[];
    final forecast = await MoodForecaster.forecastMood();

    insights.add(AiInsight(
      id: _uuid.v4(),
      title: 'Mood Forecast: ${forecast['mood']}',
      description: '${forecast['emoji']} ${forecast['description']}',
      insightType: InsightType.moodForecast,
      confidence: forecast['score'] as double,
      data: forecast,
      createdAt: DateTime.now(),
    ));

    // Add suggestions
    final suggestions = forecast['suggestions'] as List<String>;
    if (suggestions.isNotEmpty) {
      insights.add(AiInsight(
        id: _uuid.v4(),
        title: 'Mood Tip',
        description: suggestions.first,
        insightType: InsightType.suggestion,
        confidence: 0.6,
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  static Future<List<AiInsight>> _generateAnomalyInsights() async {
    final insights = <AiInsight>[];
    final anomalies = await AnomalyDetector.detectAnomalies();

    for (final anomaly in anomalies) {
      insights.add(AiInsight(
        id: _uuid.v4(),
        title: anomaly['title'] as String,
        description: anomaly['description'] as String,
        insightType: InsightType.anomaly,
        confidence: anomaly['severity'] == 'high' || anomaly['severity'] == 'warning' ? 0.9 : 0.5,
        data: anomaly['data'] as Map<String, dynamic>?,
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  static Future<List<AiInsight>> _generateCorrelationInsights() async {
    final insights = <AiInsight>[];
    final correlations = await CorrelationEngine.findHabitCorrelations();

    // Find strongest positive correlations
    final positiveCorrelations = correlations.entries
        .where((e) => e.value > 0.3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (positiveCorrelations.isNotEmpty) {
      final topCorrelation = positiveCorrelations.first;
      final habits = topCorrelation.key.split('_');
      
      insights.add(AiInsight(
        id: _uuid.v4(),
        title: 'Habit Connection Found!',
        description: 'When you do "${habits[0]}", you\'re more likely to do "${habits[1]}". Try doing them together!',
        insightType: InsightType.correlation,
        confidence: topCorrelation.value.abs(),
        data: {'correlation': topCorrelation.key, 'value': topCorrelation.value},
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  static Future<void> _saveInsight(AiInsight insight) async {
    // Check if similar insight exists recently
    final recentInsights = await DatabaseService.query(
      DatabaseConstants.aiInsightsTable,
      where: 'title = ? AND created_at >= ?',
      whereArgs: [insight.title, DateTime.now().subtract(const Duration(hours: 24)).toIso8601String()],
    );

    if (recentInsights.isEmpty) {
      await DatabaseService.insert(DatabaseConstants.aiInsightsTable, insight.toMap());
    }
  }

  static Future<List<AiInsight>> getRecentInsights({int limit = 10}) async {
    final results = await DatabaseService.query(
      DatabaseConstants.aiInsightsTable,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((map) => AiInsight.fromMap(map)).toList();
  }

  static Future<void> markInsightAsRead(String insightId) async {
    await DatabaseService.update(
      DatabaseConstants.aiInsightsTable,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [insightId],
    );
  }

  static Future<int> getUnreadCount() async {
    final results = await DatabaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.aiInsightsTable} WHERE is_read = 0',
    );
    return results.first['count'] as int? ?? 0;
  }

  static String _getHabitName(String habitId) {
    // This would fetch from database in production
    return 'Daily';
  }
}
