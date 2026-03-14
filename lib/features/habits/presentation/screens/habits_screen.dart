import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../services/gamification/level_system.dart';
import '../../../../services/gamification/reward_service.dart';

final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final results = await DatabaseService.query(
    DatabaseConstants.habitsTable,
    where: 'is_active = ?',
    whereArgs: [1],
    orderBy: 'created_at DESC',
  );
  return results.map((map) => Habit.fromMap(map)).toList();
});

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) => habits.isEmpty
            ? _buildEmptyState(context)
            : _buildHabitsList(context, habits),
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
          Icon(Icons.repeat, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start building good habits!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context, List<Habit> habits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return _HabitCard(habit: habits[index]);
      },
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddHabitDialog(),
    );
  }
}

class _HabitCard extends ConsumerStatefulWidget {
  final Habit habit;

  const _HabitCard({required this.habit});

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkTodayCompletion();
  }

  Future<void> _checkTodayCompletion() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final results = await DatabaseService.query(
      DatabaseConstants.habitCompletionsTable,
      where: 'habit_id = ? AND completed_at >= ?',
      whereArgs: [widget.habit.id, today],
    );
    if (mounted) {
      setState(() => _isCompleted = results.isNotEmpty);
    }
  }

  Future<void> _toggleCompletion() async {
    final now = DateTime.now();
    
    if (_isCompleted) {
      // Remove completion
      await DatabaseService.delete(
        DatabaseConstants.habitCompletionsTable,
        where: 'habit_id = ? AND completed_at >= ?',
        whereArgs: [widget.habit.id, DateTime(now.year, now.month, now.day).toIso8601String()],
      );
    } else {
      // Add completion
      await DatabaseService.insert(DatabaseConstants.habitCompletionsTable, {
        'id': const Uuid().v4(),
        'habit_id': widget.habit.id,
        'completed_at': now.toIso8601String(),
      });
      
      // Award rewards
      final stats = await LevelSystem.getOrCreateUserStats();
      await RewardService.awardHabitCompletionRewards(streakDays: stats.streakDays);
    }

    setState(() => _isCompleted = !_isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: _toggleCompletion,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isCompleted
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCompleted ? AppColors.success : AppColors.glassDark,
                width: 2,
              ),
            ),
            child: Icon(
              _isCompleted ? Icons.check : Icons.repeat,
              color: _isCompleted ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.habit.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: _isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (widget.habit.description != null)
                  Text(
                    widget.habit.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            widget.habit.frequency.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddHabitDialog extends StatefulWidget {
  const _AddHabitDialog();

  @override
  State<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<_AddHabitDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_titleController.text.isEmpty) return;

    final now = DateTime.now();
    await DatabaseService.insert(DatabaseConstants.habitsTable, {
      'id': const Uuid().v4(),
      'title': _titleController.text,
      'description': _descriptionController.text,
      'frequency': _frequency.name,
      'target_count': 1,
      'is_active': 1,
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
      title: const Text('Add Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter habit name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Enter description',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<HabitFrequency>(
            value: _frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: HabitFrequency.values.map((f) {
              return DropdownMenuItem(value: f, child: Text(f.name));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _frequency = value);
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
          onPressed: _saveHabit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
