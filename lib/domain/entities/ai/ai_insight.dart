import 'dart:convert';
import 'package:equatable/equatable.dart';

enum InsightType {
  habitPrediction,
  productivity,
  moodForecast,
  anomaly,
  correlation,
  suggestion,
}

class AiInsight extends Equatable {
  final String id;
  final String title;
  final String description;
  final InsightType insightType;
  final double confidence;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  const AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.insightType,
    this.confidence = 0.0,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  AiInsight copyWith({
    String? id,
    String? title,
    String? description,
    InsightType? insightType,
    double? confidence,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AiInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      insightType: insightType ?? this.insightType,
      confidence: confidence ?? this.confidence,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'insight_type': insightType.name,
      'confidence': confidence,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory AiInsight.fromMap(Map<String, dynamic> map) {
    return AiInsight(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      insightType: InsightType.values.firstWhere(
        (e) => e.name == map['insight_type'],
        orElse: () => InsightType.suggestion,
      ),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      data: map['data'] != null 
          ? jsonDecode(map['data'] as String) as Map<String, dynamic>
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: (map['is_read'] as int?) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, insightType, createdAt, isRead];
}

class PatternLog extends Equatable {
  final String id;
  final String patternType;
  final Map<String, dynamic>? data;
  final DateTime recordedAt;

  const PatternLog({
    required this.id,
    required this.patternType,
    this.data,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pattern_type': patternType,
      'data': data != null ? jsonEncode(data) : null,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory PatternLog.fromMap(Map<String, dynamic> map) {
    return PatternLog(
      id: map['id'] as String,
      patternType: map['pattern_type'] as String,
      data: map['data'] != null 
          ? jsonDecode(map['data'] as String) as Map<String, dynamic>
          : null,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, patternType, recordedAt];
}
