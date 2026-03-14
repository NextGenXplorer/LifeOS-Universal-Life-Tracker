import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/presentation/blocs/insights/insights_bloc.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        if (state is InsightsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is InsightsLoaded) {
          return _buildContent(context, state);
        }

        if (state is InsightsError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, InsightsLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(state),
        ),

        // Weekly Summary
        SliverToBoxAdapter(
          child: _buildWeeklySummary(state.weeklySummary),
        ),

        // Recommendations
        if (state.recommendations.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildRecommendations(state.recommendations),
          ),

        // Habit Insights
        if (state.habitInsights.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildHabitInsights(state.habitInsights),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader(InsightsLoaded state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'AI-powered analysis of your habits',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(Map<String, dynamic> summary) {
    final habitsCompleted = summary['habitsCompleted'] ?? 0;
    final tasksCompleted = summary['tasksCompleted'] ?? 0;
    final xpEarned = summary['xpEarned'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Habits',
                  '$habitsCompleted',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Tasks',
                  '$tasksCompleted',
                  Icons.task_alt,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'XP',
                  '$xpEarned',
                  Icons.star,
                  AppColors.xpGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return NeoGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
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

  Widget _buildRecommendations(List<Map<String, dynamic>> recommendations) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.take(3).map((r) => _buildRecommendationCard(r)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    final priority = recommendation['priority'] ?? 'medium';
    final color = priority == 'high' ? AppColors.error : (priority == 'medium' ? AppColors.warning : AppColors.info);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getRecommendationIcon(recommendation['type']),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['description'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitInsights(List<Map<String, dynamic>> insights) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Analysis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...insights.take(3).map((i) => _buildHabitInsightCard(i)),
        ],
      ),
    );
  }

  Widget _buildHabitInsightCard(Map<String, dynamic> insight) {
    final completionRate = (insight['completionRate'] as double? ?? 0) * 100;
    final streak = insight['currentStreak'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insight['habitName'] ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              minHeight: 6,
              backgroundColor: AppColors.inputBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                completionRate >= 70 ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${completionRate.toStringAsFixed(0)}% completion rate',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecommendationIcon(String? type) {
    switch (type) {
      case 'habit':
        return Icons.check_circle;
      case 'streak':
        return Icons.local_fire_department;
      case 'perfect_day':
        return Icons.verified;
      default:
        return Icons.lightbulb;
    }
  }
}
