import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int colorIndex;
  final String frequency; // daily, weekly, custom
  final List<int>? weekDays; // 1-7 for weekly
  final int? targetPerWeek; // for custom frequency
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final int xpReward;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastCompletedAt;
  final String? iconName;
  final String skillTree; // Health, Productivity, Learning, Social, Creativity

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.colorIndex,
    required this.frequency,
    this.weekDays,
    this.targetPerWeek,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.xpReward = 10,
    this.isActive = true,
    required this.createdAt,
    this.lastCompletedAt,
    this.iconName,
    required this.skillTree,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    int? colorIndex,
    String? frequency,
    List<int>? weekDays,
    int? targetPerWeek,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletions,
    int? xpReward,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    String? iconName,
    String? skillTree,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      frequency: frequency ?? this.frequency,
      weekDays: weekDays ?? this.weekDays,
      targetPerWeek: targetPerWeek ?? this.targetPerWeek,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      xpReward: xpReward ?? this.xpReward,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      iconName: iconName ?? this.iconName,
      skillTree: skillTree ?? this.skillTree,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'frequency': frequency,
      'weekDays': weekDays?.join(','),
      'targetPerWeek': targetPerWeek,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCompletions': totalCompletions,
      'xpReward': xpReward,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'iconName': iconName,
      'skillTree': skillTree,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      colorIndex: map['colorIndex'] as int,
      frequency: map['frequency'] as String,
      weekDays: map['weekDays'] != null
          ? (map['weekDays'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      targetPerWeek: map['targetPerWeek'] as int?,
      currentStreak: map['currentStreak'] as int,
      bestStreak: map['bestStreak'] as int,
      totalCompletions: map['totalCompletions'] as int,
      xpReward: map['xpReward'] as int,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastCompletedAt: map['lastCompletedAt'] != null
          ? DateTime.parse(map['lastCompletedAt'] as String)
          : null,
      iconName: map['iconName'] as String?,
      skillTree: map['skillTree'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        colorIndex,
        frequency,
        weekDays,
        targetPerWeek,
        currentStreak,
        bestStreak,
        totalCompletions,
        xpReward,
        isActive,
        createdAt,
        lastCompletedAt,
        iconName,
        skillTree,
      ];
}

class HabitLog extends Equatable {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final int xpEarned;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completedAt': completedAt.toIso8601String(),
      'xpEarned': xpEarned,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
      xpEarned: map['xpEarned'] as int,
    );
  }

  @override
  List<Object?> get props => [id, habitId, completedAt, xpEarned];
}
