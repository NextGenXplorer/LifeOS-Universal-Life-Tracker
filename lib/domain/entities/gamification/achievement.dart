import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? icon;
  final String? category;
  final int xpReward;
  final int coinReward;
  final String? requirementType;
  final int requirementValue;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.category,
    this.xpReward = 0,
    this.coinReward = 0,
    this.requirementType,
    this.requirementValue = 0,
    this.isSecret = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? category,
    int? xpReward,
    int? coinReward,
    String? requirementType,
    int? requirementValue,
    bool? isSecret,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      requirementType: requirementType ?? this.requirementType,
      requirementValue: requirementValue ?? this.requirementValue,
      isSecret: isSecret ?? this.isSecret,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'xp_reward': xpReward,
      'coin_reward': coinReward,
      'requirement_type': requirementType,
      'requirement_value': requirementValue,
      'is_secret': isSecret ? 1 : 0,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      category: map['category'] as String?,
      xpReward: map['xp_reward'] as int? ?? 0,
      coinReward: map['coin_reward'] as int? ?? 0,
      requirementType: map['requirement_type'] as String?,
      requirementValue: map['requirement_value'] as int? ?? 0,
      isSecret: (map['is_secret'] as int?) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon, category, xpReward, coinReward];
}

class UserAchievement extends Equatable {
  final String id;
  final String achievementId;
  final DateTime? unlockedAt;
  final int progress;
  final Achievement? achievement;

  const UserAchievement({
    required this.id,
    required this.achievementId,
    this.unlockedAt,
    this.progress = 0,
    this.achievement,
  });

  bool get isUnlocked => unlockedAt != null;

  UserAchievement copyWith({
    String? id,
    String? achievementId,
    DateTime? unlockedAt,
    int? progress,
    Achievement? achievement,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      achievement: achievement ?? this.achievement,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory UserAchievement.fromMap(Map<String, dynamic> map, {Achievement? achievement}) {
    return UserAchievement(
      id: map['id'] as String,
      achievementId: map['achievement_id'] as String,
      unlockedAt: map['unlocked_at'] != null 
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      progress: map['progress'] as int? ?? 0,
      achievement: achievement,
    );
  }

  @override
  List<Object?> get props => [id, achievementId, unlockedAt, progress];
}
