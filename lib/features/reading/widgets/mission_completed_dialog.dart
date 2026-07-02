import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';

class MissionCompletedDialog extends StatefulWidget {
  const MissionCompletedDialog({super.key, required this.book});
  final Book book;

  @override
  State<MissionCompletedDialog> createState() => _MissionCompletedDialogState();
}

class _MissionCompletedDialogState extends State<MissionCompletedDialog>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    _cardCtrl.forward();

    // Generate random confetti
    final rand = Random();
    for (int i = 0; i < 80; i++) {
      _particles.add(
        _ConfettiParticle(
          x: rand.nextDouble() * 400 - 200,
          y: rand.nextDouble() * -500,
          speedY: rand.nextDouble() * 3 + 2,
          speedX: rand.nextDouble() * 4 - 2,
          color: [
            AppColors.gold,
            const Color(0xFFFF6B35),
            const Color(0xFFFFBC42),
            const Color(0xFF4EA8DE),
            Colors.greenAccent,
          ][rand.nextInt(5)],
          size: rand.nextDouble() * 6 + 4,
          rotation: rand.nextDouble() * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Card panel
          ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x22BF8E3D),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.military_tech_rounded,
                          size: 42,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'MISSION ACCOMPLISHED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Book Title
                    Text(
                      widget.book.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rewards List
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Knowledge XP gained',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              Text(
                                '+${widget.book.xpReward} XP',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.darkBorder, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attributes Upgraded',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              Text(
                                widget.book.skillsUnlocked.map((s) => '+$s').join(', '),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Confirm Alignment',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confetti particles layer
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(400, 500),
                  painter: _ConfettiPainter(particles: _particles),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.color,
    required this.size,
    required this.rotation,
  });

  double x;
  double y;
  double speedY;
  double speedX;
  Color color;
  double size;
  double rotation;

  void update() {
    y += speedY;
    x += speedX;
    rotation += 0.05;
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles});
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final p in particles) {
      p.update();
      paint.color = p.color;

      canvas.save();
      canvas.translate(size.width / 2 + p.x, p.y);
      canvas.rotate(p.rotation);
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
