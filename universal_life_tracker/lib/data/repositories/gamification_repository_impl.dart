import 'package:lifeos/domain/entities/gamification.dart';
import 'package:lifeos/domain/repositories/gamification_repository.dart';
import 'package:lifeos/data/datasources/local/app_database.dart';
import 'package:uuid/uuid.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final AppDatabase _database;
  final _uuid = const Uuid();

  GamificationRepositoryImpl(this._database);

  @override
  Future<UserProfile> getUserProfile() async {
    final db = await _database.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: ['default_user']);
    
    if (maps.isEmpty) {
      throw Exception('User profile not found');
    }
    
    return UserProfile.fromMap(maps.first);
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final db = await _database.database;
    await db.update(
      'users',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    return profile;
  }

  @override
  Future<UserProfile> addXp(int xp) async {
    final profile = await getUserProfile();
    var newXp = profile.currentXp + xp;
    var newLevel = profile.level;
    var totalXp = profile.totalXp + xp;
    
    // Check for level up
    while (newXp >= _xpRequiredForLevel(newLevel + 1)) {
      newXp -= _xpRequiredForLevel(newLevel + 1);
      newLevel++;
    }
    
    final updatedProfile = profile.copyWith(
      currentXp: newXp,
      level: newLevel,
      totalXp: totalXp,
      lastActiveAt: DateTime.now(),
    );
    
    return updateUserProfile(updatedProfile);
  }

  int _xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * (1.15 * (level - 1) - 1) / 0.15).round();
  }

  @override
  Future<UserProfile> addCoins(int coins) async {
    final profile = await getUserProfile();
    final updatedProfile = profile.copyWith(
      coins: profile.coins + coins,
    );
    return updateUserProfile(updatedProfile);
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    final db = await _database.database;
    final maps = await db.query('achievements', orderBy: 'category ASC');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  @override
  Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await _database.database;
    final maps = await db.query(
      'achievements',
      where: 'isUnlocked = ?',
      whereArgs: [1],
      orderBy: 'unlockedAt DESC',
    );
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  @override
  Future<Achievement> unlockAchievement(String achievementId) async {
    final db = await _database.database;
    final maps = await db.query(
      'achievements',
      where: 'id = ?',
      whereArgs: [achievementId],
    );
    
    if (maps.isEmpty) {
      throw Exception('Achievement not found');
    }
    
    final achievement = Achievement.fromMap(maps.first);
    
    if (achievement.isUnlocked) {
      return achievement;
    }
    
    final updatedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      progress: achievement.target.toDouble(),
    );
    
    await db.update(
      'achievements',
      updatedAchievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievementId],
    );
    
    // Award XP and coins
    await addXp(achievement.xpReward);
    await addCoins(achievement.coinReward);
    
    return updatedAchievement;
  }

  @override
  Future<Achievement> updateAchievementProgress(String achievementId, double progress) async {
    final db = await _database.database;
    final maps = await db.query(
      'achievements',
      where: 'id = ?',
      whereArgs: [achievementId],
    );
    
    if (maps.isEmpty) {
      throw Exception('Achievement not found');
    }
    
    final achievement = Achievement.fromMap(maps.first);
    final updatedProgress = progress.clamp(0.0, achievement.target.toDouble());
    
    final updatedAchievement = achievement.copyWith(
      progress: updatedProgress,
    );
    
    await db.update(
      'achievements',
      updatedAchievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievementId],
    );
    
    // Auto-unlock if target reached
    if (updatedProgress >= achievement.target && !achievement.isUnlocked) {
      return unlockAchievement(achievementId);
    }
    
    return updatedAchievement;
  }

  @override
  Future<List<Skill>> getAllSkills() async {
    final db = await _database.database;
    final maps = await db.query('skills', orderBy: 'treeName ASC, level ASC');
    return maps.map((map) => Skill.fromMap(map)).toList();
  }

  @override
  Future<List<Skill>> getSkillsByTree(String treeName) async {
    final db = await _database.database;
    final maps = await db.query(
      'skills',
      where: 'treeName = ?',
      whereArgs: [treeName],
      orderBy: 'level ASC',
    );
    return maps.map((map) => Skill.fromMap(map)).toList();
  }

  @override
  Future<Skill> updateSkill(Skill skill) async {
    final db = await _database.database;
    await db.update(
      'skills',
      skill.toMap(),
      where: 'id = ?',
      whereArgs: [skill.id],
    );
    return skill;
  }

  @override
  Future<Skill> addSkillXp(String skillId, int xp) async {
    final db = await _database.database;
    final maps = await db.query(
      'skills',
      where: 'id = ?',
      whereArgs: [skillId],
    );
    
    if (maps.isEmpty) {
      throw Exception('Skill not found');
    }
    
    final skill = Skill.fromMap(maps.first);
    var newXp = skill.currentXp + xp;
    var newLevel = skill.level;
    
    // Check for level up
    while (newXp >= skill.xpToNextLevel && newLevel < skill.maxLevel) {
      newXp -= skill.xpToNextLevel;
      newLevel++;
      // Increase XP requirement for next level
    }
    
    final updatedSkill = skill.copyWith(
      currentXp: newXp,
      level: newLevel,
    );
    
    await db.update(
      'skills',
      updatedSkill.toMap(),
      where: 'id = ?',
      whereArgs: [skillId],
    );
    
    return updatedSkill;
  }

  @override
  Future<Skill> unlockSkill(String skillId) async {
    final db = await _database.database;
    final maps = await db.query(
      'skills',
      where: 'id = ?',
      whereArgs: [skillId],
    );
    
    if (maps.isEmpty) {
      throw Exception('Skill not found');
    }
    
    final skill = Skill.fromMap(maps.first);
    
    if (skill.isUnlocked) {
      return skill;
    }
    
    final updatedSkill = skill.copyWith(isUnlocked: true);
    
    await db.update(
      'skills',
      updatedSkill.toMap(),
      where: 'id = ?',
      whereArgs: [skillId],
    );
    
    return updatedSkill;
  }

  @override
  Future<Map<String, dynamic>> getGamificationStats() async {
    final profile = await getUserProfile();
    final achievements = await getAllAchievements();
    final unlockedAchievements = await getUnlockedAchievements();
    final skills = await getAllSkills();
    
    return {
      'profile': profile,
      'totalAchievements': achievements.length,
      'unlockedAchievements': unlockedAchievements.length,
      'totalSkills': skills.length,
      'averageSkillLevel': skills.isEmpty 
          ? 0.0 
          : skills.map((s) => s.level).reduce((a, b) => a + b) / skills.length,
    };
  }

  @override
  Future<UserProfile> updateDayStreak() async {
    final profile = await getUserProfile();
    final now = DateTime.now();
    final lastActive = profile.lastActiveAt;
    
    final daysDiff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;
    
    int newStreak = profile.currentDayStreak;
    
    if (daysDiff == 1) {
      newStreak += 1;
    } else if (daysDiff > 1) {
      newStreak = 1;
    }
    
    final updatedProfile = profile.copyWith(
      currentDayStreak: newStreak,
      bestDayStreak: newStreak > profile.bestDayStreak ? newStreak : profile.bestDayStreak,
      lastActiveAt: now,
    );
    
    return updateUserProfile(updatedProfile);
  }
}
