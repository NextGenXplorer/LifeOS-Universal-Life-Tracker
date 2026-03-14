import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HabitHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final int maxValue;
  final double cellSize;
  final Color? emptyColor;
  final Color? filledColor;

  const HabitHeatmap({
    super.key,
    required this.data,
    this.maxValue = 1,
    this.cellSize = 12,
    this.emptyColor,
    this.filledColor,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 364));
    
    // Generate weeks
    final weeks = <List<DateTime>>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(today)) {
      final week = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        if (currentDate.isBefore(today)) {
          week.add(currentDate);
        } else {
          week.add(DateTime(0)); // Empty placeholder
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weeks.map((week) {
          return Column(
            children: week.map((date) {
              if (date.year == 0) {
                return SizedBox(
                  width: cellSize,
                  height: cellSize,
                );
              }
              
              final value = data[DateTime(date.year, date.month, date.day)] ?? 0;
              final intensity = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
              
              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: intensity > 0
                      ? (filledColor ?? AppColors.primary).withOpacity(0.3 + (intensity * 0.7))
                      : (emptyColor ?? AppColors.surface),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class StreakVisualization extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final double size;

  const StreakVisualization({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.3),
            AppColors.error.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: AppColors.warning,
              size: size * 0.3,
            ),
            Text(
              '$currentStreak',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'day streak',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
