import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Activity extends Equatable {
  final String id;
  final String name;
  final IconData? icon;
  final Color? color;
  final String? category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.category,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Activity copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        color,
        category,
        isActive,
        createdAt,
        updatedAt,
      ];
}
