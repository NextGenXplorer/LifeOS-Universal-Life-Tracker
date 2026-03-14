import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/domain/entities/habit.dart';
import 'package:lifeos/presentation/blocs/habit/habit_bloc.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';
import 'package:lifeos/presentation/widgets/animations/pulse_animation.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state is HabitLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is HabitLoaded) {
          return _buildContent(context, state);
        }

        if (state is HabitError) {
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

  Widget _buildContent(BuildContext context, HabitLoaded state) {
    final activeHabits = state.habits.where((h) => h.isActive).toList();
    final completedToday = state.completedToday;
    final totalHabits = activeHabits.length;

    return CustomScrollView(
      slivers: [
        // Progress Header
        SliverToBoxAdapter(
          child: _buildProgressHeader(completedToday, totalHabits),
        ),

        // Quick Stats
        SliverToBoxAdapter(
          child: _buildQuickStats(state),
        ),

        // Section Title
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Today\'s Habits',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Habits List
        if (activeHabits.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyState(context),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habit = activeHabits[index];
                  final isCompleted = state.isHabitCompletedToday(habit.id);
                  return _buildHabitCard(context, habit, isCompleted);
                },
                childCount: activeHabits.length,
              ),
            ),
          ),

        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final isPerfect = completed == total && total > 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPerfect
              ? [AppColors.success.withOpacity(0.3), AppColors.primary.withOpacity(0.3)]
              : [AppColors.cardBackground, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPerfect ? AppColors.success : AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPerfect ? 'Perfect Day!' : 'Daily Progress',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of $total habits completed',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.inputBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPerfect ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(HabitLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: NeoGlassCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.habits.fold<int>(0, (max, h) => h.currentStreak > max ? h.currentStreak : max)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Best Streak',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NeoGlassCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.habits.fold<int>(0, (sum, h) => sum + h.totalCompletions)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Total Done',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NeoGlassCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.add_task,
                    color: AppColors.secondary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.habits.length}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoGlassCard(
        child: InkWell(
          onTap: () {
            if (!isCompleted) {
              context.read<HabitBloc>().add(CompleteHabit(habit.id));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Completion indicator
                PulseAnimation(
                  isAnimating: !isCompleted,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.habitColors[habit.colorIndex % AppColors.habitColors.length]
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : _getHabitIcon(habit.iconName),
                      color: isCompleted
                          ? Colors.white
                          : AppColors.habitColors[habit.colorIndex % AppColors.habitColors.length],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.textTertiary,
                        ),
                      ),
                      if (habit.description != null && habit.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            habit.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: habit.currentStreak > 0
                                ? AppColors.accent
                                : AppColors.textTertiary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} day streak',
                            style: TextStyle(
                              color: habit.currentStreak > 0
                                  ? AppColors.accent
                                  : AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.star,
                            color: AppColors.xpGold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${habit.xpReward} XP',
                            style: const TextStyle(
                              color: AppColors.xpGold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Completion checkbox
                GestureDetector(
                  onTap: () {
                    context.read<HabitBloc>().add(
                          isCompleted ? UncompleteHabit(habit.id) : CompleteHabit(habit.id),
                        );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? AppColors.success : AppColors.textTertiary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_task,
            color: AppColors.textTertiary,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start building good habits to level up!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Show add habit dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Habit'),
          ),
        ],
      ),
    );
  }

  IconData _getHabitIcon(String? iconName) {
    switch (iconName) {
      case 'fitness':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'meditation':
        return Icons.self_improvement;
      case 'water':
        return Icons.water_drop;
      case 'sleep':
        return Icons.bedtime;
      case 'food':
        return Icons.restaurant;
      case 'walk':
        return Icons.directions_walk;
      case 'code':
        return Icons.code;
      default:
        return Icons.check_circle_outline;
    }
  }
}
