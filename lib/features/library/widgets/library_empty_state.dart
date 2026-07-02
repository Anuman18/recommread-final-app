import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.buttonText,
  });

  final String emoji;
  final String title;
  final String description;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji container with gold halo shadow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: AnimatedButton(
                onPressed: () {
                  context.go('/search');
                },
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
