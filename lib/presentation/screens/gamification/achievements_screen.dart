import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/gamification/achievement_engine.dart';
import '../../../domain/entities/gamification/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        actions: [
          FutureBuilder<int>(
            future: _getAchievementStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final unlocked = snapshot.data!;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$unlocked Unlocked',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Achievement>>(
        future: AchievementEngine.getAllAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No achievements yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final achievements = snapshot.data!;
          
          // Group by category
          final grouped = <String, List<Achievement>>{};
          for (final achievement in achievements) {
            final category = achievement.category ?? 'other';
            grouped.putIfAbsent(category, () => []).add(achievement);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _formatCategory(entry.key),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...entry.value.map((a) => _buildAchievementCard(context, a)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<int> _getAchievementStats() async {
    return await AchievementEngine.getUnlockedCount();
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: Icon(
                _getIcon(achievement.icon),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (achievement.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        achievement.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (achievement.xpReward > 0)
                        _buildRewardChip(
                          Icons.star,
                          '${achievement.xpReward} XP',
                          AppColors.warning,
                        ),
                      if (achievement.coinReward > 0)
                        _buildRewardChip(
                          Icons.monetization_on,
                          '${achievement.coinReward}',
                          AppColors.accent,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'task_alt':
        return Icons.task_alt;
      case 'verified':
        return Icons.verified;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'psychology':
        return Icons.psychology;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'habit':
        return 'Habits';
      case 'streak':
        return 'Streaks';
      case 'level':
        return 'Levels';
      case 'task':
        return 'Tasks';
      case 'expense':
        return 'Expenses';
      case 'skill':
        return 'Skills';
      case 'daily':
        return 'Daily';
      default:
        return 'Other';
    }
  }
}
