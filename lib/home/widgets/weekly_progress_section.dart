import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';

class WeeklyProgressSection extends StatefulWidget {
  const WeeklyProgressSection({super.key, required this.stats});
  final WeeklyStats stats;

  @override
  State<WeeklyProgressSection> createState() => _WeeklyProgressSectionState();
}

class _WeeklyProgressSectionState extends State<WeeklyProgressSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _tileAnims;

  static const _count = 5;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tileAnims = List.generate(_count, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(i * 0.1, (i * 0.1 + 0.55).clamp(0, 1), curve: Curves.easeOutCubic),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(emoji: '⏱️', label: 'Learning\nHours', value: widget.stats.learningHours.toStringAsFixed(1), color: const Color(0xFF6C8EFF)),
      _Metric(emoji: '✅', label: 'Missions\nCompleted', value: '${widget.stats.completedMissions}', color: const Color(0xFF4CAF50)),
      _Metric(emoji: '💻', label: 'Coding\nProblems', value: '${widget.stats.codingQuestions}', color: const Color(0xFFFF7043)),
      _Metric(emoji: '🛠️', label: 'Projects\nStarted', value: '${widget.stats.projects}', color: const Color(0xFFAB47BC)),
      _Metric(emoji: '⚡', label: 'XP\nEarned', value: '${widget.stats.xpEarned}', color: AppColors.gold),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Weekly Progress',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'This Week',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3+2 grid of metric tiles
          Column(
            children: [
              // Row 1 — 3 tiles
              Row(
                children: [
                  _buildTile(metrics[0], _tileAnims[0]),
                  const SizedBox(width: 10),
                  _buildTile(metrics[1], _tileAnims[1]),
                  const SizedBox(width: 10),
                  _buildTile(metrics[2], _tileAnims[2]),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2 — 2 tiles centered
              Row(
                children: [
                  Expanded(child: _buildTile(metrics[3], _tileAnims[3], expanded: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTile(metrics[4], _tileAnims[4], expanded: true)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile(_Metric metric, Animation<double> anim, {bool expanded = false}) {
    final tile = AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: _MetricTile(metric: metric),
    );

    return expanded ? tile : Expanded(child: tile);
  }
}

class _Metric {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _Metric({required this.emoji, required this.label, required this.value, required this.color});
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: metric.color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [metric.color, metric.color.withValues(alpha: 0.8)],
                ).createShader(b),
                child: Text(
                  metric.value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiaryDark,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
