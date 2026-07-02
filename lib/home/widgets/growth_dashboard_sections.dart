import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../features/profile/xp_provider.dart';

class DailyChallengesSection extends ConsumerWidget {
  const DailyChallengesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpState = ref.watch(xpProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Challenges',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: xpState.dailyChallenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final challenge = xpState.dailyChallenges.keys.elementAt(i);
              final isCompleted = xpState.dailyChallenges[challenge] ?? false;

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(xpProvider.notifier).toggleChallenge(challenge);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.gold.withValues(alpha: 0.3)
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Check icon / checkbox
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? AppColors.gold : Colors.transparent,
                          border: Border.all(
                            color: isCompleted ? AppColors.gold : AppColors.textSecondaryDark,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: AppColors.darkBg,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      // Challenge details
                      Expanded(
                        child: Text(
                          challenge,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.textSecondaryDark
                                : AppColors.textPrimaryDark,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),

                      // XP reward text
                      Text(
                        '+150 XP',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? AppColors.textTertiaryDark : AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SkillProgressSection extends ConsumerWidget {
  const SkillProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpState = ref.watch(xpProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attribute Progression',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          
          // Attributes Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: xpState.skills.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final skill = xpState.skills.keys.elementAt(i);
              final levelVal = xpState.skills[skill] ?? 1.0;
              final int integerPart = levelVal.floor();
              final double decimalPart = levelVal - integerPart;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      skill,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'LVL $integerPart',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        Text(
                          '+${(decimalPart * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 3,
                        child: LinearProgressIndicator(
                          value: decimalPart == 0.0 && levelVal > 1.0 ? 1.0 : decimalPart,
                          backgroundColor: AppColors.darkSurface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
