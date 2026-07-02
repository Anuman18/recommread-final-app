import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../future_self_provider.dart';

class MilestoneOverlay extends StatefulWidget {
  const MilestoneOverlay({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  final Milestone milestone;
  final VoidCallback onDismiss;

  @override
  State<MilestoneOverlay> createState() => _MilestoneOverlayState();
}

class _MilestoneOverlayState extends State<MilestoneOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _particleAnim;

  final _random = Random();
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
    _particleAnim = CurvedAnimation(parent: _particleCtrl, curve: Curves.easeOut);

    _generateParticles();
    _scaleCtrl.forward();
    _particleCtrl.forward();
  }

  void _generateParticles() {
    for (int i = 0; i < 24; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble() * 2 - 1,
        y: _random.nextDouble() * 2 - 1,
        size: _random.nextDouble() * 6 + 3,
        color: [AppColors.gold, AppColors.goldLight, const Color(0xFF82E2A0), const Color(0xFF6EC6E2)][_random.nextInt(4)],
        speed: _random.nextDouble() * 0.6 + 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleCtrl, _particleCtrl]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Particles
                ..._particles.map((p) {
                  final t = _particleAnim.value * p.speed;
                  final x = MediaQuery.of(context).size.width / 2 + p.x * 200 * t;
                  final y = MediaQuery.of(context).size.height / 2 + p.y * 300 * t - 60 * t * t;
                  return Positioned(
                    left: x - p.size / 2,
                    top: y - p.size / 2,
                    child: Opacity(
                      opacity: (1 - _particleAnim.value).clamp(0.0, 1.0),
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                // Card
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.25),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                              boxShadow: [
                                BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 20),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.milestone.emoji,
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ACHIEVEMENT UNLOCKED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.milestone.title,
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.milestone.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondaryDark,
                              height: 1.5,
                            ),
                          ),
                          if (widget.milestone.xpGained > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                '+${widget.milestone.xpGained} XP',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            'Tap to continue',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textTertiaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  const _Particle({required this.x, required this.y, required this.size, required this.color, required this.speed});
}
