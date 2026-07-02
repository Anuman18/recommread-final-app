import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';

class AiRecommendationSection extends StatefulWidget {
  const AiRecommendationSection({super.key, required this.recommendations});
  final List<AiRecommendation> recommendations;

  @override
  State<AiRecommendationSection> createState() => _AiRecommendationSectionState();
}

class _AiRecommendationSectionState extends State<AiRecommendationSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    final count = widget.recommendations.length;
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnims = List.generate(count, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(i * 0.15, (i * 0.15 + 0.6).clamp(0, 1), curve: Curves.easeOutCubic),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recommendations.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'AI Recommendation',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              ShaderMask(
                shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                child: Text(
                  'Powered by AI',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Recommendation cards
          ...List.generate(widget.recommendations.length, (i) {
            final rec = widget.recommendations[i];
            return AnimatedBuilder(
              animation: _cardAnims[i],
              builder: (_, child) => Opacity(
                opacity: _cardAnims[i].value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - _cardAnims[i].value)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AiRecCard(rec: rec),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AiRecCard extends StatelessWidget {
  const _AiRecCard({required this.rec});
  final AiRecommendation rec;

  Color get _typeColor {
    switch (rec.type) {
      case 'warn':      return const Color(0xFFFF7043);
      case 'celebrate': return const Color(0xFF4CAF50);
      case 'encourage': return AppColors.gold;
      default:          return const Color(0xFF6C8EFF);
    }
  }

  IconData get _typeIcon {
    switch (rec.type) {
      case 'warn':      return Icons.warning_amber_rounded;
      case 'celebrate': return Icons.celebration_rounded;
      case 'encourage': return Icons.local_fire_department_rounded;
      default:          return Icons.lightbulb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _typeColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(rec.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),

          // Message + CTA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                    height: 1.45,
                  ),
                ),
                if (rec.ctaLabel != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rec.ctaLabel!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _typeColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: _typeColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Type icon indicator
          Icon(_typeIcon, size: 18, color: _typeColor.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
