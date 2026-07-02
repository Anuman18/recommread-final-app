import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import 'coding_practice_provider.dart';

class QuestionDetailsScreen extends ConsumerStatefulWidget {
  const QuestionDetailsScreen({super.key, required this.question});
  final CodingQuestion question;

  @override
  ConsumerState<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends ConsumerState<QuestionDetailsScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _codeCtrl;
  int _selectedTab = 0; // 0: Description, 1: Hints, 2: Editorial, 3: Resources
  bool _isRunning = false;
  bool _isSubmitting = false;
  bool _showSubmissionResult = false;
  bool _passedAll = false;
  int _visibleHintCount = 0;

  // Simulation Metrics
  int _passedTestCases = 0;
  int _totalTestCases = 5;
  int _execTimeMs = 12;
  double _memMb = 1.1;

  // Reward Splash Overlay
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    // Default template code depending on question topic
    String template = 'def solve(arr):\n    # Write your python code here\n    pass';
    if (widget.question.topicId.contains('sql')) {
      template = 'SELECT *\nFROM Employee\nWHERE salary > 100000;';
    } else if (widget.question.topicId.contains('numpy')) {
      template = 'import numpy as np\n\ndef dot_product(A, B):\n    return np.dot(A, B)';
    } else if (widget.question.topicId.contains('pandas')) {
      template = 'import pandas as pd\n\ndef filter_ages(df):\n    return df';
    }
    _codeCtrl = TextEditingController(text: template);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Color get _difficultyColor {
    switch (widget.question.difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFFBC42);
      case 'hard':
        return const Color(0xFFE91E63);
      default:
        return AppColors.gold;
    }
  }

  void _runCodeSimulate() async {
    setState(() {
      _isRunning = true;
      _showSubmissionResult = false;
    });

    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1400));

    setState(() {
      _isRunning = false;
      _showSubmissionResult = true;
      _passedAll = true; // Simulating successful run
      _passedTestCases = 5;
      _execTimeMs = Random().nextInt(10) + 8;
      _memMb = 1.0 + (Random().nextDouble() * 0.4);
    });
  }

  void _submitSolutionSimulate(CodingQuestion liveQ) async {
    setState(() {
      _isSubmitting = true;
    });

    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 1800));

    setState(() {
      _isSubmitting = false;
      _showSubmissionResult = true;
      _passedAll = true;
      _passedTestCases = 5;
      _execTimeMs = Random().nextInt(6) + 6;
      _memMb = 1.0 + (Random().nextDouble() * 0.2);
    });

    if (liveQ.status != 'solved') {
      // Award rewards in Provider
      await ref.read(codingPracticeProvider.notifier).submitSolution(liveQ.id, _codeCtrl.text);
      
      // Play Confetti Splash
      setState(() {
        _showCelebration = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(codingPracticeProvider);
    final liveQ = findQuestionById(widget.question.id, state.questions) ?? widget.question;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main column
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Appbar ──────────────────────────────────────────────────
                  _buildAppBar(context, liveQ),

                  // ── Upper Split: Description & Console Toggles ──────────────
                  _buildTabSelectionBar(liveQ),
                  const SizedBox(height: 10),

                  // ── Scrollable detail panels ───────────────────────────────
                  Expanded(
                    flex: 12,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      child: _buildTabContent(liveQ),
                    ),
                  ),

                  // ── Code Editor Console Pane ────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: AppColors.darkBorder, height: 12),
                  ),

                  // Editor title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Coding Console',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
                        ),
                        Text(
                          liveQ.topicId.contains('sql') ? 'SQL' : 'Python 3',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  // Code Text Area
                  Expanded(
                    flex: 9,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _codeCtrl,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.firaCode(
                          color: const Color(0xFF82E2A0),
                          fontSize: 12,
                          height: 1.45,
                        ),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
                    ),
                  ),

                  // Simulation results console popup (if visible)
                  if (_showSubmissionResult) _buildResultConsolePanel(liveQ),

                  // Action Buttons row
                  _buildConsoleActionRow(liveQ),
                ],
              ),

              // Confetti Splash Overlay
              if (_showCelebration)
                Positioned.fill(
                  child: _ConfettiSplash(
                    question: liveQ,
                    onDismiss: () => setState(() => _showCelebration = false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Headers & Meta ─────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, CodingQuestion q) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.darkBorder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
                Row(
                  children: [
                    Text(q.difficulty, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _difficultyColor)),
                    const SizedBox(width: 6),
                    Text('•  ${q.timeMin} mins estim.', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondaryDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Toggles ────────────────────────────────────────────────────────────

  Widget _buildTabSelectionBar(CodingQuestion q) {
    final tabs = ['Problem', 'Hints', 'Editorial', 'Resources'];
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = i);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
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

  // ── Tab Content resolver ───────────────────────────────────────────────────

  Widget _buildTabContent(CodingQuestion q) {
    switch (_selectedTab) {
      case 0:
        return _buildProblemTab(q);
      case 1:
        return _buildHintsTab(q);
      case 2:
        return _buildEditorialTab(q);
      case 3:
        return _buildResourcesTab(q);
      default:
        return _buildProblemTab(q);
    }
  }

  // ── Tab 1: Description ─────────────────────────────────────────────────────

  Widget _buildProblemTab(CodingQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.problemStatement, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.5)),
        const SizedBox(height: 20),

        // Examples
        ...List.generate(q.examples.length, (i) {
          final e = q.examples[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Example ${i + 1}:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
                  const SizedBox(height: 8),
                  Text('Input: ${e.input}', style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 4),
                  Text('Output: ${e.output}', style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.textPrimaryDark)),
                  if (e.explanation != null) ...[
                    const SizedBox(height: 6),
                    Text('Explanation: ${e.explanation}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark, height: 1.4)),
                  ],
                ],
              ),
            ),
          );
        }),

        // Constraints
        if (q.constraints.isNotEmpty) ...[
          Text('Constraints:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
          const SizedBox(height: 6),
          ...q.constraints.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('•  $c', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark)),
              )),
        ],
      ],
    );
  }

  // ── Tab 2: Hints ───────────────────────────────────────────────────────────

  Widget _buildHintsTab(CodingQuestion q) {
    if (q.hints.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(q.hints.length, (i) {
        final revealed = _visibleHintCount > i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hint ${i + 1}:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
                    if (!revealed)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _visibleHintCount = i + 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Reveal Hint', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gold)),
                        ),
                      ),
                  ],
                ),
                if (revealed) ...[
                  const SizedBox(height: 8),
                  Text(q.hints[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.45)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Tab 3: Editorial ───────────────────────────────────────────────────────

  Widget _buildEditorialTab(CodingQuestion q) {
    final solved = q.status == 'solved';
    if (!solved) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              'Editorial Locked',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Submit a correct solution to unlock full algorithms review, efficiency metrics, and code explanations.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Algorithm Analysis', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        const SizedBox(height: 8),
        Text(q.editorial, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.5)),
      ],
    );
  }

  // ── Tab 4: Resources ───────────────────────────────────────────────────────

  Widget _buildResourcesTab(CodingQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.docUrl.isNotEmpty) ...[
          _resourceCard(Icons.article_rounded, 'Official API Reference', q.docUrl),
          const SizedBox(height: 8),
        ],
        if (q.videoUrl.isNotEmpty) ...[
          _resourceCard(Icons.play_circle_fill_rounded, 'Visual Walkthrough Video', q.videoUrl),
        ],
      ],
    );
  }

  Widget _resourceCard(IconData icon, String title, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await launchUrl(uri)) {}
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiaryDark),
          ],
        ),
      ),
    );
  }

  // ── Bottom results panel ───────────────────────────────────────────────────

  Widget _buildResultConsolePanel(CodingQuestion q) {
    final statusColor = _passedAll ? const Color(0xFF4CAF50) : AppColors.error;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_passedAll ? Icons.check_circle_rounded : Icons.cancel_rounded, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Text(
                _passedAll ? 'Submission Accepted!' : 'Test Cases Failed',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: statusColor),
              ),
              const Spacer(),
              Text(
                '$_passedTestCases / $_totalTestCases Passed',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricItem('Execution Time', '$_execTimeMs ms'),
              _metricItem('Memory Usage', '${_memMb.toStringAsFixed(1)} MB'),
              _metricItem('XP Gained', '+${q.xpReward} XP'),
              _metricItem('Coins Gained', '+${q.coinsReward} Coins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
      ],
    );
  }

  // ── Console Action Row ─────────────────────────────────────────────────────

  Widget _buildConsoleActionRow(CodingQuestion q) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      color: AppColors.darkCard,
      child: Row(
        children: [
          // Run Tests
          Expanded(
            child: GestureDetector(
              onTap: _isRunning || _isSubmitting ? null : _runCodeSimulate,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Center(
                  child: _isRunning
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2))
                      : Text('Run Tests', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Submit Code
          Expanded(
            child: GestureDetector(
              onTap: _isRunning || _isSubmitting ? null : () => _submitSolutionSimulate(q),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.darkBg, strokeWidth: 2))
                      : Text('Submit Code', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CONFETTI SUCCESS CELEBRATION ─────────────────────────────────────────────

class _ConfettiSplash extends StatefulWidget {
  const _ConfettiSplash({required this.question, required this.onDismiss});
  final CodingQuestion question;
  final VoidCallback onDismiss;

  @override
  State<_ConfettiSplash> createState() => _ConfettiSplashState();
}

class _ConfettiSplashState extends State<_ConfettiSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _particles = List.generate(40, (i) {
      final rand = Random();
      return _Particle(
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
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Particles
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

                // Card info
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
                        const Text('🎯', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('CHALLENGE PASSED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 2.0)),
                        const SizedBox(height: 6),
                        Text(widget.question.title, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryDark, height: 1.4), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('+${widget.question.xpReward} XP', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gold)),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFFFBC42).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('+${widget.question.coinsReward} Coins', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFFFFBC42))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Tap anywhere to continue', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  const _Particle({required this.color, required this.angle, required this.speed, required this.size});
}
