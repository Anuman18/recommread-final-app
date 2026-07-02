import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// Placeholder home screen shown after onboarding completes.
/// Full implementation is out of scope for this release.
class HomePlaceholder extends StatefulWidget {
  const HomePlaceholder({super.key});

  @override
  State<HomePlaceholder> createState() => _HomePlaceholderState();
}

class _HomePlaceholderState extends State<HomePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            blurRadius: 36,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'RR',
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBg,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldGradient.createShader(bounds),
                      child: Text(
                        'You\'re all set! 🎉',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your reading journey starts now.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Home screen coming soon.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
