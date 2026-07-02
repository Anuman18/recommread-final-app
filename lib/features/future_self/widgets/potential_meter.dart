import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class PotentialMeter extends StatefulWidget {
  const PotentialMeter({
    super.key,
    required this.xp,
    required this.level,
    required this.missionsCompleted,
    required this.skillAverage,
    required this.streak,
  });

  final int xp;
  final int level;
  final int missionsCompleted;
  final double skillAverage;
  final int streak;

  @override
  State<PotentialMeter> createState() => _PotentialMeterState();
}

class _PotentialMeterState extends State<PotentialMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
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
    final items = [
      _MeterItem(label: 'Knowledge XP', value: (widget.xp / 50000.0).clamp(0.0, 1.0), display: '${widget.xp} / 50K', color: const Color(0xFFE2B96F)),
      _MeterItem(label: 'Current Level', value: (widget.level / 20.0).clamp(0.0, 1.0), display: 'Lv ${widget.level} / 20', color: const Color(0xFF6EC6E2)),
      _MeterItem(label: 'Mission Completion', value: (widget.missionsCompleted / 30.0).clamp(0.0, 1.0), display: '${widget.missionsCompleted} / 30', color: const Color(0xFF82E2A0)),
      _MeterItem(label: 'Skill Growth', value: (widget.skillAverage / 5.0).clamp(0.0, 1.0), display: '${widget.skillAverage.toStringAsFixed(1)} / 5.0', color: const Color(0xFFE2A06E)),
      _MeterItem(label: 'Consistency Streak', value: (widget.streak / 30.0).clamp(0.0, 1.0), display: '${widget.streak} days', color: const Color(0xFFE26EBD)),
    ];

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Column(
          children: items.map((item) => _buildBar(item)).toList(),
        );
      },
    );
  }

  Widget _buildBar(_MeterItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
              Text(item.display, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: item.color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.darkCard),
                FractionallySizedBox(
                  widthFactor: item.value * _anim.value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [item.color.withValues(alpha: 0.6), item.color],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterItem {
  final String label;
  final double value;
  final String display;
  final Color color;
  const _MeterItem({required this.label, required this.value, required this.display, required this.color});
}
