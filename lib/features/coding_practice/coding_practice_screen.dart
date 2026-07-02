import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'coding_practice_provider.dart';

class CodingPracticeScreen extends ConsumerStatefulWidget {
  const CodingPracticeScreen({super.key});

  @override
  ConsumerState<CodingPracticeScreen> createState() => _CodingPracticeScreenState();
}

class _CodingPracticeScreenState extends ConsumerState<CodingPracticeScreen> {
  int _selectedTab = 0; // 0: Topics, 1: Leaderboards, 2: Achievements, 3: Stats
  int _leaderboardSubTab = 0; // 0: Weekly, 1: Monthly, 2: Friends

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(codingPracticeProvider);
    final notifier = ref.read(codingPracticeProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Area ────────────────────────────────────────────────
              _buildHeader(context),

              // ── Home Section: Challenges, Streaks & Stats Summary ──────────
              if (state.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
              else ...[
                _buildStatsSummaryCard(state),
                const SizedBox(height: 12),

                // ── Tab Bar selector ─────────────────────────────────────────
                _buildPracticeTabBar(),
                const SizedBox(height: 16),

                // ── Tab Content Viewport ─────────────────────────────────────
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

  // ── Header builder ─────────────────────────────────────────────────────────

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
                  'Coding Practice',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  'Master interview algorithms',
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
            child: const Icon(Icons.code_rounded,
                color: AppColors.gold, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Challenge & Stats card ─────────────────────────────────────────────────

  Widget _buildStatsSummaryCard(CodingPracticeState s) {
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
        child: Column(
          children: [
            // Row 1: Streak, XP, Coins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statSummaryItem('🔥', '${s.streak} Days', 'Streak'),
                _statSummaryItem('⚡', '${s.totalXpEarned} XP', 'Practice XP'),
                _statSummaryItem('🪙', '${s.totalCoinsEarned}', 'Coins'),
                _statSummaryItem('🧩', '${s.solvedCount}', 'Solved'),
              ],
            ),
            const Divider(color: AppColors.darkBorder, height: 28),

            // Row 2: Today's featured challenge banner
            if (s.dailyChallenge != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/coding-practice/question/${s.dailyChallenge!.id}', extra: s.dailyChallenge);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: AppColors.darkBg, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY CHALLENGE',
                              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.0),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.dailyChallenge!.title,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Start',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statSummaryItem(String emoji, String val, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(val, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Tab Bar selector ───────────────────────────────────────────────────────

  Widget _buildPracticeTabBar() {
    final labels = ['Topics', 'Leaderboards', 'Achievements', 'Statistics'];
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
        children: List.generate(labels.length, (i) {
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
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 9,
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

  // ── Tab Content switcher ───────────────────────────────────────────────────

  Widget _buildTabContent(CodingPracticeState s) {
    switch (_selectedTab) {
      case 0:
        return _buildTopicsTab(s);
      case 1:
        return _buildLeaderboardsTab(s);
      case 2:
        return _buildAchievementsTab(s);
      case 3:
        return _buildStatsTab(s);
      default:
        return _buildTopicsTab(s);
    }
  }

  // ── Tab 1: Topics Cards ────────────────────────────────────────────────────

  Widget _buildTopicsTab(CodingPracticeState s) {
    if (s.topics.isEmpty) return const SizedBox();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: s.topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final t = s.topics[i];
        final remaining = t.totalQuestions - t.completedQuestions;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/coding-practice/topic/${t.id}', extra: t);
          },
          child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.name,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
                    ),
                    Text(
                      '${t.completedQuestions} / ${t.totalQuestions} Solved',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 6, color: AppColors.darkElevated),
                      FractionallySizedBox(
                        widthFactor: t.progress,
                        child: Container(
                          height: 6,
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Footer metadata (Remaining, Distributions, XP)
                Row(
                  children: [
                    Text(
                      'Remaining: $remaining',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Easy: ${t.difficultyDistribution['Easy'] ?? 0}  •  Med: ${t.difficultyDistribution['Medium'] ?? 0}',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '⚡ ${t.xpEarned} XP',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 2: Leaderboard ─────────────────────────────────────────────────────

  Widget _buildLeaderboardsTab(CodingPracticeState s) {
    final subTabs = ['Weekly', 'Monthly', 'Friends'];
    final currentList = _leaderboardSubTab == 0
        ? s.weeklyLeaderboard
        : _leaderboardSubTab == 1
            ? s.monthlyLeaderboard
            : s.friendsLeaderboard;

    return Column(
      children: [
        // Sub-tabs segment switcher
        Container(
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(2),
          child: Row(
            children: List.generate(subTabs.length, (i) {
              final selected = _leaderboardSubTab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _leaderboardSubTab = i);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? AppColors.darkCard : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: selected ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Center(
                      child: Text(
                        subTabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? AppColors.gold : AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            itemCount: currentList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final entry = currentList[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: entry.isMe ? AppColors.gold.withValues(alpha: 0.05) : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: entry.isMe ? AppColors.gold.withValues(alpha: 0.3) : AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 24,
                      child: Text(
                        '#${entry.rank}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: entry.rank <= 3 ? AppColors.gold : AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Avatar
                    Text(entry.avatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: entry.isMe ? FontWeight.w900 : FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                    // XP
                    Text(
                      '${entry.xp} XP',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Achievements ────────────────────────────────────────────────────

  Widget _buildAchievementsTab(CodingPracticeState s) {
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
              // Icon Circle
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

              // Labels
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

              // Locked status check
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

  // ── Tab 4: Statistics ──────────────────────────────────────────────────────

  Widget _buildStatsTab(CodingPracticeState s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Large summary metrics
          Row(
            children: [
              _statSquare('Solved Issues', '${s.solvedCount}', 'Baseline + local'),
              const SizedBox(width: 12),
              _statSquare('Average Acc', '94.2%', 'Test case score'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statSquare('Learning Time', '8.4 hrs', 'Total active editor'),
              const SizedBox(width: 12),
              _statSquare('Streak Max', '12 Days', 'Consistency peak'),
            ],
          ),
          const SizedBox(height: 24),

          // Topic reviews
          Text(
            'Career Topic Insights',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 12),
          _insightRow('🔥 Favorite Area', 'Python Algorithms'),
          const SizedBox(height: 8),
          _insightRow('⚠️ Weak Target', 'SQL Aggregate Windowing'),
        ],
      ),
    );
  }

  Widget _statSquare(String label, String value, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _insightRow(String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark)),
          Text(val, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
        ],
      ),
    );
  }
}
