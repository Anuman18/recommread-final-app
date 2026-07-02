import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import 'ai_learning_provider.dart';

class LearningAnalyticsScreen extends ConsumerWidget {
  const LearningAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiLearningProvider);
    final a = state.analytics;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Radial Knowledge Retention Card
                      _buildRetentionCard(a.retentionRate),
                      const SizedBox(height: 20),
                      // Analytics grid parameters
                      Row(
                        children: [
                          _buildAnalyticParameter('Quiz Accuracy', '${(a.quizAccuracy * 100).round()}%', '⚡', const Color(0xFF6EC6E2)),
                          const SizedBox(width: 12),
                          _buildAnalyticParameter('Avg Learn Score', '${a.avgLearningScore} / 5.0', '🏆', AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildAnalyticParameter('Revision Ratio', '${(a.revisionConsistency * 100).round()}%', '🔄', const Color(0xFF82E2A0)),
                          const SizedBox(width: 12),
                          _buildAnalyticParameter('Synaptic Speed', '1.2s avg', '⏱️', const Color(0xFFE26EBD)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Strongest / Weakest Topics lists
                      _buildTopicsSection('💪 Strongest Knowledge Domains', a.strongestTopics, const Color(0xFF82E2A0)),
                      const SizedBox(height: 20),
                      _buildTopicsSection('⚠️ Weakest Knowledge Domains', a.weakestTopics, const Color(0xFFE26EBD)),
                      const SizedBox(height: 28),
                      // Recommended Revision
                      _buildRecommendedSection(a.recommendedRevision),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.darkBorder)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textPrimaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Learning Analytics', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.4)),
              Text('AI retention models', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionCard(double rate) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Circular Progress indicator
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 8,
                  backgroundColor: AppColors.darkElevated,
                  color: AppColors.gold,
                ),
                Text(
                  '${(rate * 100).round()}%',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knowledge Retention', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                const SizedBox(height: 4),
                Text('Estimated memory index based on quiz accuracy, scenario checks, and revision consistency cycles.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticParameter(String label, String value, String icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection(String title, List<String> topics, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(List<String> revisions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Recommended Revisions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 12),
          ...revisions.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right_rounded, color: AppColors.gold, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
