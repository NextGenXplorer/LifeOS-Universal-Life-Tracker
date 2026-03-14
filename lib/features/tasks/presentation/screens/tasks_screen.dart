import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/constants/database_constants.dart';
import '../../domain/entities/task.dart';
import '../../../../services/gamification/level_system.dart';
import '../../../../services/gamification/reward_service.dart';

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final results = await DatabaseService.query(
    DatabaseConstants.tasksTable,
    orderBy: 'created_at DESC',
  );
  return results.map((map) => Task.fromMap(map)).toList();
});

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? _buildEmptyState(context)
            : _buildTasksList(context, tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<Task> tasks) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingTasks.isNotEmpty) ...[
          Text(
            'Pending',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...pendingTasks.map((task) => _TaskCard(task: task)),
        ],
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Completed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...completedTasks.map((task) => _TaskCard(task: task)),
        ],
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddTaskDialog(),
    );
  }
}

class _TaskCard extends ConsumerStatefulWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  Future<void> _toggleCompletion() async {
    final now = DateTime.now();

    if (_isCompleted) {
      // Mark as incomplete
      await DatabaseService.update(
        DatabaseConstants.tasksTable,
        {'completed_at': null, 'updated_at': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [widget.task.id],
      );
    } else {
      // Mark as complete
      await DatabaseService.update(
        DatabaseConstants.tasksTable,
        {'completed_at': now.toIso8601String(), 'updated_at': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [widget.task.id],
      );

      // Award rewards
      await RewardService.awardTaskCompletionRewards(priority: widget.task.priority.index);
    }

    setState(() => _isCompleted = !_isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await DatabaseService.delete(
          DatabaseConstants.tasksTable,
          where: 'id = ?',
          whereArgs: [widget.task.id],
        );
      },
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        onTap: _toggleCompletion,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: _isCompleted ? AppColors.success : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: _isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: _isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (widget.task.description != null)
                    Text(
                      widget.task.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _PriorityIndicator(priority: widget.task.priority),
          ],
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.urgent:
        color = AppColors.error;
      case TaskPriority.high:
        color = AppColors.warning;
      case TaskPriority.medium:
        color = AppColors.info;
      case TaskPriority.low:
        color = AppColors.success;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) return;

    final now = DateTime.now();
    await DatabaseService.insert(DatabaseConstants.tasksTable, {
      'id': const Uuid().v4(),
      'title': _titleController.text,
      'description': _descriptionController.text,
      'priority': _priority.index,
      'is_recurring': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter task name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Enter description',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
