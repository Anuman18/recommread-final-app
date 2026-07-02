import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'coding_practice_provider.dart';

class TopicQuestionsScreen extends ConsumerWidget {
  const TopicQuestionsScreen({super.key, required this.topic});
  final CodingTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(codingPracticeProvider);

    // Filter questions matching this topic
    final filtered = state.questions.where((q) => q.topicId == topic.id).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 14, color: AppColors.textPrimaryDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Solve problems to unlock career paths',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Topic Completion',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
                                ),
                                Text(
                                  '${topic.completedQuestions} / ${topic.totalQuestions}',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(height: 5, color: AppColors.darkElevated),
                                  FractionallySizedBox(
                                    widthFactor: topic.progress,
                                    child: Container(height: 5, decoration: const BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.all(Radius.circular(4)))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Questions List
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyQuestionsPlaceholder()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final q = filtered[i];
                          return _QuestionCard(question: q);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Question Card Widget ─────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});
  final CodingQuestion question;

  Color get _difficultyColor {
    switch (question.difficulty.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = question.status == 'solved'
        ? const Color(0xFF4CAF50)
        : question.status == 'in_progress'
            ? const Color(0xFF2196F3)
            : AppColors.textTertiaryDark;

    final statusText = question.status == 'solved'
        ? 'Solved'
        : question.status == 'in_progress'
            ? 'Attempting'
            : 'Unsolved';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/coding-practice/question/${question.id}', extra: question);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _difficultyColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryDark,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: Companies
            if (question.companies.isNotEmpty) ...[
              Text(
                'Asked at: ${question.companies.join(', ')}',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],

            // Row 3: Meta Info (Difficulty, Time, Rewards)
            Row(
              children: [
                // Difficulty
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.difficulty,
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _difficultyColor),
                  ),
                ),
                const SizedBox(width: 8),
                // Time
                const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondaryDark),
                const SizedBox(width: 4),
                Text(
                  '${question.timeMin}m',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                // Rewards
                Text('⚡ +${question.xpReward} XP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold)),
                const SizedBox(width: 8),
                Text('🪙 +${question.coinsReward}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFFFBC42))),
              ],
            ),
            const SizedBox(height: 14),

            // Action: Start Button
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                context.push('/coding-practice/question/${question.id}', extra: question);
              },
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_difficultyColor, _difficultyColor.withValues(alpha: 0.75)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: _difficultyColor.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: Text(
                    question.status == 'solved' ? 'Re-run Code' : 'Start Coding',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
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

class _EmptyQuestionsPlaceholder extends StatelessWidget {
  const _EmptyQuestionsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No questions loaded for this topic.',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark),
      ),
    );
  }
}
