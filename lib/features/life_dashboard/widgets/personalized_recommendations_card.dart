import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../life_dashboard_provider.dart';

class PersonalizedRecommendationsCard extends ConsumerWidget {
  const PersonalizedRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    final rec = state.dailyRecommendations;
    if (rec.isEmpty) return const SizedBox.shrink();

    final intensity = rec['intensity']?.toString() ?? 'Cruising';
    final dailyMission = rec['daily_mission'] as Map?;
    final List<dynamic> resources = rec['suggested_resources'] ?? [];
    final List<dynamic> codingQuestions = rec['suggested_coding_questions'] ?? [];

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
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Smart Recommendations', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Text(intensity, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily Mission if present
          if (dailyMission != null) ...[
            Text('DAILY TARGET', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textTertiaryDark, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(lifeDashboardProvider.notifier).trackRecommendation('click', 'mission', dailyMission['id']?.toString() ?? '');
                context.push('/home');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dailyMission['title']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                          const SizedBox(height: 3),
                          Text(dailyMission['description']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+${dailyMission['xp_reward']} XP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold)),
                        Text('+${dailyMission['coins_reward']} coins', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Recommended resources if present
          if (resources.isNotEmpty) ...[
            Text('SUGGESTED BOOKS & DOCUMENTS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textTertiaryDark, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            ...resources.map((res) {
              final map = Map<String, dynamic>.from(res);
              final skills = List<String>.from(map['skills'] ?? []);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(lifeDashboardProvider.notifier).trackRecommendation('click', 'resource', map['id']?.toString() ?? '');
                    context.push('/home');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📖', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(map['title']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(map['ai_reason']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.4)),
                        if (skills.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                                ),
                                child: Text(skill, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.gold)),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Recommended coding challenges if present
          if (codingQuestions.isNotEmpty) ...[
            Text('CODING PRACTICE SUITE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textTertiaryDark, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            ...codingQuestions.map((q) {
              final map = Map<String, dynamic>.from(q);
              final diff = map['difficulty']?.toString() ?? 'Easy';
              final isHard = diff.toLowerCase() == 'hard';
              final diffColor = isHard ? const Color(0xFFE26EBD) : const Color(0xFF82E2A0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(lifeDashboardProvider.notifier).trackRecommendation('click', 'coding', map['id']?.toString() ?? '');
                    context.push('/home');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Text('💻', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(map['title']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: diffColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(diff, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: diffColor)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('⚡ +${map['xp_reward']} XP  ⏱️ ${map['time_min']}m', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiaryDark),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
