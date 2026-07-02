import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../life_dashboard_provider.dart';

class AchievementCenterCard extends ConsumerWidget {
  const AchievementCenterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    final achievements = state.achievements;

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
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Achievement Center', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Text('${achievements.where((a) => a.unlocked).length}/${achievements.length}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, i) => _AchievementCell(achievement: achievements[i]),
          ),
        ],
      ),
    );
  }
}

class _AchievementCell extends StatefulWidget {
  const _AchievementCell({required this.achievement});
  final Achievement achievement;

  @override
  State<_AchievementCell> createState() => _AchievementCellState();
}

class _AchievementCellState extends State<_AchievementCell> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: a.unlocked ? LinearGradient(
            colors: [AppColors.gold.withValues(alpha: 0.15), AppColors.gold.withValues(alpha: 0.05)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          color: a.unlocked ? null : AppColors.darkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: a.unlocked ? AppColors.gold.withValues(alpha: 0.35) : AppColors.darkBorder,
            width: a.unlocked ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(a.emoji, style: TextStyle(fontSize: 20, color: a.unlocked ? null : Colors.grey)),
                const Spacer(),
                if (a.unlocked) const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.gold),
              ],
            ),
            const Spacer(),
            Text(a.title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: a.unlocked ? AppColors.textPrimaryDark : AppColors.textTertiaryDark), maxLines: 1),
            const SizedBox(height: 4),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(height: 3, color: AppColors.darkBorder),
                  FractionallySizedBox(
                    widthFactor: a.progress,
                    child: Container(height: 3, color: a.unlocked ? AppColors.gold : AppColors.textTertiaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(a.progressLabel, style: GoogleFonts.inter(fontSize: 9, color: a.unlocked ? AppColors.gold : AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
