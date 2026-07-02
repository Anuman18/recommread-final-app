import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'animated_nav_bar.dart';

/// The main shell that wraps all tab screens with the animated bottom nav.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: navigationShell,
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ── Stub screen widget shared by Search / Library / AI Coach / Profile ─────

class ComingSoonStub extends StatefulWidget {
  const ComingSoonStub({
    super.key,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.gradientColors,
  });

  final String title;
  final String emoji;
  final String subtitle;
  final List<Color> gradientColors;

  @override
  State<ComingSoonStub> createState() => _ComingSoonStubState();
}

class _ComingSoonStubState extends State<ComingSoonStub>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradientColors.first
                                .withValues(alpha: 0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Coming in next release',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
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
