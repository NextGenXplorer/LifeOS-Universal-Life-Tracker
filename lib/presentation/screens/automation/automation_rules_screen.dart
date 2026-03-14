import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/automation/automation_engine.dart';
import '../../../domain/entities/automation/automation_rule.dart';

class AutomationRulesScreen extends ConsumerWidget {
  const AutomationRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Automation'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRuleDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<AutomationRule>>(
        future: AutomationEngine.getAllRules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildRuleCard(context, snapshot.data![index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.automation, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No automation rules',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create rules to automate your life',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRuleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Rule'),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, AutomationRule rule) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (rule.isActive ? AppColors.success : AppColors.textSecondary)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTriggerIcon(rule.triggerType),
                  color: rule.isActive ? AppColors.success : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (rule.description != null)
                      Text(
                        rule.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: rule.isActive,
                onChanged: (value) {
                  AutomationEngine.toggleRule(rule.id, value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(
                Icons.flash_on,
                _formatTriggerType(rule.triggerType),
                AppColors.warning,
              ),
              const SizedBox(width: 8),
              _buildChip(
                Icons.play_arrow,
                _formatActionType(rule.actionType),
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
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
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  IconData _getTriggerIcon(TriggerType type) {
    switch (type) {
      case TriggerType.time:
        return Icons.schedule;
      case TriggerType.event:
        return Icons.event;
      case TriggerType.location:
        return Icons.location_on;
      case TriggerType.sensor:
        return Icons.sensors;
    }
  }

  String _formatTriggerType(TriggerType type) {
    switch (type) {
      case TriggerType.time:
        return 'Time';
      case TriggerType.event:
        return 'Event';
      case TriggerType.location:
        return 'Location';
      case TriggerType.sensor:
        return 'Sensor';
    }
  }

  String _formatActionType(ActionType type) {
    switch (type) {
      case ActionType.showNotification:
        return 'Notification';
      case ActionType.awardXpCoins:
        return 'Reward';
      case ActionType.createTask:
        return 'Create Task';
      case ActionType.logActivity:
        return 'Log Activity';
      case ActionType.startTimer:
        return 'Start Timer';
    }
  }

  void _showCreateRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Automation Rule'),
        content: const Text(
          'Automation rule creation would be implemented here. '
          'Select trigger, condition, and action types to create custom automation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
