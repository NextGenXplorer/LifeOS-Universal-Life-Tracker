import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String? description;
  final double targetValue;
  final double currentValue;
  final String? unit;
  final DateTime? deadline;
  final String? category;
  final Color? color;
  final List<Milestone> milestones;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.unit,
    this.deadline,
    this.category,
    this.color,
    this.milestones = const [],
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? deadline,
    String? category,
    Color? color,
    List<Milestone>? milestones,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      color: color ?? this.color,
      milestones: milestones ?? this.milestones,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      targetValue: (map['target_value'] as num?)?.toDouble() ?? 0,
      currentValue: (map['current_value'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String?,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
      category: map['category'] as String?,
      color: map['color'] != null ? Color(map['color'] as int) : null,
      isCompleted: (map['is_completed'] as int?) == 1,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'color': color?.value,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Milestone {
  final String id;
  final String goalId;
  final String title;
  final String? description;
  final double? targetValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    this.targetValue,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  Milestone copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    double? targetValue,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      targetValue: (map['target_value'] as num?)?.toDouble(),
      isCompleted: (map['is_completed'] as int?) == 1,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'description': description,
      'target_value': targetValue,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
