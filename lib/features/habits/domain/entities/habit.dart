import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly, monthly, custom }

class Habit {
  final String id;
  final String title;
  final String? description;
  final IconData? icon;
  final Color? color;
  final HabitFrequency frequency;
  final int targetCount;
  final TimeOfDay? reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.color,
    this.frequency = HabitFrequency.daily,
    this.targetCount = 1,
    this.reminderTime,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}
