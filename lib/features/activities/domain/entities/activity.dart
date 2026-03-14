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

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
