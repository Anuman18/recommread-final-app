import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AiScanPage extends StatefulWidget {
  const AiScanPage({super.key, required this.onScanComplete});
  final VoidCallback onScanComplete;

  @override
  State<AiScanPage> createState() => _AiScanPageState();
}

class _AiScanPageState extends State<AiScanPage> with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final Animation<double> _pulseAnim;

  int _statusIndex = 0;
  final List<Map<String, String>> _statuses = [
    {'icon': '🎯', 'text': 'Analyzing Goal...'},
    {'icon': '🗺️', 'text': 'Building Personalized Career Roadmap...'},
    {'icon': '📚', 'text': 'Finding Best Learning Resources...'},
    {'icon': '🏭', 'text': 'Matching Industry Requirements...'},
    {'icon': '✅', 'text': 'Roadmap Ready! Finalizing your plan...'},
  ];

  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward().then((_) {
        if (mounted) widget.onScanComplete();
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusTimer = Timer.periodic(const Duration(milliseconds: 840), (timer) {
      if (mounted) {
        setState(() {
          if (_statusIndex < _statuses.length - 1) {
            _statusIndex++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scanner icon
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (_, child) => Transform.rotate(
                    angle: _rotateController.value * 6.28,
                    child: child,
                  ),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DashedCirclePainter(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        dashes: 12,
                      ),
                    ),
                  ),
                ),
                // Middle glow ring
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // Inner icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.3),
                        AppColors.darkCard,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 38,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Title
            Text(
              'AI Career Analyzer',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Calibrating your personal growth OS...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textTertiaryDark,
              ),
            ),
            const SizedBox(height: 36),

            // Status message with icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Container(
                key: ValueKey<int>(_statusIndex),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statuses[_statusIndex]['icon']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _statuses[_statusIndex]['text']!,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Progress bar
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, _) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 240,
                        height: 5,
                        child: LinearProgressIndicator(
                          value: _scanController.value,
                          backgroundColor: AppColors.darkSurface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(_scanController.value * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashes;

  _DashedCirclePainter({required this.color, required this.dashes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const gap = 0.3;
    final sweep = (6.28 / dashes) - gap;

    for (int i = 0; i < dashes; i++) {
      final start = i * 6.28 / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.dashes != dashes;
}
