import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A premium animated button that scales down on press.
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 56,
    this.borderRadius = 16,
    this.border,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;
  final BoxBorder? border;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.goldGradient,
            color: widget.gradient == null ? widget.backgroundColor : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border,
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.onPressed != null
              ? widget.child
              : Opacity(opacity: 0.5, child: widget.child),
        ),
      ),
    );
  }
}
