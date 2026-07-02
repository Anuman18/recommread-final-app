import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../onboarding/onboarding_provider.dart';
import '../profile/xp_provider.dart';
import '../profile/profile_provider.dart';
import 'future_self_provider.dart';
import 'widgets/skill_radar_chart.dart';
import 'widgets/future_timeline.dart';
import 'widgets/potential_meter.dart';
import 'widgets/milestone_overlay.dart';

class FutureSelfDashboardScreen extends ConsumerWidget {
  const FutureSelfDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpState = ref.watch(xpProvider);
    final profileState = ref.watch(profileProvider);
    final futureSelfState = ref.watch(futureSelfProvider);
    final onboardingState = ref.watch(onboardingProvider);
    final goalLabel = onboardingState.goal?.label ?? profileState.readingGoal.label;
    final skillAvg = xpState.skills.values.isEmpty
        ? 1.0
        : xpState.skills.values.reduce((a, b) => a + b) / xpState.skills.length;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(context, goalLabel, xpState)),
                  // Body sections
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Chat with Future Self CTA ─────────────
                        _buildChatCTA(context),
                        const SizedBox(height: 28),
                        // ── Potential Meter ───────────────────────
                        _buildSection(
                          'Potential Meter',
                          '🔋',
                          PotentialMeter(
                            xp: xpState.currentXp,
                            level: xpState.level,
                            missionsCompleted: profileState.booksCompleted,
                            skillAverage: skillAvg,
                            streak: profileState.streak,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // ── Skill Radar ───────────────────────────
                        _buildSection(
                          'Skill Radar',
                          '🕸️',
                          Center(
                            child: SkillRadarChart(skills: xpState.skills),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // ── Future Timeline ───────────────────────
                        _buildSection(
                          'Growth Timeline',
                          '🗺️',
                          FutureTimeline(goalLabel: goalLabel),
                        ),
                        const SizedBox(height: 28),
                        // ── Milestone Demos ───────────────────────
                        _buildMilestoneDemoSection(context, ref),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Milestone overlay
          if (futureSelfState.pendingMilestone != null)
            Positioned.fill(
              child: MilestoneOverlay(
                milestone: futureSelfState.pendingMilestone!,
                onDismiss: () {
                  HapticFeedback.lightImpact();
                  ref.read(futureSelfProvider.notifier).clearMilestone();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String goalLabel, XpState xpState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimaryDark),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Lv ${xpState.level}  ·  ${xpState.currentXp} XP',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Future Self',
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.8),
          ),
          const SizedBox(height: 4),
          Text(
            'Your journey toward becoming a $goalLabel',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/future-self/chat');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold.withValues(alpha: 0.12), AppColors.gold.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 12)],
              ),
              child: const Center(child: Text('✨', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Talk to Your Future Self', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 3),
                  Text('Get advice, guidance & mission briefings', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String icon, Widget child) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildMilestoneDemoSection(BuildContext context, WidgetRef ref) {
    final milestones = [
      kLevelUpMilestone,
      kMissionCompleteMilestone,
      kSkillUnlockedMilestone,
      kStreak7Milestone,
      kStreak30Milestone,
      kXp1000Milestone,
    ];

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Milestone Celebrations', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap any to preview the celebration', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: milestones.map((m) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(futureSelfProvider.notifier).triggerMilestone(m);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(m.title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
