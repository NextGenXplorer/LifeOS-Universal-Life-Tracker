import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ai/ai_insight.dart';

class AiSuggestionCard extends StatelessWidget {
  final AiInsight insight;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const AiSuggestionCard({
    super.key,
    required this.insight,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getColor(),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(insight.confidence * 100).toInt()}% confidence',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (onAction != null)
                  TextButton(
                    onPressed: onAction,
                    child: const Text('Learn More'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (insight.insightType) {
      case InsightType.habitPrediction:
        return AppColors.primary;
      case InsightType.productivity:
        return AppColors.accent;
      case InsightType.moodForecast:
        return Colors.pink;
      case InsightType.anomaly:
        return AppColors.warning;
      case InsightType.correlation:
        return AppColors.info;
      case InsightType.suggestion:
        return AppColors.success;
    }
  }

  IconData _getIcon() {
    switch (insight.insightType) {
      case InsightType.habitPrediction:
        return Icons.repeat;
      case InsightType.productivity:
        return Icons.speed;
      case InsightType.moodForecast:
        return Icons.mood;
      case InsightType.anomaly:
        return Icons.warning;
      case InsightType.correlation:
        return Icons.link;
      case InsightType.suggestion:
        return Icons.lightbulb;
    }
  }
}
