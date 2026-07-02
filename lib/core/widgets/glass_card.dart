import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A frosted-glass style card with subtle border and blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.opacity = 0.06,
    this.borderOpacity = 0.15,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = color ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      decoration: BoxDecoration(
        color: base.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: base.withValues(alpha: borderOpacity),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
