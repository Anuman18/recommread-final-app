import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// A reusable section header row: bold title on the left, "See All" on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: -0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A small animated badge (e.g. for AI picks "Today's" pill).
class GoldBadge extends StatelessWidget {
  const GoldBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
