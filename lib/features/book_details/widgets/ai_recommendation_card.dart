import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Glassmorphism card showing the AI-generated recommendation reason.
class AiRecommendationCard extends StatefulWidget {
  const AiRecommendationCard({super.key, required this.reason});
  final String reason;

  @override
  State<AiRecommendationCard> createState() => _AiRecommendationCardState();
}

class _AiRecommendationCardState extends State<AiRecommendationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkleCtrl;
  late final Animation<double> _sparkleAnim;

  @override
  void initState() {
    super.initState();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _sparkleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sparkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            const Color(0xFF4527A0).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              AnimatedBuilder(
                animation: _sparkleAnim,
                builder: (_, __) => ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.goldGradient.createShader(b),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 22,
                    color:
                        Colors.white.withValues(alpha: _sparkleAnim.value),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Why AI Recommended This',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Reason text
          Text(
            widget.reason,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.65,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 14),
          // Confidence bar
          Row(
            children: [
              Text(
                'Match Score',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.94,
                    backgroundColor:
                        AppColors.gold.withValues(alpha: 0.15),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '94%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
