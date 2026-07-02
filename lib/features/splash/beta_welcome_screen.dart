import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';

class BetaWelcomeScreen extends StatelessWidget {
  const BetaWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Tech Glow Icon
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🧪',
                        style: TextStyle(fontSize: 42),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Welcome Title
                Text(
                  'Welcome to\nRecommRead Beta',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Beta Status description
                Text(
                  'You have been selected as an early testing member of the RecommRead Career OS. The application is under active deployment.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Call to feedback
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Help Us Improve!',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please report any bugs, incorrect responses, or system feedback using the settings page options.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Continue CTA
                AnimatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_beta_welcome', true);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                  child: Text(
                    'Continue into App',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBg,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
