import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'interview_provider.dart';

class InterviewDashboardScreen extends ConsumerStatefulWidget {
  const InterviewDashboardScreen({super.key});

  @override
  ConsumerState<InterviewDashboardScreen> createState() => _InterviewDashboardScreenState();
}

class _InterviewDashboardScreenState extends ConsumerState<InterviewDashboardScreen> {
  int _selectedTab = 0; // 0: Rounds, 1: History, 2: Achievements

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);
    final notifier = ref.read(interviewProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),

              if (state.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
              else ...[
                // Score Gauge Overview Card
                _buildReadinessGauge(state),
                const SizedBox(height: 12),

                // Tab Switcher
                _buildTabBar(),
                const SizedBox(height: 16),

                // Content Viewport
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => notifier.refresh(),
                    color: AppColors.gold,
                    backgroundColor: AppColors.darkCard,
                    child: _buildTabContent(state),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Interview prep',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  'Assess readiness with AI simulation',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_external_on_rounded,
                color: AppColors.gold, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Animated Readiness Gauge Card ──────────────────────────────────────────

  Widget _buildReadinessGauge(InterviewState s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Readiness Meter
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: s.readinessScore / 100.0,
                    strokeWidth: 9,
                    backgroundColor: AppColors.darkElevated,
                    color: AppColors.gold,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${s.readinessScore.round()}%',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
                    ),
                    Text(
                      'READINESS',
                      style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w800, color: AppColors.textTertiaryDark, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Metrics Summary details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _gaugeLabel('Completed', '${s.completedInterviews} rounds'),
                      _gaugeLabel('Average Score', '${s.currentScore.round()}%'),
                    ],
                  ),
                  const Divider(color: AppColors.darkBorder, height: 16),
                  Text(
                    'Weak area: ${s.weakSkills.isNotEmpty ? s.weakSkills.first : "None"}',
                    style: GoogleFonts.inter(fontSize: 9, color: AppColors.error, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Strong point: ${s.strongSkills.isNotEmpty ? s.strongSkills.first : "None"}',
                    style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gaugeLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
      ],
    );
  }

  // ── Tab Bar selector ───────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = ['Rounds', 'History', 'Achievements'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.darkBg : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab Content Switcher ───────────────────────────────────────────────────

  Widget _buildTabContent(InterviewState s) {
    switch (_selectedTab) {
      case 0:
        return _buildRoundsTab(s);
      case 1:
        return _buildHistoryTab(s);
      case 2:
        return _buildAchievementsTab(s);
      default:
        return _buildRoundsTab(s);
    }
  }

  // ── Tab 1: Rounds list ─────────────────────────────────────────────────────

  Widget _buildRoundsTab(InterviewState s) {
    if (s.interviewTypes.isEmpty) return const SizedBox();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: s.interviewTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final t = s.interviewTypes[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(t.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
                        Text(
                          '${t.questionCount} Questions  •  ${t.durationMin} mins estim.',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.description, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.45)),
              const SizedBox(height: 14),

              // Action button
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  ref.read(interviewProvider.notifier).startInterview(t);
                  context.push('/ai-interview/active', extra: t);
                },
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Launch AI Interview Simulator',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: History list ────────────────────────────────────────────────────

  Widget _buildHistoryTab(InterviewState s) {
    if (s.history.isEmpty) return const SizedBox();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: s.history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = s.history[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              const Text('🎤', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.typeName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                    Text(item.date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.score.round()}% Score',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold),
                  ),
                  Text(
                    '+${item.readinessGained} Readiness',
                    style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Achievements ────────────────────────────────────────────────────

  Widget _buildAchievementsTab(InterviewState s) {
    if (s.achievements.isEmpty) return const SizedBox();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: s.achievements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final ach = s.achievements[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ach.isUnlocked
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : AppColors.darkBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ach.isUnlocked
                      ? AppColors.gold.withValues(alpha: 0.1)
                      : AppColors.darkElevated,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Opacity(
                    opacity: ach.isUnlocked ? 1.0 : 0.4,
                    child: Text(
                      ach.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ach.title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ach.isUnlocked ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach.description,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
              Icon(
                ach.isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                color: ach.isUnlocked ? const Color(0xFF4CAF50) : AppColors.textTertiaryDark,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }
}
