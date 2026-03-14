import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final int level;
  final int currentXp;
  final int totalXp;
  final int coins;
  final int totalHabitsCompleted;
  final int totalTasksCompleted;
  final int currentDayStreak;
  final int bestDayStreak;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String avatarId;
  final Map<String, int> skillLevels;
  final Map<String, int> skillXp;

  const UserProfile({
    required this.id,
    required this.username,
    this.level = 1,
    this.currentXp = 0,
    this.totalXp = 0,
    this.coins = 0,
    this.totalHabitsCompleted = 0,
    this.totalTasksCompleted = 0,
    this.currentDayStreak = 0,
    this.bestDayStreak = 0,
    required this.createdAt,
    required this.lastActiveAt,
    this.avatarId = 'default',
    this.skillLevels = const {},
    this.skillXp = const {},
  });

  int get xpToNextLevel {
    return _calculateXpForLevel(level + 1) - _calculateXpForLevel(level);
  }

  double get levelProgress {
    final levelStartXp = _calculateXpForLevel(level);
    final nextLevelXp = _calculateXpForLevel(level + 1);
    return (currentXp - levelStartXp) / (nextLevelXp - levelStartXp);
  }

  int _calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * (1.15 * (level - 1) - 1) / 0.15).round();
  }

  UserProfile copyWith({
    String? id,
    String? username,
    int? level,
    int? currentXp,
    int? totalXp,
    int? coins,
    int? totalHabitsCompleted,
    int? totalTasksCompleted,
    int? currentDayStreak,
    int? bestDayStreak,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? avatarId,
    Map<String, int>? skillLevels,
    Map<String, int>? skillXp,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      coins: coins ?? this.coins,
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentDayStreak: currentDayStreak ?? this.currentDayStreak,
      bestDayStreak: bestDayStreak ?? this.bestDayStreak,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      avatarId: avatarId ?? this.avatarId,
      skillLevels: skillLevels ?? this.skillLevels,
      skillXp: skillXp ?? this.skillXp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'level': level,
      'currentXp': currentXp,
      'totalXp': totalXp,
      'coins': coins,
      'totalHabitsCompleted': totalHabitsCompleted,
      'totalTasksCompleted': totalTasksCompleted,
      'currentDayStreak': currentDayStreak,
      'bestDayStreak': bestDayStreak,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'avatarId': avatarId,
      'skillLevels': skillLevels.entries.map((e) => '${e.key}:${e.value}').join(','),
      'skillXp': skillXp.entries.map((e) => '${e.key}:${e.value}').join(','),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      level: map['level'] as int,
      currentXp: map['currentXp'] as int,
      totalXp: map['totalXp'] as int,
      coins: map['coins'] as int,
      totalHabitsCompleted: map['totalHabitsCompleted'] as int,
      totalTasksCompleted: map['totalTasksCompleted'] as int,
      currentDayStreak: map['currentDayStreak'] as int,
      bestDayStreak: map['bestDayStreak'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActiveAt: DateTime.parse(map['lastActiveAt'] as String),
      avatarId: map['avatarId'] as String,
      skillLevels: _parseMap(map['skillLevels'] as String),
      skillXp: _parseMap(map['skillXp'] as String),
    );
  }

  static Map<String, int> _parseMap(String data) {
    if (data.isEmpty) return {};
    final map = <String, int>{};
    for (final entry in data.split(',')) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        level,
        currentXp,
        totalXp,
        coins,
        totalHabitsCompleted,
        totalTasksCompleted,
        currentDayStreak,
        bestDayStreak,
        createdAt,
        lastActiveAt,
        avatarId,
        skillLevels,
        skillXp,
      ];
}

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final int xpReward;
  final int coinReward;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress;
  final int target;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.xpReward = 50,
    this.coinReward = 10,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
    this.target = 1,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? xpReward,
    int? coinReward,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'iconName': iconName,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      xpReward: map['xpReward'] as int,
      coinReward: map['coinReward'] as int,
      iconName: map['iconName'] as String,
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
      progress: (map['progress'] as num).toDouble(),
      target: map['target'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        xpReward,
        coinReward,
        iconName,
        isUnlocked,
        unlockedAt,
        progress,
        target,
      ];
}

class Skill extends Equatable {
  final String id;
  final String name;
  final String treeName;
  final String description;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int maxLevel;
  final bool isUnlocked;
  final String iconName;
  final List<String> prerequisiteSkills;
  final List<String> unlockedRecipes;

  const Skill({
    required this.id,
    required this.name,
    required this.treeName,
    required this.description,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.maxLevel = 10,
    this.isUnlocked = true,
    required this.iconName,
    this.prerequisiteSkills = const [],
    this.unlockedRecipes = const [],
  });

  double get levelProgress => currentXp / xpToNextLevel;

  Skill copyWith({
    String? id,
    String? name,
    String? treeName,
    String? description,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? maxLevel,
    bool? isUnlocked,
    String? iconName,
    List<String>? prerequisiteSkills,
    List<String>? unlockedRecipes,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      treeName: treeName ?? this.treeName,
      description: description ?? this.description,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      iconName: iconName ?? this.iconName,
      prerequisiteSkills: prerequisiteSkills ?? this.prerequisiteSkills,
      unlockedRecipes: unlockedRecipes ?? this.unlockedRecipes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'treeName': treeName,
      'description': description,
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'maxLevel': maxLevel,
      'isUnlocked': isUnlocked ? 1 : 0,
      'iconName': iconName,
      'prerequisiteSkills': prerequisiteSkills.join(','),
      'unlockedRecipes': unlockedRecipes.join(','),
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as String,
      name: map['name'] as String,
      treeName: map['treeName'] as String,
      description: map['description'] as String,
      level: map['level'] as int,
      currentXp: map['currentXp'] as int,
      xpToNextLevel: map['xpToNextLevel'] as int,
      maxLevel: map['maxLevel'] as int,
      isUnlocked: map['isUnlocked'] == 1,
      iconName: map['iconName'] as String,
      prerequisiteSkills: (map['prerequisiteSkills'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList(),
      unlockedRecipes: (map['unlockedRecipes'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        treeName,
        description,
        level,
        currentXp,
        xpToNextLevel,
        maxLevel,
        isUnlocked,
        iconName,
        prerequisiteSkills,
        unlockedRecipes,
      ];
}
