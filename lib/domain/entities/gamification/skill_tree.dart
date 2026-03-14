import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SkillTree extends Equatable {
  final String id;
  final String name;
  final String category;
  final IconData? icon;
  final Color? color;
  final int maxLevel;
  final String? description;
  final List<String> branches;
  final bool isActive;

  const SkillTree({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
    this.color,
    this.maxLevel = 10,
    this.description,
    this.branches = const [],
    this.isActive = true,
  });

  SkillTree copyWith({
    String? id,
    String? name,
    String? category,
    IconData? icon,
    Color? color,
    int? maxLevel,
    String? description,
    List<String>? branches,
    bool? isActive,
  }) {
    return SkillTree(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      maxLevel: maxLevel ?? this.maxLevel,
      description: description ?? this.description,
      branches: branches ?? this.branches,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon?.codePoint.toString(),
      'color': color?.value,
      'max_level': maxLevel,
      'description': description,
      'branches': branches.join(','),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory SkillTree.fromMap(Map<String, dynamic> map) {
    return SkillTree(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      icon: map['icon'] != null ? IconData(int.parse(map['icon'] as String), fontFamily: 'MaterialIcons') : null,
      color: map['color'] != null ? Color(map['color'] as int) : null,
      maxLevel: map['max_level'] as int? ?? 10,
      description: map['description'] as String?,
      branches: (map['branches'] as String?)?.split(',') ?? [],
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  @override
  List<Object?> get props => [id, name, category, icon, color, maxLevel, branches, isActive];
}

class UserSkill extends Equatable {
  final String id;
  final String skillTreeId;
  final int currentLevel;
  final int xpInSkill;
  final List<String> unlockedPerks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSkill({
    required this.id,
    required this.skillTreeId,
    this.currentLevel = 0,
    this.xpInSkill = 0,
    this.unlockedPerks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get xpForNextLevel => _calculateXpForLevel(currentLevel + 1);
  int get xpProgressInLevel => xpInSkill - _calculateXpForLevel(currentLevel);
  int get xpNeededForNextLevel => _calculateXpForLevel(currentLevel + 1) - _calculateXpForLevel(currentLevel);
  double get levelProgress => xpNeededForNextLevel > 0 ? xpProgressInLevel / xpNeededForNextLevel : 0;

  static int _calculateXpForLevel(int level) {
    if (level <= 0) return 0;
    return (50 * level * level);
  }

  static int calculateSkillLevelFromXp(int xp) {
    int level = 0;
    while (_calculateXpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  UserSkill copyWith({
    String? id,
    String? skillTreeId,
    int? currentLevel,
    int? xpInSkill,
    List<String>? unlockedPerks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSkill(
      id: id ?? this.id,
      skillTreeId: skillTreeId ?? this.skillTreeId,
      currentLevel: currentLevel ?? this.currentLevel,
      xpInSkill: xpInSkill ?? this.xpInSkill,
      unlockedPerks: unlockedPerks ?? this.unlockedPerks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skill_tree_id': skillTreeId,
      'current_level': currentLevel,
      'xp_in_skill': xpInSkill,
      'unlocked_perks': unlockedPerks.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserSkill.fromMap(Map<String, dynamic> map) {
    return UserSkill(
      id: map['id'] as String,
      skillTreeId: map['skill_tree_id'] as String,
      currentLevel: map['current_level'] as int? ?? 0,
      xpInSkill: map['xp_in_skill'] as int? ?? 0,
      unlockedPerks: (map['unlocked_perks'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, skillTreeId, currentLevel, xpInSkill, unlockedPerks];
}
