import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../life_dashboard_provider.dart';

class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Weekly Report', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 20),
          // XP Chart
          _WeeklyXpChart(data: state.weeklyXpChart),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              _ReportStat(label: 'Hours Learned', value: '${state.weeklyHours}h', icon: '⏱️', positive: true),
              const SizedBox(width: 10),
              _ReportStat(label: 'XP Earned', value: '+${state.weeklyXp}', icon: '⚡', positive: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ReportStat(label: 'Missions Done', value: '${state.weeklyMissions}', icon: '🎯', positive: true),
              const SizedBox(width: 10),
              const _ReportStat(label: 'Skills Improved', value: '4 skills', icon: '📈', positive: true),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Best Category', value: state.bestCategory, icon: '🏆'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Needs Attention', value: state.weakestSkill, icon: '⚠️'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Recommendation', value: state.nextRecommendation, icon: '💡'),
        ],
      ),
    );
  }
}

class _WeeklyXpChart extends StatefulWidget {
  const _WeeklyXpChart({required this.data});
  final List<int> data;

  @override
  State<_WeeklyXpChart> createState() => _WeeklyXpChartState();
}

class _WeeklyXpChartState extends State<_WeeklyXpChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = widget.data.reduce(max).toDouble();
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.data.length, (i) {
              final ratio = maxVal > 0 ? widget.data[i] / maxVal : 0.0;
              final isToday = i == widget.data.length - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: 68 * ratio * _anim.value,
                        decoration: BoxDecoration(
                          gradient: isToday ? AppColors.goldGradient : const LinearGradient(
                            colors: [AppColors.darkElevated, AppColors.darkBorder],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(days[i], style: GoogleFonts.inter(fontSize: 9, color: isToday ? AppColors.gold : AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value, required this.icon, required this.positive});
  final String label;
  final String value;
  final String icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: positive ? AppColors.gold : AppColors.textPrimaryDark)),
                Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// ── Monthly Growth Report ─────────────────────────────────────────────────────

class MonthlyReportCard extends ConsumerWidget {
  const MonthlyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Monthly Growth', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 8),
          Text('This month vs last month comparison', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
          const SizedBox(height: 20),
          _MonthlyComparisonChart(data: state.monthlyXpChart),
          const SizedBox(height: 20),
          // Metric comparisons
          _CompareRow(label: 'XP Earned', thisMonth: state.monthlyXp, lastMonth: 7200, unit: 'XP'),
          const SizedBox(height: 10),
          _CompareRow(label: 'Hours Learned', thisMonth: state.monthlyHours.round(), lastMonth: 14, unit: 'hrs'),
          const SizedBox(height: 10),
          _CompareRow(label: 'Missions Complete', thisMonth: state.monthlyMissions, lastMonth: 8, unit: ''),
        ],
      ),
    );
  }
}

class _MonthlyComparisonChart extends StatefulWidget {
  const _MonthlyComparisonChart({required this.data});
  final List<int> data;

  @override
  State<_MonthlyComparisonChart> createState() => _MonthlyComparisonChartState();
}

class _MonthlyComparisonChartState extends State<_MonthlyComparisonChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    final maxVal = widget.data.reduce(max).toDouble();
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.data.length, (i) {
              final ratio = maxVal > 0 ? widget.data[i] / maxVal : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${widget.data[i]}', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.gold)),
                      const SizedBox(height: 4),
                      Container(
                        height: 80 * ratio * _anim.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gold.withValues(alpha: 0.4), AppColors.gold],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(weeks[i], style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.thisMonth, required this.lastMonth, required this.unit});
  final String label;
  final num thisMonth;
  final num lastMonth;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final improved = thisMonth > lastMonth;
    final delta = thisMonth - lastMonth;
    final deltaStr = improved ? '+$delta' : '$delta';
    final deltaColor = improved ? const Color(0xFF82E2A0) : const Color(0xFFE26EBD);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$thisMonth${unit.isNotEmpty ? ' $unit' : ''}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gold)),
              Text('vs $lastMonth${unit.isNotEmpty ? ' $unit' : ''} last month', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: deltaColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: deltaColor.withValues(alpha: 0.3)),
            ),
            child: Text(deltaStr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: deltaColor)),
          ),
        ],
      ),
    );
  }
}
