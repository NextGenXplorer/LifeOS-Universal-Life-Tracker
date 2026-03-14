import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

// Placeholders for providers
final todayHabitsProvider = Provider((ref) => []);
final todayTasksProvider = Provider((ref) => []);

enum TaskPriority { low, medium, high, urgent }

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(todayHabitsProvider);
    final tasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'LifeOS',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting Section
                  _buildGreetingSection(context),
                  SizedBox(height: 24.h),
                  
                  // Today's Overview Cards
                  _buildOverviewCards(context, habitsAsync, tasksAsync),
                  SizedBox(height: 24.h),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                  SizedBox(height: 24.h),
                  
                  // Today's Habits
                  _buildHabitsSection(context, habitsAsync),
                  SizedBox(height: 24.h),
                  
                  // Today's Tasks
                  _buildTasksSection(context, tasksAsync),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';
    else greeting = 'Good Evening';

    return GlassCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Let\'s make today productive!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    dynamic habits,
    dynamic tasks,
  ) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.all(16.w),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.accent,
                  size: 32.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  '12',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  'Day Streak',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.all(16.w),
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.3),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  '0/0',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  'Tasks Done',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('Habit', Icons.repeat, AppColors.primary, () {}),
      _QuickAction('Task', Icons.check_circle, AppColors.accent, () {}),
      _QuickAction('Expense', Icons.attach_money, AppColors.warning, () {}),
      _QuickAction('Note', Icons.note_add, AppColors.info, () {}),
    ];

    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Log',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((action) => _buildActionButton(context, action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsSection(BuildContext context, dynamic habits) {
    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Habits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Text('No habits for today'),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, dynamic tasks) {
    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Text('No tasks for today'),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
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
      width: 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAction(this.label, this.icon, this.color, this.onTap);
}
