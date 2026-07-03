import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../features/onboarding/onboarding_provider.dart';
import '../features/profile/profile_provider.dart';
import '../core/widgets/animated_button.dart';
import 'home_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/skeleton_loader.dart';
import 'widgets/today_mission_section.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/ai_recommendation_section.dart';
import 'widgets/learning_resources_section.dart';
import 'widgets/skill_progress_section.dart';
import 'widgets/weekly_progress_section.dart';
import 'widgets/upcoming_milestone_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  bool _fabVisible = true;
  final ScrollController _scrollCtrl = ScrollController();

  late final AnimationController _contentCtrl;

  // Stagger controllers for each section
  late final List<AnimationController> _sectionCtrls;
  late final List<Animation<double>> _sectionFades;
  late final List<Animation<Offset>> _sectionSlides;

  static const _sectionCount = 9;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Per-section stagger animations
    _sectionCtrls = List.generate(_sectionCount, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      );
    });
    _sectionFades = _sectionCtrls.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOut);
    }).toList();
    _sectionSlides = _sectionCtrls.map((c) {
      return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    }).toList();

    // Load home data with career context
    Future.microtask(() {
      final career = ref.read(profileProvider).readingGoal.name;
      ref.read(homeProvider.notifier).loadHomeData(career: career);
    });

    // Hide FAB on scroll down
    _scrollCtrl.addListener(() {
      final direction = _scrollCtrl.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _fabVisible) {
        setState(() => _fabVisible = false);
      } else if (direction == ScrollDirection.forward && !_fabVisible) {
        setState(() => _fabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _scrollCtrl.dispose();
    for (final c in _sectionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // Stagger-fire all section animations with 60ms delays
  Future<void> _fireStaggeredSections() async {
    for (int i = 0; i < _sectionCount; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (mounted) _sectionCtrls[i].forward();
    }
  }

  Future<void> _onRefresh() async {
    _contentCtrl.reset();
    for (final c in _sectionCtrls) {
      c.reset();
    }
    final career = ref.read(profileProvider).readingGoal.name;
    await ref.read(homeProvider.notifier).loadHomeData(career: career);
    _contentCtrl.forward();
    _fireStaggeredSections();
  }

  Widget _section(int index, Widget child) {
    return FadeTransition(
      opacity: _sectionFades[index],
      child: SlideTransition(
        position: _sectionSlides[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final profile = ref.watch(profileProvider);
    final isLoading = homeState.isLoading;

    // Fire stagger when content becomes available
    if (!isLoading && _sectionCtrls[0].status == AnimationStatus.dismissed) {
      _contentCtrl.forward();
      _fireStaggeredSections();
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      floatingActionButton: _FloatingAiButton(visible: _fabVisible),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.gold,
            backgroundColor: AppColors.darkCard,
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Header (always shown) ──────────────────────────────
                const SliverToBoxAdapter(child: HomeHeader()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                if (isLoading) ...[
                  // ── Skeleton loading state ─────────────────────────
                  const SliverToBoxAdapter(child: SkeletonMissionSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SkeletonContinueCard()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SkeletonAiRecSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildSkeletonSectionTitle(),
                        const SkeletonHorizontalSection(),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SkeletonSkillGrid()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SkeletonWeeklyProgress()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SkeletonMilestones()),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ] else if (homeState.errorMessage != null &&
                    homeState.missions.isEmpty) ...[
                  // ── Error state ─────────────────────────────────────
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              color: AppColors.error, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            homeState.errorMessage!,
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondaryDark,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 140,
                            child: AnimatedButton(
                              onPressed: _onRefresh,
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBg),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Real content ─────────────────────────────────────
                  // 1. Career context banner
                  SliverToBoxAdapter(
                    child: _section(
                      0,
                      _CareerContextBanner(career: profile.readingGoal.label),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // 2. Today's Mission
                  SliverToBoxAdapter(
                    child: _section(
                      1,
                      TodayMissionSection(missions: homeState.missions),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 3. Continue Learning
                  if (homeState.continueResource != null)
                    SliverToBoxAdapter(
                      child: _section(
                        2,
                        ContinueLearningCard(
                            resource: homeState.continueResource!),
                      ),
                    ),
                  if (homeState.continueResource != null)
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 4. AI Recommendation
                  if (homeState.aiRecommendations.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _section(
                        3,
                        AiRecommendationSection(
                            recommendations: homeState.aiRecommendations),
                      ),
                    ),
                  if (homeState.aiRecommendations.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 5. Learning Resources
                  if (homeState.learningResources.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _section(
                        4,
                        LearningResourcesSection(
                            resources: homeState.learningResources),
                      ),
                    ),
                  if (homeState.learningResources.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 6. Skill Progress
                  if (homeState.skills.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _section(
                        5,
                        SkillProgressSection(skills: homeState.skills),
                      ),
                    ),
                  if (homeState.skills.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 7. Weekly Progress
                  SliverToBoxAdapter(
                    child: _section(
                      6,
                      WeeklyProgressSection(stats: homeState.weeklyStats),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 8. Upcoming Milestones
                  if (homeState.milestones.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _section(
                        7,
                        UpcomingMilestoneSection(
                            milestones: homeState.milestones),
                      ),
                    ),
                  if (homeState.milestones.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 9. Quick access banners (Future Self + Life Dashboard)
                  SliverToBoxAdapter(
                    child: _section(8, const _QuickAccessBanners()),
                  ),

                  // Footer
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 100),
                      child: Center(
                        child: Text(
                          '✨ Powered by Career AI OS',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          ShimmerBox(width: 160, height: 18, borderRadius: 8),
          Spacer(),
          ShimmerBox(width: 50, height: 13, borderRadius: 6),
        ],
      ),
    );
  }
}

// ── Career Context Banner ─────────────────────────────────────────────────────

class _CareerContextBanner extends StatelessWidget {
  const _CareerContextBanner({required this.career});
  final String career;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.12),
              AppColors.darkCard,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.track_changes_rounded,
                    size: 18, color: AppColors.gold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondaryDark),
                  children: [
                    const TextSpan(text: 'Today\'s focus: '),
                    TextSpan(
                      text: career,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                    const TextSpan(text: ' path'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '● ACTIVE',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Access Banners ──────────────────────────────────────────────────────

class _QuickAccessBanners extends StatelessWidget {
  const _QuickAccessBanners();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _GlowBanner(
            title: 'Life Dashboard',
            subtitle: 'Your life operating system, metrics & reports',
            emoji: '📊',
            gradientColors: const [Color(0xFF12222E), Color(0xFF0D1821)],
            borderColor: const Color(0xFF82E2C0),
            buttonColor: const LinearGradient(
              colors: [Color(0xFF82E2C0), Color(0xFF6EC6E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/life-dashboard');
            },
          ),
        ],
      ),
    );
  }
}

class _GlowBanner extends StatefulWidget {
  const _GlowBanner({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    required this.borderColor,
    required this.buttonColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final Color borderColor;
  final Gradient buttonColor;
  final VoidCallback onTap;

  @override
  State<_GlowBanner> createState() => _GlowBannerState();
}

class _GlowBannerState extends State<_GlowBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.borderColor
                    .withValues(alpha: 0.2 + 0.15 * _glowAnim.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor
                      .withValues(alpha: 0.06 + 0.05 * _glowAnim.value),
                  blurRadius: 20,
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
                    shape: BoxShape.circle,
                    gradient: widget.buttonColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.borderColor
                            .withValues(alpha: 0.25 + 0.15 * _glowAnim.value),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (b) => widget.buttonColor.createShader(b),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.borderColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Open',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Floating AI Coach button ──────────────────────────────────────────────────

class _FloatingAiButton extends StatefulWidget {
  const _FloatingAiButton({required this.visible});
  final bool visible;

  @override
  State<_FloatingAiButton> createState() => _FloatingAiButtonState();
}

class _FloatingAiButtonState extends State<_FloatingAiButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _scalePress;
  late final Animation<double> _entranceAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scalePress =
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);
    _entranceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 280),
      curve:
          widget.visible ? Curves.elasticOut : Curves.easeIn,
      child: ScaleTransition(
        scale: _entranceAnim,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.reverse(),
          onTapUp: (_) => _pressCtrl.forward(),
          onTapCancel: () => _pressCtrl.forward(),
          onTap: () {
            HapticFeedback.mediumImpact();
            context.push('/ai-coach');
          },
          child: ScaleTransition(
            scale: _scalePress,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.darkBg, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Coach',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
