import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/gamification/level_system.dart';
import '../../../domain/entities/gamification/user_stats.dart';
import '../widgets/xp_bar.dart';
import '../widgets/level_indicator.dart';

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  return await LevelSystem.getOrCreateUserStats();
});

class DashboardStatsCard extends ConsumerWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) => _buildStatsCard(context, stats),
      loading: () => _buildLoadingCard(context),
      error: (e, _) => _buildErrorCard(context, e.toString()),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserStats stats) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.secondary.withOpacity(0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LevelSystem.getLevelTitle(stats.currentLevel),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${stats.currentLevel}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              LevelIndicator(
                level: stats.currentLevel,
                size: 60,
              ),
            ],
          ),
          const SizedBox(height: 16),
          XpBar(
            currentXp: stats.xpProgressInLevel,
            requiredXp: stats.xpNeededForNextLevel,
            showLabel: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                Icons.local_fire_department,
                '${stats.streakDays}',
                'Day Streak',
                AppColors.warning,
              ),
              _buildStatItem(
                context,
                Icons.monetization_on,
                '${stats.coins}',
                'Coins',
                AppColors.accent,
              ),
              _buildStatItem(
                context,
                Icons.star,
                '${stats.totalXp}',
                'Total XP',
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Error loading stats',
          style: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
