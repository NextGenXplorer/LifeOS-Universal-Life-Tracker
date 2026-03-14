import 'package:lifeos/domain/entities/gamification.dart';

abstract class GamificationRepository {
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<UserProfile> addXp(int xp);
  Future<UserProfile> addCoins(int coins);
  Future<List<Achievement>> getAllAchievements();
  Future<List<Achievement>> getUnlockedAchievements();
  Future<Achievement> unlockAchievement(String achievementId);
  Future<Achievement> updateAchievementProgress(String achievementId, double progress);
  Future<List<Skill>> getAllSkills();
  Future<List<Skill>> getSkillsByTree(String treeName);
  Future<Skill> updateSkill(Skill skill);
  Future<Skill> addSkillXp(String skillId, int xp);
  Future<Skill> unlockSkill(String skillId);
  Future<Map<String, dynamic>> getGamificationStats();
  Future<UserProfile> updateDayStreak();
}
