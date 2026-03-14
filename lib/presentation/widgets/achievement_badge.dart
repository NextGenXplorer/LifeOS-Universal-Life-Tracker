import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String? icon;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final double size;

  const AchievementBadge({
    super.key,
    required this.title,
    this.icon,
    this.isUnlocked = false,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked 
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surface,
              border: Border.all(
                color: isUnlocked ? AppColors.primary : AppColors.glassDark,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                _getIcon(),
                size: size * 0.5,
                color: isUnlocked ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size + 20,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUnlocked ? AppColors.text : AppColors.textSecondary,
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (icon) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'task_alt':
        return Icons.task_alt;
      case 'verified':
        return Icons.verified;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'psychology':
        return Icons.psychology;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? icon;
  final int xpReward;
  final int coinReward;
  final bool isUnlocked;
  final double? progress;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.xpReward = 0,
    this.coinReward = 0,
    this.isUnlocked = false,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnlocked 
          ? AppColors.cardBackground
          : AppColors.cardBackground.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked 
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: isUnlocked ? AppColors.primary : AppColors.glassDark,
                  ),
                ),
                child: Icon(
                  _getIcon(),
                  color: isUnlocked ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? AppColors.text : AppColors.textSecondary,
                      ),
                    ),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (xpReward > 0)
                          _buildRewardChip(
                            Icons.star,
                            '$xpReward XP',
                            AppColors.warning,
                          ),
                        if (coinReward > 0)
                          _buildRewardChip(
                            Icons.monetization_on,
                            '$coinReward',
                            AppColors.accent,
                          ),
                      ],
                    ),
                    if (progress != null && !isUnlocked) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
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
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (icon) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'task_alt':
        return Icons.task_alt;
      case 'verified':
        return Icons.verified;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'psychology':
        return Icons.psychology;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }
}
