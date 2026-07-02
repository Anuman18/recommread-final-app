import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class FutureTimeline extends StatefulWidget {
  const FutureTimeline({super.key, required this.goalLabel});
  final String goalLabel;

  @override
  State<FutureTimeline> createState() => _FutureTimelineState();
}

class _FutureTimelineState extends State<FutureTimeline>
    with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  final List<Animation<double>> _anims = [];

  static const _milestones = [
    {'label': 'Today', 'desc': 'Building habits & reading consistency', 'icon': '📍', 'days': 'Now'},
    {'label': '30 Days', 'desc': 'First 3 missions done. Core skills activated.', 'icon': '🔓', 'days': '+30'},
    {'label': '90 Days', 'desc': 'Knowledge XP crosses 10,000. Mindset shifted.', 'icon': '🚀', 'days': '+90'},
    {'label': '180 Days', 'desc': 'Skill radar balanced. Level 5+ achieved.', 'icon': '⚡', 'days': '+180'},
    {'label': '1 Year', 'desc': 'Deep expertise unlocked. Mentoring others.', 'icon': '🎯', 'days': '+365'},
    {'label': 'Dream Identity', 'desc': 'You became who you set out to be.', 'icon': '🏆', 'days': '5 yr'},
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _milestones.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _ctrls.add(ctrl);
      _anims.add(CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack));
      Future.delayed(Duration(milliseconds: 200 + i * 180), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_milestones.length, (i) {
        final item = _milestones[i];
        final isLast = i == _milestones.length - 1;
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (context, child) {
            return Opacity(
              opacity: _anims[i].value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(20 * (1 - _anims[i].value), 0),
                child: child,
              ),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline spine
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isLast ? AppColors.goldGradient : null,
                          color: isLast ? null : AppColors.darkCard,
                          border: isLast
                              ? null
                              : Border.all(color: AppColors.darkBorder),
                          boxShadow: isLast
                              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 12)]
                              : null,
                        ),
                        child: Center(
                          child: Text(item['icon']!, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.gold.withValues(alpha: 0.5),
                                  AppColors.darkBorder,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              item['label']!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isLast ? AppColors.gold : AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                item['days']!,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
