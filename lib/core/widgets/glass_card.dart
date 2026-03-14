import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 12,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.blur = 10,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: AppColors.glassDark,
              width: 1,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: blur,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap == null && onLongPress == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(borderRadius),
      child: card,
    );
  }
}

class GlassCardTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final TextStyle? style;

  const GlassCardTitle({
    super.key,
    required this.title,
    this.trailing,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: style ?? Theme.of(context).textTheme.titleLarge,
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
