import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class CareerPreviewPage extends ConsumerStatefulWidget {
  const CareerPreviewPage({super.key});

  @override
  ConsumerState<CareerPreviewPage> createState() => _CareerPreviewPageState();
}

class _CareerPreviewPageState extends ConsumerState<CareerPreviewPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _itemAnims;

  static const _itemCount = 8; // header + 7 metrics

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _itemAnims = List.generate(_itemCount, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.07,
            (i * 0.07 + 0.5).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _getMetrics(ReadingGoal goal, ReadingLevel level, DailyTime time) {
    // Estimated learning time in months
    final int months;
    switch (level) {
      case ReadingLevel.beginner:     months = 18; break;
      case ReadingLevel.intermediate: months = 10; break;
      case ReadingLevel.advanced:     months = 5;  break;
    }

    // Projects estimate
    final int projects;
    switch (goal) {
      case ReadingGoal.aiEngineer:
      case ReadingGoal.dataScientist:        projects = 12; break;
      case ReadingGoal.fullStackDeveloper:
      case ReadingGoal.backendEngineer:
      case ReadingGoal.frontendEngineer:
      case ReadingGoal.softwareEngineer:     projects = 10; break;
      case ReadingGoal.uxDesigner:
      case ReadingGoal.productManager:       projects = 6;  break;
      case ReadingGoal.cyberSecurityEngineer:
      case ReadingGoal.devOpsEngineer:
      case ReadingGoal.cloudEngineer:        projects = 8;  break;
      default:                               projects = 5;  break;
    }

    // Coding questions
    final int coding;
    switch (goal) {
      case ReadingGoal.aiEngineer:
      case ReadingGoal.dataScientist:
      case ReadingGoal.softwareEngineer:
      case ReadingGoal.fullStackDeveloper:
      case ReadingGoal.backendEngineer:
      case ReadingGoal.frontendEngineer:
      case ReadingGoal.cyberSecurityEngineer:
      case ReadingGoal.devOpsEngineer:
      case ReadingGoal.cloudEngineer:        coding = 300; break;
      case ReadingGoal.productManager:       coding = 50;  break;
      case ReadingGoal.startupFounder:
      case ReadingGoal.entrepreneur:
      case ReadingGoal.digitalMarketer:
      case ReadingGoal.contentCreator:       coding = 0;   break;
      default:                               coding = 0;   break;
    }

    // Skills estimate
    final int skills;
    switch (goal) {
      case ReadingGoal.aiEngineer:           skills = 12; break;
      case ReadingGoal.fullStackDeveloper:   skills = 14; break;
      case ReadingGoal.cyberSecurityEngineer:skills = 10; break;
      case ReadingGoal.devOpsEngineer:
      case ReadingGoal.cloudEngineer:        skills = 11; break;
      default:                               skills = 8;  break;
    }

    // Interview & Job readiness %
    final int interview = level == ReadingLevel.advanced ? 85 : level == ReadingLevel.intermediate ? 72 : 60;
    final int job = interview - 10;

    return {
      'months': '$months months',
      'projects': '$projects projects',
      'coding': coding == 0 ? 'Not required' : '$coding questions',
      'skills': '$skills core skills',
      'interview': '$interview% match',
      'job': '$job% ready',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final goal = state.goal ?? ReadingGoal.aiEngineer;
    final level = state.level ?? ReadingLevel.beginner;
    final time = state.dailyTime ?? DailyTime.min60;
    final lang = state.language ?? PreferredLanguage.english;
    final metrics = _getMetrics(goal, level, time);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // ── Header Career Card ──────────────────────────────────────────
          _buildItem(
            0,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.18),
                    const Color(0xFF1A1228),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Emoji
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.3),
                          AppColors.darkCard,
                        ],
                      ),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Center(
                      child: Text(goal.emoji,
                          style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    goal.label,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShaderMask(
                    shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                    child: Text(
                      'Your AI Roadmap is Ready',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selection chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildChip(level.label, Icons.signal_cellular_alt_rounded),
                      _buildChip(time.label, Icons.timer_rounded),
                      _buildChip(lang.label, Icons.language_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Metric Cards ──────────────────────────────────────────────────
          _buildItem(1, _buildMetricCard(
            icon: '⏱️',
            label: 'Estimated Learning Time',
            value: metrics['months']!,
            color: const Color(0xFF6C8EFF),
          )),
          const SizedBox(height: 10),
          _buildItem(2, _buildMetricCard(
            icon: '🛠️',
            label: 'Estimated Projects',
            value: metrics['projects']!,
            color: const Color(0xFF4CAF50),
          )),
          const SizedBox(height: 10),
          _buildItem(3, _buildMetricCard(
            icon: '💻',
            label: 'Estimated Coding Questions',
            value: metrics['coding']!,
            color: const Color(0xFFFF7043),
          )),
          const SizedBox(height: 10),
          _buildItem(4, _buildMetricCard(
            icon: '🧩',
            label: 'Estimated Skills Required',
            value: metrics['skills']!,
            color: const Color(0xFFAB47BC),
          )),
          const SizedBox(height: 10),
          _buildItem(5, _buildMetricCard(
            icon: '🎤',
            label: 'Estimated Interview Readiness',
            value: metrics['interview']!,
            color: AppColors.gold,
          )),
          const SizedBox(height: 10),
          _buildItem(6, _buildMetricCard(
            icon: '💼',
            label: 'Estimated Job Readiness',
            value: metrics['job']!,
            color: const Color(0xFF26C6DA),
          )),
          const SizedBox(height: 10),
          // Ready banner
          _buildItem(
            7,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Your personalized AI Career OS is calibrated. Let\'s begin your transformation.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF81C784),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _itemAnims[index],
      builder: (_, c) => Opacity(
        opacity: _itemAnims[index].value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _itemAnims[index].value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gold),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
