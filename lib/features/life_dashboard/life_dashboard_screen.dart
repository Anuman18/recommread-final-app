import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../profile/xp_provider.dart';
import 'life_dashboard_provider.dart';
import 'widgets/today_header_card.dart';
import 'widgets/daily_agenda_card.dart';
import 'widgets/skill_dashboard_card.dart';
import 'widgets/mission_center_card.dart';
import 'widgets/achievement_center_card.dart';
import 'widgets/daily_rewards_card.dart';
import 'widgets/reports_card.dart';

class LifeDashboardScreen extends ConsumerStatefulWidget {
  const LifeDashboardScreen({super.key});

  @override
  ConsumerState<LifeDashboardScreen> createState() => _LifeDashboardScreenState();
}

class _LifeDashboardScreenState extends ConsumerState<LifeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _tabCtrl;
  int _selectedTab = 0;
  final _scrollCtrl = ScrollController();

  static const _tabs = ['Today', 'Skills', 'Missions', 'Growth'];
  static const _tabIcons = ['📋', '🕸️', '🎯', '📈'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(lifeDashboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lifeDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.gold,
                  backgroundColor: AppColors.darkCard,
                  child: CustomScrollView(
                    controller: _scrollCtrl,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      if (!state.isLoaded)
                        const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 100),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(_buildTabContent()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final xp = ref.watch(xpProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); context.go('/home'); },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.darkBorder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Life Dashboard', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.4)),
              Text('Your daily operating system', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 8)],
            ),
            child: Text('Lv ${xp.level}  •  ${xp.currentXp} XP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = i);
                _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_tabIcons[i], style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        _tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.darkBg : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _todayTab();
      case 1: return _skillsTab();
      case 2: return _missionsTab();
      case 3: return _growthTab();
      default: return _todayTab();
    }
  }

  List<Widget> _todayTab() => [
    const TodayHeaderCard(),
    const SizedBox(height: 20),
    _buildLearningEngineHub(),
    const SizedBox(height: 20),
    const DailyRewardsCard(),
    const SizedBox(height: 20),
    const DailyAgendaCard(),
    const SizedBox(height: 20),
    _buildUpcomingMilestones(),
  ];

  List<Widget> _skillsTab() => [
    const SkillDashboardCard(),
  ];

  List<Widget> _missionsTab() => [
    const MissionCenterCard(),
    const SizedBox(height: 20),
    const _ProjectTracksBanner(),
    const SizedBox(height: 20),
    const _CodingPracticeBanner(),
  ];

  List<Widget> _growthTab() => [
    const WeeklyReportCard(),
    const SizedBox(height: 20),
    const MonthlyReportCard(),
    const SizedBox(height: 20),
    const AchievementCenterCard(),
  ];

  Widget _buildUpcomingMilestones() {
    final milestones = [
      {'icon': '⚡', 'title': 'Reach Level 2', 'desc': '1750 XP needed', 'progress': 0.42},
      {'icon': '💎', 'title': '30-Day Streak', 'desc': '23 days to go', 'progress': 0.23},
      {'icon': '🏆', 'title': 'Complete 5 Missions', 'desc': '1 more to go', 'progress': 0.8},
    ];
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
              const Text('🔮', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Upcoming Milestones', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          ...milestones.map((m) {
            final progress = m['progress'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(m['icon'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark)),
                            Text(m['desc'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                          ],
                        ),
                      ),
                      Text('${(progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(height: 4, color: AppColors.darkElevated),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(height: 4, decoration: const BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.all(Radius.circular(4)))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLearningEngineHub() {
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
              const Text('🧠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('AI Learning Engine', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/life-dashboard/revision-center');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        const Text('🔄', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),
                        Text('Revision Center', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                        const SizedBox(height: 3),
                        Text('Recall & mind maps', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/life-dashboard/analytics');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkBorder, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        const Text('📈', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),
                        Text('Analytics', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                        const SizedBox(height: 3),
                        Text('Retention index', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectTracksBanner extends StatelessWidget {
  const _ProjectTracksBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        context.push('/projects');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1D36), Color(0xFF0D0F1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💻', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Tracks',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build real products & verify your skills with AI Mentors.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gold,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodingPracticeBanner extends StatelessWidget {
  const _CodingPracticeBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        context.push('/coding-practice');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF221326), Color(0xFF120914)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFAB47BC).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAB47BC).withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFAB47BC).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧩', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coding Practice',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solve quick algorithmic challenges & track leaderboard rankings.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFAB47BC),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
