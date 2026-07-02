import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';

class ContinueLearningCard extends StatefulWidget {
  const ContinueLearningCard({super.key, required this.resource});
  final LearningResource resource;

  @override
  State<ContinueLearningCard> createState() => _ContinueLearningCardState();
}

class _ContinueLearningCardState extends State<ContinueLearningCard>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;
  late final AnimationController _pressCtrl;

  static const _mockProgress = 0.38; // will come from backend

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(begin: 0, end: _mockProgress)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));

    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.resource.type) {
      case 'video':    return const Color(0xFFFF4444);
      case 'docs':     return const Color(0xFF6C8EFF);
      case 'course':   return const Color(0xFF4CAF50);
      case 'practice': return const Color(0xFFFF7043);
      case 'project':  return const Color(0xFFAB47BC);
      default:         return AppColors.gold;
    }
  }

  String get _typeLabel {
    switch (widget.resource.type) {
      case 'video':    return 'Video';
      case 'docs':     return 'Documentation';
      case 'course':   return 'Course';
      case 'practice': return 'Practice';
      case 'project':  return 'Project';
      case 'blog':     return 'Blog';
      default:         return 'Resource';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('▶️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Continue Learning',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Card
          GestureDetector(
            onTapDown: (_) => _pressCtrl.reverse(),
            onTapUp: (_) => _pressCtrl.forward(),
            onTapCancel: () => _pressCtrl.forward(),
            onTap: () => HapticFeedback.lightImpact(),
            child: ScaleTransition(
              scale: _pressCtrl,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.darkBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Thumbnail square
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _typeColor.withValues(alpha: 0.25)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              widget.resource.icon,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: _typeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _typeLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.resource.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.resource.source,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Progress row
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnimatedBuilder(
                                    animation: _progressAnim,
                                    builder: (_, __) => LinearProgressIndicator(
                                      value: _progressAnim.value,
                                      minHeight: 4,
                                      backgroundColor: AppColors.darkSurface,
                                      valueColor: AlwaysStoppedAnimation<Color>(_typeColor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _progressAnim,
                                builder: (_, __) => Text(
                                  '${(_progressAnim.value * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _typeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Resume button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _typeColor.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_filled_rounded,
                            color: _typeColor,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Resume',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
