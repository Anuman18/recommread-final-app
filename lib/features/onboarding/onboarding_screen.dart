import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';
import '../onboarding/onboarding_provider.dart';
import '../profile/profile_provider.dart';
import 'pages/reading_goal_page.dart';
import 'pages/reading_level_page.dart';
import 'pages/daily_time_page.dart';
import 'pages/preferred_language_page.dart';
import 'pages/ai_scan_page.dart';
import 'pages/career_preview_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  late final AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  static const _totalPages = 6;

  List<Widget> get _pages => [
        const CareerGoalPage(),
        const ReadingLevelPage(),
        const DailyTimePage(),
        const PreferredLanguagePage(),
        AiScanPage(onScanComplete: _next),
        const CareerPreviewPage(),
      ];

  final _pageTitles = const [
    'Who do you want to become?',
    'What\'s your current level?',
    'Daily learning commitment',
    'Preferred learning language',
    'AI Career Analyzer',
    'Your Career Roadmap',
  ];

  final _pageSubtitles = const [
    'Choose your target career — we\'ll build your complete roadmap',
    'Be honest — your AI plan adapts to exactly where you are',
    'How much time can you commit to transforming yourself daily?',
    'Your AI tutor will teach in your preferred style and language',
    'Synthesizing your personalized career learning path...',
    'Here\'s exactly what it takes to become who you want to be',
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _progressAnim = Tween<double>(
      begin: 1.0 / _totalPages,
      end: 1.0 / _totalPages,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  bool _canAdvance(OnboardingState s) {
    switch (_currentPage) {
      case 0:
        return s.goal != null;
      case 1:
        return s.level != null;
      case 2:
        return s.dailyTime != null;
      case 3:
        return s.language != null;
      case 4:
        return false; // auto-advances on scan complete
      case 5:
        return true;
      default:
        return false;
    }
  }

  void _animateProgress(int page) {
    final nextVal = (page + 1) / _totalPages;
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: nextVal,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
    _progressCtrl.forward(from: 0.0);
  }

  Future<void> _next() async {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
      _animateProgress(_currentPage);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _isCompleting = true);
      try {
        await ref.read(onboardingProvider.notifier).saveAndComplete();
        await ref.read(profileProvider.notifier).loadProfile();
        if (mounted) context.go('/future-self/intro');
      } catch (e) {
        if (mounted) {
          setState(() => _isCompleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.darkSurface,
              content: Text(
                'Failed to complete onboarding: $e. Please check your connection and try again.',
                style: GoogleFonts.inter(color: AppColors.textPrimaryDark),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _back() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _animateProgress(_currentPage);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final canAdvance = _canAdvance(state);
    final isScanPage = _currentPage == 4;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    // Back button
                    AnimatedOpacity(
                      opacity: _currentPage > 0 && !isScanPage ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _currentPage > 0 && !isScanPage ? _back : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Step counter
                    if (!isScanPage)
                      Text(
                        '${_currentPage + 1} of $_totalPages',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Progress bar ──────────────────────────────────────────
              if (!isScanPage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: AppColors.darkCard,
                          valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          minHeight: 3,
                        ),
                      );
                    },
                  ),
                ),

              if (!isScanPage) const SizedBox(height: 32),
              if (isScanPage) const SizedBox(height: 16),

              // ── Page title ────────────────────────────────────────────
              if (!isScanPage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(_currentPage),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accent dot
                        Container(
                          width: 28,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          _pageTitles[_currentPage],
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _pageSubtitles[_currentPage],
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: AppColors.textSecondaryDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!isScanPage) const SizedBox(height: 28),

              // ── Page content ──────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _pages,
                ),
              ),

              // ── Bottom CTA ────────────────────────────────────────────
              if (!isScanPage)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: AnimatedOpacity(
                    opacity: canAdvance ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedButton(
                      onPressed: canAdvance ? _next : null,
                      gradient: canAdvance ? AppColors.goldGradient : null,
                      backgroundColor:
                          canAdvance ? null : AppColors.darkElevated,
                      child: _isCompleting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.darkBg,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _totalPages - 1
                                      ? 'Begin My Career Journey'
                                      : 'Continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: canAdvance
                                        ? AppColors.darkBg
                                        : AppColors.textTertiaryDark,
                                  ),
                                ),
                                if (canAdvance) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == _totalPages - 1
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: AppColors.darkBg,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
