import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos/core/utils/app_colors.dart';
import 'package:lifeos/presentation/blocs/automation/automation_bloc.dart';
import 'package:lifeos/domain/entities/automation.dart';
import 'package:lifeos/presentation/widgets/common/neo_glass_card.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutomationBloc, AutomationState>(
      builder: (context, state) {
        if (state is AutomationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AutomationLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, AutomationLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(state),
        ),

        // Rules
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Automation Rules',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddRuleDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        ),

        if (state.allRules.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyState(context),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildRuleCard(context, state.allRules[index]),
                childCount: state.allRules.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeader(AutomationLoaded state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlue,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Automate your productivity',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('${state.activeRules.length} active', Icons.check_circle),
              const SizedBox(width: 12),
              _buildStatChip('${state.allRules.length} total', Icons.list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, AutomationRule rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: rule.isActive ? AppColors.success.withOpacity(0.2) : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTriggerIcon(rule.triggerType),
                      color: rule.isActive ? AppColors.success : AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.name,
                          style: TextStyle(
                            color: rule.isActive ? AppColors.textPrimary : AppColors.textTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (rule.description != null)
                          Text(
                            rule.description!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: rule.isActive,
                    onChanged: (value) {
                      context.read<AutomationBloc>().add(
                            ToggleAutomationRule(rule.id, value),
                          );
                    },
                    activeColor: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRuleChip(_getTriggerLabel(rule.triggerType), AppColors.primary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 8),
                  _buildRuleChip(_getActionLabel(rule.actionType), AppColors.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
            Icons.auto_awesome,
            color: AppColors.textTertiary,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No automation rules',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create rules to automate your habits and earn XP automatically',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddRuleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create First Rule'),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Automation Rule',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildRuleOption(
              context,
              'Daily Reminder',
              'Get reminded to complete habits',
              Icons.notifications,
            ),
            _buildRuleOption(
              context,
              'Streak Bonus',
              'Earn bonus XP on streak milestones',
              Icons.local_fire_department,
            ),
            _buildRuleOption(
              context,
              'Time-based',
              'Trigger actions at specific times',
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleOption(BuildContext context, String title, String desc, IconData icon) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        // Create rule
      },
    );
  }

  IconData _getTriggerIcon(String type) {
    switch (type) {
      case 'time':
        return Icons.schedule;
      case 'habit_completed':
        return Icons.check_circle;
      case 'task_completed':
        return Icons.task_alt;
      case 'daily_streak':
        return Icons.local_fire_department;
      default:
        return Icons.bolt;
    }
  }

  String _getTriggerLabel(String type) {
    switch (type) {
      case 'time':
        return 'Time';
      case 'habit_completed':
        return 'Habit Done';
      case 'task_completed':
        return 'Task Done';
      case 'daily_streak':
        return 'Streak';
      default:
        return type;
    }
  }

  String _getActionLabel(String type) {
    switch (type) {
      case 'send_notification':
        return 'Notify';
      case 'award_xp':
        return 'Award XP';
      case 'create_task':
        return 'Create Task';
      case 'send_reminder':
        return 'Reminder';
      default:
        return type;
    }
  }
}
