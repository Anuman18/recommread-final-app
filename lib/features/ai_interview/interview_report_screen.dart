import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'interview_provider.dart';

class InterviewReportScreen extends ConsumerStatefulWidget {
  const InterviewReportScreen({super.key});

  @override
  ConsumerState<InterviewReportScreen> createState() => _InterviewReportScreenState();
}

class _InterviewReportScreenState extends ConsumerState<InterviewReportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final List<_ConfettiParticle> _particles;
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _particles = List.generate(40, (i) {
      final rand = Random();
      return _ConfettiParticle(
        color: [AppColors.gold, const Color(0xFF6C8EFF), const Color(0xFF4CAF50), const Color(0xFFFFBC42)][rand.nextInt(4)],
        angle: rand.nextDouble() * 2 * pi,
        speed: rand.nextDouble() * 8 + 3,
        size: rand.nextDouble() * 8 + 4,
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);
    final report = state.latestReport;

    if (report == null) {
      return const Scaffold(backgroundColor: AppColors.darkBg, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Content
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appbar leading
                  _buildHeader(context),

                  // Scroll body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overall Score Card
                          _buildOverallScoreProgress(report),
                          const SizedBox(height: 24),

                          // Reward Strip banner
                          _buildRewardsBanner(report),
                          const SizedBox(height: 24),

                          // Strengths & Weak Areas
                          _buildInsightsList('✅ Strong Points', report.strengths, const Color(0xFF4CAF50)),
                          const SizedBox(height: 20),
                          _buildInsightsList('⚠️ Development Areas', report.weakAreas, AppColors.error),
                          const SizedBox(height: 20),
                          _buildInsightsList('📚 Topics to Revise', report.topicsToRevise, AppColors.gold),
                          const SizedBox(height: 24),

                          // Recommendations (Missions, Projects, Coding Practice)
                          _buildRecommendationsSection(report),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti overlay splash
          if (_showConfetti)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showConfetti = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.75),
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final w = MediaQuery.of(context).size.width;
                      final h = MediaQuery.of(context).size.height;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ..._particles.map((p) {
                            final t = _ctrl.value;
                            final x = w / 2 + cos(p.angle) * p.speed * 40 * t;
                            final y = h / 2 + sin(p.angle) * p.speed * 40 * t + 80 * t * t;
                            return Positioned(
                              left: x,
                              top: y,
                              child: Opacity(
                                opacity: (1 - t).clamp(0.0, 1.0),
                                child: Container(width: p.size, height: p.size, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
                              ),
                            );
                          }),
                          ScaleTransition(
                            scale: _scale,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 36),
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
                                boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 30)],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🏆', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 16),
                                  Text('ROUND COMPLETED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 2.0)),
                                  const SizedBox(height: 6),
                                  Text(report.typeName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark), textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Overall Score: ${report.overallScore.round()}%',
                                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.gold),
                                  ),
                                  const SizedBox(height: 24),
                                  Text('Tap anywhere to view report details', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header app bar ─────────────────────────────────────────────────────────

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
              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Interview Report',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Overall Score card ─────────────────────────────────────────────────────

  Widget _buildOverallScoreProgress(InterviewReport r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.typeName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
              Text('${r.overallScore.round()}% Score', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 7, color: AppColors.darkElevated),
                FractionallySizedBox(
                  widthFactor: r.overallScore / 100.0,
                  child: Container(height: 7, decoration: const BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.all(Radius.circular(4)))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reward Banner ──────────────────────────────────────────────────────────

  Widget _buildRewardsBanner(InterviewReport r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _rewardItem('⚡ +${r.xpGained} XP', 'Vocal simulation bonus'),
          Container(width: 0.5, height: 32, color: AppColors.gold.withValues(alpha: 0.25)),
          _rewardItem('🪙 +${r.coinsGained} Coins', 'Store credits earned'),
          Container(width: 0.5, height: 32, color: AppColors.gold.withValues(alpha: 0.25)),
          _rewardItem('📈 +3.5 Readiness', 'Interview index shift'),
        ],
      ),
    );
  }

  Widget _rewardItem(String val, String desc) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.gold)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.inter(fontSize: 7, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Insights Lists ─────────────────────────────────────────────────────────

  Widget _buildInsightsList(String sectionTitle, List<String> list, Color badgeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        const SizedBox(height: 8),
        ...list.map((str) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(str, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.4)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Recommendations lists ──────────────────────────────────────────────────

  Widget _buildRecommendationsSection(InterviewReport r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended Practice', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        const SizedBox(height: 10),
        
        // Recommended project
        if (r.recommendedProjects.isNotEmpty)
          _recCard('💻 Project Track:', r.recommendedProjects.first, () {
            context.push('/projects');
          }),

        const SizedBox(height: 8),
        
        // Recommended Coding Practice
        if (r.recommendedCoding.isNotEmpty)
          _recCard('🧩 Coding Challenge:', r.recommendedCoding.first, () {
            context.push('/coding-practice');
          }),
      ],
    );
  }

  Widget _recCard(String category, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 0.8)),
                  const SizedBox(height: 3),
                  Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  const _ConfettiParticle({required this.color, required this.angle, required this.speed, required this.size});
}
