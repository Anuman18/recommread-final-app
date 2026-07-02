import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class SkillRadarChart extends StatefulWidget {
  const SkillRadarChart({
    super.key,
    required this.skills,
    this.size = 260,
  });

  final Map<String, double> skills;
  final double size;

  @override
  State<SkillRadarChart> createState() => _SkillRadarChartState();
}

class _SkillRadarChartState extends State<SkillRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.skills.keys.toList();
    final values = widget.skills.values.toList();
    // Normalise: max skill value = 5.0
    final normalised = values.map((v) => (v / 5.0).clamp(0.0, 1.0)).toList();

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarPainter(
                  progress: _anim.value,
                  normalisedValues: normalised,
                  count: labels.length,
                ),
              ),
              // Axis labels
              ...List.generate(labels.length, (i) {
                final angle = (2 * pi * i / labels.length) - pi / 2;
                final r = widget.size / 2 * 0.88;
                final x = r * cos(angle);
                final y = r * sin(angle);
                return Transform.translate(
                  offset: Offset(x, y),
                  child: SizedBox(
                    width: 64,
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final List<double> normalisedValues;
  final int count;

  _RadarPainter({
    required this.progress,
    required this.normalisedValues,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 * 0.62;

    // Grid rings
    final gridPaint = Paint()
      ..color = AppColors.darkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = (2 * pi * i / count) - pi / 2;
        final pt = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Axis spokes
    final spokePaint = Paint()
      ..color = AppColors.darkBorder
      ..strokeWidth = 0.6;
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + maxR * cos(angle), center.dy + maxR * sin(angle)),
        spokePaint,
      );
    }

    // Data fill
    final fillPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final r = maxR * normalisedValues[i] * progress;
      final pt = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Data points
    final dotPaint = Paint()..color = AppColors.gold;
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final r = maxR * normalisedValues[i] * progress;
      final pt = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      canvas.drawCircle(pt, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => oldDelegate.progress != progress;
}
