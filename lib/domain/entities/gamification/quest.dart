import 'package:equatable/equatable.dart';

class DailyQuest extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String questType;
  final int targetValue;
  final int xpReward;
  final int coinReward;
  final DateTime expiresAt;
  final bool isDaily;

  const DailyQuest({
    required this.id,
    required this.title,
    this.description,
    required this.questType,
    this.targetValue = 1,
    this.xpReward = 0,
    this.coinReward = 0,
    required this.expiresAt,
    this.isDaily = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  DailyQuest copyWith({
    String? id,
    String? title,
    String? description,
    String? questType,
    int? targetValue,
    int? xpReward,
    int? coinReward,
    DateTime? expiresAt,
    bool? isDaily,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questType: questType ?? this.questType,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      expiresAt: expiresAt ?? this.expiresAt,
      isDaily: isDaily ?? this.isDaily,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quest_type': questType,
      'target_value': targetValue,
      'xp_reward': xpReward,
      'coin_reward': coinReward,
      'expires_at': expiresAt.toIso8601String(),
      'is_daily': isDaily ? 1 : 0,
    };
  }

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      questType: map['quest_type'] as String,
      targetValue: map['target_value'] as int? ?? 1,
      xpReward: map['xp_reward'] as int? ?? 0,
      coinReward: map['coin_reward'] as int? ?? 0,
      expiresAt: DateTime.parse(map['expires_at'] as String),
      isDaily: (map['is_daily'] as int?) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, questType, targetValue, expiresAt];
}

class UserQuest extends Equatable {
  final String id;
  final String questId;
  final int progress;
  final bool completed;
  final DateTime? completedAt;
  final DailyQuest? quest;

  const UserQuest({
    required this.id,
    required this.questId,
    this.progress = 0,
    this.completed = false,
    this.completedAt,
    this.quest,
  });

  double get progressPercentage => quest != null && quest!.targetValue > 0 
      ? (progress / quest!.targetValue).clamp(0.0, 1.0)
      : 0.0;

  UserQuest copyWith({
    String? id,
    String? questId,
    int? progress,
    bool? completed,
    DateTime? completedAt,
    DailyQuest? quest,
  }) {
    return UserQuest(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      quest: quest ?? this.quest,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quest_id': questId,
      'progress': progress,
      'completed': completed ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory UserQuest.fromMap(Map<String, dynamic> map, {DailyQuest? quest}) {
    return UserQuest(
      id: map['id'] as String,
      questId: map['quest_id'] as String,
      progress: map['progress'] as int? ?? 0,
      completed: (map['completed'] as int?) == 1,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      quest: quest,
    );
  }

  @override
  List<Object?> get props => [id, questId, progress, completed];
}
