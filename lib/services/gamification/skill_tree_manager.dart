import 'dart:convert';
import '../../core/constants/database_constants.dart';
import '../../core/services/database_service.dart';
import '../../domain/entities/gamification/skill_tree.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class SkillTreeManager {
  static const _uuid = Uuid();

  // Perks for each skill tree at each level
  static const Map<String, Map<int, List<String>>> _perks = {
    'health': {
      1: ['Energy Boost', 'Morning Motivation'],
      3: ['Exercise Habit', 'Better Sleep'],
      5: ['Nutrition Guide', 'Health Tips'],
      7: ['Mental Clarity', 'Stress Relief'],
      9: ['Wellness Master', 'Life Balance'],
    },
    'productivity': {
      1: ['Quick Start', 'Focus Timer'],
      3: ['Priority Mode', 'Task Batching'],
      5: ['Deep Work', 'Time Blocking'],
      7: ['Productivity Flow', 'Energy Management'],
      9: ['Peak Performance', 'Master Planner'],
    },
    'learning': {
      1: ['Quick Learner', 'Curiosity Spark'],
      3: ['Note Taking', 'Memory Palace'],
      5: ['Spaced Repetition', 'Skill Tracking'],
      7: ['Knowledge Network', 'Learning Roadmap'],
      9: ['Wisdom Keeper', 'Expert Status'],
    },
    'social': {
      1: ['Ice Breaker', 'Active Listener'],
      3: ['Networking Pro', 'Connection Builder'],
      5: ['Influence Builder', 'Relationship Manager'],
      7: ['Community Leader', 'Team Player'],
      9: ['Social Master', 'Relationship Expert'],
    },
    'creativity': {
      1: ['Idea Spark', 'Creative Thinking'],
      3: ['Brainstorming', 'Mind Mapping'],
      5: ['Innovation Mode', 'Problem Solving'],
      7: ['Creative Flow', 'Artistic Expression'],
      9: ['Innovation Master', 'Creative Genius'],
    },
  };

  static Future<List<SkillTree>> getAllSkillTrees() async {
    final results = await DatabaseService.query(DatabaseConstants.skillTreesTable);
    return results.map((map) => SkillTree.fromMap(map)).toList();
  }

  static Future<SkillTree?> getSkillTree(String id) async {
    final results = await DatabaseService.query(
      DatabaseConstants.skillTreesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return SkillTree.fromMap(results.first);
  }

  static Future<UserSkill?> getUserSkill(String skillTreeId) async {
    final results = await DatabaseService.query(
      DatabaseConstants.userSkillsTable,
      where: 'skill_tree_id = ?',
      whereArgs: [skillTreeId],
    );
    if (results.isEmpty) return null;
    return UserSkill.fromMap(results.first);
  }

  static Future<List<UserSkill>> getAllUserSkills() async {
    final results = await DatabaseService.query(DatabaseConstants.userSkillsTable);
    return results.map((map) => UserSkill.fromMap(map)).toList();
  }

  static Future<UserSkill> getOrCreateUserSkill(String skillTreeId) async {
    final existing = await getUserSkill(skillTreeId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final userSkill = UserSkill(
      id: _uuid.v4(),
      skillTreeId: skillTreeId,
      currentLevel: 0,
      xpInSkill: 0,
      unlockedPerks: [],
      createdAt: now,
      updatedAt: now,
    );

    await DatabaseService.insert(DatabaseConstants.userSkillsTable, userSkill.toMap());
    return userSkill;
  }

  static Future<UserSkill> addSkillXp(String skillTreeId, int xp) async {
    final userSkill = await getOrCreateUserSkill(skillTreeId);
    final newXp = userSkill.xpInSkill + xp;
    final newLevel = UserSkill.calculateSkillLevelFromXp(newXp);

    // Check for new perks
    List<String> newPerks = List.from(userSkill.unlockedPerks);
    for (int level = userSkill.currentLevel + 1; level <= newLevel; level++) {
      final perks = _perks[skillTreeId]?[level] ?? [];
      for (final perk in perks) {
        if (!newPerks.contains(perk)) {
          newPerks.add(perk);
        }
      }
    }

    final updatedSkill = userSkill.copyWith(
      xpInSkill: newXp,
      currentLevel: newLevel.clamp(0, 10),
      unlockedPerks: newPerks,
      updatedAt: DateTime.now(),
    );

    await DatabaseService.update(
      DatabaseConstants.userSkillsTable,
      updatedSkill.toMap(),
      where: 'id = ?',
      whereArgs: [userSkill.id],
    );

    return updatedSkill;
  }

  static List<String> getAvailablePerks(String skillTreeId, int level) {
    return _perks[skillTreeId]?[level] ?? [];
  }

  static Future<Map<String, dynamic>> getFullSkillTreeData(String skillTreeId) async {
    final skillTree = await getSkillTree(skillTreeId);
    final userSkill = await getUserSkill(skillTreeId);
    
    return {
      'tree': skillTree,
      'userSkill': userSkill,
      'availablePerks': userSkill != null 
          ? getAvailablePerks(skillTreeId, userSkill.currentLevel + 1)
          : [],
    };
  }

  static Future<List<Map<String, dynamic>>> getAllSkillTreesWithProgress() async {
    final trees = await getAllSkillTrees();
    final List<Map<String, dynamic>> result = [];

    for (final tree in trees) {
      final userSkill = await getUserSkill(tree.id);
      result.add({
        'tree': tree,
        'userSkill': userSkill,
        'progress': userSkill?.levelProgress ?? 0.0,
        'level': userSkill?.currentLevel ?? 0,
      });
    }

    return result;
  }

  static IconData getSkillIcon(String category) {
    switch (category) {
      case 'health':
        return Icons.favorite;
      case 'productivity':
        return Icons.speed;
      case 'learning':
        return Icons.school;
      case 'social':
        return Icons.people;
      case 'creativity':
        return Icons.palette;
      default:
        return Icons.star;
    }
  }

  static Color getSkillColor(String category) {
    switch (category) {
      case 'health':
        return const Color(0xFF00BFA6);
      case 'productivity':
        return const Color(0xFF6C63FF);
      case 'learning':
        return const Color(0xFFFFA726);
      case 'social':
        return const Color(0xFF4CAF50);
      case 'creativity':
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
