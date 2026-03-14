import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class XpBar extends StatelessWidget {
  final int currentXp;
  final int requiredXp;
  final bool showLabel;
  final double height;
  final Color? barColor;

  const XpBar({
    super.key,
    required this.currentXp,
    required this.requiredXp,
    this.showLabel = false,
    this.height = 12,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = requiredXp > 0 ? currentXp / requiredXp : 0.0;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor ?? AppColors.primary,
                          barColor?.withOpacity(0.7) ?? AppColors.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: (barColor ?? AppColors.primary).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$currentXp / $requiredXp XP ($percentage%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class AnimatedXpBar extends StatefulWidget {
  final int currentXp;
  final int requiredXp;
  final bool showLabel;
  final double height;
  final Duration duration;

  const AnimatedXpBar({
    super.key,
    required this.currentXp,
    required this.requiredXp,
    this.showLabel = false,
    this.height = 12,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedXpBar> createState() => _AnimatedXpBarState();
}

class _AnimatedXpBarState extends State<AnimatedXpBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _setupAnimation();
  }

  void _setupAnimation() {
    final targetProgress = widget.requiredXp > 0 
        ? widget.currentXp / widget.requiredXp 
        : 0.0;
    _animation = Tween<double>(
      begin: _previousProgress,
      end: targetProgress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward(from: 0);
    _previousProgress = targetProgress.clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(AnimatedXpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXp != widget.currentXp ||
        oldWidget.requiredXp != widget.requiredXp) {
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return XpBar(
          currentXp: widget.currentXp,
          requiredXp: widget.requiredXp,
          showLabel: widget.showLabel,
          height: widget.height,
        );
      },
    );
  }
}
