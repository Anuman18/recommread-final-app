import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../profile/xp_provider.dart';
import '../../profile/profile_provider.dart';
import '../../onboarding/onboarding_provider.dart';

class TodayHeaderCard extends ConsumerStatefulWidget {
  const TodayHeaderCard({super.key});

  @override
  ConsumerState<TodayHeaderCard> createState() => _TodayHeaderCardState();
}

class _TodayHeaderCardState extends ConsumerState<TodayHeaderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xp = ref.watch(xpProvider);
    final profile = ref.watch(profileProvider);
    final onboarding = ref.watch(onboardingProvider);
    final goalLabel = onboarding.goal?.label ?? profile.readingGoal.label;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = (hour >= 5 && hour < 12)
        ? 'Good Morning'
        : (hour >= 12 && hour < 17)
            ? 'Good Afternoon'
            : (hour >= 17 && hour < 21)
                ? 'Good Evening'
                : 'Good Night';
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1228), Color(0xFF0F0D1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: AppColors.gold.withValues(alpha: 0.06), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$greeting, ${profile.name}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(dayName, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 12)],
                    ),
                    child: Column(
                      children: [
                        Text('Lv ${xp.level}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBg)),
                        Text(goalLabel.split(' ').first, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkBg.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // XP Bar
              Row(
                children: [
                  Text('${xp.currentXp} XP', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  const Spacer(),
                  Text('${xp.xpInCurrentLevel} / 3000', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(height: 6, color: AppColors.darkCard),
                    FractionallySizedBox(
                      widthFactor: xp.levelProgress,
                      child: Container(
                        height: 6,
                        decoration: const BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stats row
              Row(
                children: [
                  _statChip('🔥', '${profile.streak}d', 'Streak'),
                  const SizedBox(width: 10),
                  _statChip('🏆', '${profile.booksCompleted}', 'Missions'),
                  const SizedBox(width: 10),
                  _statChip('⏱️', '4.5h', 'Today'),
                  const SizedBox(width: 10),
                  _statChip('📈', '+2340', 'Week XP'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
