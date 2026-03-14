import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/domain/entities/task.dart';
import 'package:lifeos/presentation/blocs/task/task_bloc.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is TaskLoaded) {
          return _buildContent(context, state);
        }

        if (state is TaskError) {
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

  Widget _buildContent(BuildContext context, TaskLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(state),
        ),

        // Overdue Tasks
        if (state.overdueTasks.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Overdue',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTaskCard(context, state.overdueTasks[index], isOverdue: true),
                childCount: state.overdueTasks.length,
              ),
            ),
          ),
        ],

        // Today's Tasks
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Today',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        if (state.pendingTasks.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTaskCard(context, state.pendingTasks[index]),
                childCount: state.pendingTasks.length,
              ),
            ),
          ),

        // Completed Tasks
        if (state.completedTasks.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Completed',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTaskCard(context, state.completedTasks[index], isCompleted: true),
                childCount: state.completedTasks.length.clamp(0, 5),
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader(TaskLoaded state) {
    final completionRate = state.pendingCount + state.completedToday > 0
        ? state.completedToday / (state.pendingCount + state.completedToday)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.completedToday}/${state.pendingCount + state.completedToday} completed',
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
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: completionRate,
                      strokeWidth: 6,
                      backgroundColor: AppColors.inputBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  ),
                  Text(
                    '${(completionRate * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
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

  Widget _buildTaskCard(BuildContext context, Task task, {bool isOverdue = false, bool isCompleted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoGlassCard(
        child: InkWell(
          onTap: () {
            if (!isCompleted) {
              context.read<TaskBloc>().add(CompleteTask(task.id));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                // Task info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChip(
                            _getPriorityLabel(task.priority),
                            _getPriorityColor(task.priority),
                          ),
                          const SizedBox(width: 8),
                          if (task.dueDate != null)
                            _buildChip(
                              _formatDueDate(task.dueDate!),
                              isOverdue ? AppColors.error : AppColors.textTertiary,
                            ),
                          const Spacer(),
                          Text(
                            '+${task.xpReward} XP',
                            style: const TextStyle(
                              color: AppColors.xpGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Checkbox
                GestureDetector(
                  onTap: () {
                    context.read<TaskBloc>().add(
                          isCompleted ? UncompleteTask(task.id) : CompleteTask(task.id),
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            color: AppColors.success,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No pending tasks for today',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.error;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.medium:
        return AppColors.secondary;
      case TaskPriority.low:
        return AppColors.textTertiary;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    
    if (dueDate == today) return 'Today';
    if (dueDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dueDate.isBefore(today)) return 'Overdue';
    
    return '${date.month}/${date.day}';
  }
}
