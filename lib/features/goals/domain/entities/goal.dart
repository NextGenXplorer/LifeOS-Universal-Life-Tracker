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

  double get progress => targetValue > 0 ? (currentValue / targetValue) : 0;

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
}

class Milestone {
  final String id;
  final String title;
  final String? description;
  final double? targetValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.title,
    this.description,
    this.targetValue,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });
}
