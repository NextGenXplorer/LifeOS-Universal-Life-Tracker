import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final String id;
  final int currentLevel;
  final int totalXp;
  final int coins;
  final int streakDays;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    required this.id,
    this.currentLevel = 1,
    this.totalXp = 0,
    this.coins = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  int get xpForCurrentLevel => _calculateXpForLevel(currentLevel);
  int get xpForNextLevel => _calculateXpForLevel(currentLevel + 1);
  int get xpProgressInLevel => totalXp - xpForCurrentLevel;
  int get xpNeededForNextLevel => xpForNextLevel - xpForCurrentLevel;
  double get levelProgress => xpProgressInLevel / xpNeededForNextLevel;

  static int _calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    return ((100 * (level - 1) * (level - 1)) / 2).round();
  }

  static int calculateLevelFromXp(int xp) {
    int level = 1;
    while (_calculateXpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  UserStats copyWith({
    String? id,
    int? currentLevel,
    int? totalXp,
    int? coins,
    int? streakDays,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      id: id ?? this.id,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXp: totalXp ?? this.totalXp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_level': currentLevel,
      'total_xp': totalXp,
      'coins': coins,
      'streak_days': streakDays,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id'] as String,
      currentLevel: map['current_level'] as int? ?? 1,
      totalXp: map['total_xp'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      streakDays: map['streak_days'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      lastActivityDate: map['last_activity_date'] != null 
          ? DateTime.parse(map['last_activity_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, currentLevel, totalXp, coins, streakDays, longestStreak];
}
