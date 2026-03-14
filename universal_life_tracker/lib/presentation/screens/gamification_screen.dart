import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/presentation/blocs/gamification/gamification_bloc.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';
import 'package:lifeos/presentation/widgets/charts/xp_progress_chart.dart';
import 'package:confetti/confetti.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamificationBloc, GamificationState>(
      listener: (context, state) {
        if (state is AchievementUnlocked) {
          _confettiController.play();
        }
      },
      builder: (context, state) {
        if (state is GamificationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is GamificationLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, GamificationLoaded state) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Level Header
            SliverToBoxAdapter(
              child: _buildLevelHeader(state),
            ),

            // Tab Bar
            SliverToBoxAdapter(
              child: _buildTabBar(),
            ),

            // Tab Views
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLevelTab(state),
                  _buildAchievementsTab(state),
                  _buildSkillsTab(state),
                ],
              ),
            ),
          ],
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.xpGold,
              AppColors.primary,
              AppColors.secondary,
              AppColors.levelDiamond,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelHeader(GamificationLoaded state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.auroraGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Level badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.xpGold,
                  AppColors.levelGold.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.xpGold.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${state.profile.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getLevelTitle(state.profile.level),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.profile.totalXp} Total XP',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // XP Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.profile.currentXp} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${state.xpToNextLevel} XP to Level ${state.profile.level + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: state.levelProgressPercent / 100,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        tabs: const [
          Tab(text: 'Level'),
          Tab(text: 'Badges'),
          Tab(text: 'Skills'),
        ],
      ),
    );
  }

  Widget _buildLevelTab(GamificationLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Day Streak',
                  '${state.profile.currentDayStreak}',
                  Icons.local_fire_department,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Best Streak',
                  '${state.profile.bestDayStreak}',
                  Icons.whatshot,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Habits',
                  '${state.profile.totalHabitsCompleted}',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  '${state.profile.totalTasksCompleted}',
                  Icons.task_alt,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Coins',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.xpGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.xpGold,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Text(
                  '${state.profile.coins}',
                  style: const TextStyle(
                    color: AppColors.xpGold,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  'coins',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return NeoGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationLoaded state) {
    final unlocked = state.unlockedAchievements;
    final locked = state.allAchievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unlocked
          if (unlocked.isNotEmpty) ...[
            const Text(
              'Unlocked',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: unlocked.map((a) => _buildAchievementBadge(a, true)).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Locked
          const Text(
            'Locked',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: locked.map((a) => _buildAchievementBadge(a, false)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(dynamic achievement, bool unlocked) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.cardBackground : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? AppColors.xpGold : AppColors.divider,
          width: unlocked ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getAchievementIcon(achievement.iconName),
            color: unlocked ? AppColors.xpGold : AppColors.textTertiary,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.name,
            style: TextStyle(
              color: unlocked ? AppColors.textPrimary : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(GamificationLoaded state) {
    final skills = state.allSkills;
    final skillTrees = <String, List<dynamic>>{};
    
    for (final skill in skills) {
      skillTrees.putIfAbsent(skill.treeName, () => []).add(skill);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: skillTrees.entries.map((entry) {
          return _buildSkillTree(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildSkillTree(String name, List<dynamic> skills) {
    final colors = {
      'Health': AppColors.healthSkill,
      'Productivity': AppColors.productivitySkill,
      'Learning': AppColors.learningSkill,
      'Social': AppColors.socialSkill,
      'Creativity': AppColors.creativitySkill,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (colors[name] ?? AppColors.primary).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (colors[name] ?? AppColors.primary).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSkillTreeIcon(name),
                  color: colors[name] ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...skills.take(3).map((skill) => _buildSkillProgress(skill, colors[name] ?? AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSkillProgress(dynamic skill, Color color) {
    final progress = skill.currentXp / skill.xpToNextLevel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Lv.${skill.level}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.inputBackground,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 80) return 'Transcendent';
    if (level >= 60) return 'Legendary';
    if (level >= 50) return 'Master';
    if (level >= 40) return 'Expert';
    if (level >= 30) return 'Advanced';
    if (level >= 20) return 'Intermediate';
    if (level >= 10) return 'Novice';
    return 'Beginner';
  }

  IconData _getAchievementIcon(String? name) {
    switch (name) {
      case 'star':
        return Icons.star;
      case 'list':
        return Icons.list;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'check_circle':
        return Icons.check_circle;
      case 'done_all':
        return Icons.done_all;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }

  IconData _getSkillTreeIcon(String name) {
    switch (name) {
      case 'Health':
        return Icons.favorite;
      case 'Productivity':
        return Icons.speed;
      case 'Learning':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Creativity':
        return Icons.brush;
      default:
        return Icons.bolt;
    }
  }
}
