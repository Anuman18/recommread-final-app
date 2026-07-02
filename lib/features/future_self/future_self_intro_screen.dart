import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_provider.dart';
import '../profile/xp_provider.dart';
import '../profile/profile_provider.dart';
import 'future_self_provider.dart';

class FutureSelfIntroScreen extends ConsumerStatefulWidget {
  const FutureSelfIntroScreen({super.key});

  @override
  ConsumerState<FutureSelfIntroScreen> createState() => _FutureSelfIntroScreenState();
}

class _FutureSelfIntroScreenState extends ConsumerState<FutureSelfIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _avatarCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _avatarScale;
  late Animation<double> _glowAnim;

  final List<String> _lines = [];
  final List<String> _displayedLines = [];
  int _currentLineIndex = 0;
  bool _showBeginButton = false;
  String _currentTyping = '';

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _avatarScale = CurvedAnimation(parent: _avatarCtrl, curve: Curves.easeOutBack);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    _avatarCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initLines());
  }

  void _initLines() {
    final profileState = ref.read(profileProvider);
    final xpState = ref.read(xpProvider);
    final notifier = ref.read(futureSelfProvider.notifier);
    final onboardingState = ref.read(onboardingProvider);
    final goalLabel = onboardingState.goal?.label ?? profileState.readingGoal.label;
    final lines = notifier.generateIntroLines(
      profileState.name,
      goalLabel,
      xpState.level,
      xpState.currentXp,
    );
    setState(() { _lines.addAll(lines); });
    Future.delayed(const Duration(milliseconds: 800), _typeNextLine);
  }

  Future<void> _typeNextLine() async {
    if (!mounted || _currentLineIndex >= _lines.length) {
      if (mounted) setState(() { _showBeginButton = true; });
      return;
    }
    final line = _lines[_currentLineIndex];
    setState(() { _currentTyping = ''; });
    for (int i = 0; i <= line.length; i++) {
      if (!mounted) return;
      setState(() { _currentTyping = line.substring(0, i); });
      await Future.delayed(const Duration(milliseconds: 38));
    }
    HapticFeedback.selectionClick();
    if (mounted) {
      setState(() {
        _displayedLines.add(line);
        _currentTyping = '';
        _currentLineIndex++;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      _typeNextLine();
    }
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A12), Color(0xFF12121E), Color(0xFF0D0D14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Avatar
              AnimatedBuilder(
                animation: Listenable.merge([_avatarScale, _glowAnim]),
                builder: (context, _) {
                  return ScaleTransition(
                    scale: _avatarScale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 120 + 20 * _glowAnim.value,
                          height: 120 + 20 * _glowAnim.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.15 + 0.1 * _glowAnim.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Avatar circle
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('✨', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        // Orbit ring
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.2 + 0.15 * _glowAnim.value),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'FUTURE SELF',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 40),
              // Dialogue lines
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ..._displayedLines.map((line) => _buildLine(line, done: true)),
                      if (_currentTyping.isNotEmpty) _buildLine(_currentTyping, done: false),
                    ],
                  ),
                ),
              ),
              // Begin button
              AnimatedOpacity(
                opacity: _showBeginButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, 0, 32, MediaQuery.of(context).padding.bottom + 32),
                  child: GestureDetector(
                    onTap: _showBeginButton ? _onBegin : null,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Let's Begin",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBg,
                          ),
                        ),
                      ),
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

  Widget _buildLine(String text, {required bool done}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4),
            ),
          ),
          Expanded(
            child: Text(
              text + (done ? '' : '|'),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: done ? AppColors.textPrimaryDark : AppColors.textPrimaryDark.withValues(alpha: 0.8),
                height: 1.5,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBegin() async {
    HapticFeedback.mediumImpact();
    await ref.read(futureSelfProvider.notifier).markIntroSeen();
    if (mounted) context.go('/future-self/dashboard');
  }
}
