import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AiRevisionCenterScreen extends ConsumerStatefulWidget {
  const AiRevisionCenterScreen({super.key});

  @override
  ConsumerState<AiRevisionCenterScreen> createState() => _AiRevisionCenterScreenState();
}

class _AiRevisionCenterScreenState extends ConsumerState<AiRevisionCenterScreen> {
  int _activeFlashCardIndex = 0;
  bool _revealed = false;

  final List<Map<String, String>> _revisionFCs = [
    {'q': 'Dave Brailsford methodology name?', 'a': 'Aggregation of Marginal Gains (1% improvements)'},
    {'q': 'What triggers a Habit loop?', 'a': 'The Cue (environmental stimulus)'},
    {'q': 'Where do you fall when habits fail?', 'a': 'The level of your Systems'},
    {'q': 'Atomic Habits focus area?', 'a': 'Identity transition over goal attainment'},
  ];

  @override
  Widget build(BuildContext context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Flashcard block
                      _buildHeader('⚡ Active Revision Deck', 'Daily active recall'),
                      const SizedBox(height: 12),
                      _buildFlashcardPanel(),
                      const SizedBox(height: 28),
                      // Revision Modules
                      _buildHeader('📅 Weekly Revision Blocks', 'Re-learning queues'),
                      const SizedBox(height: 12),
                      _buildRevisionModules(),
                      const SizedBox(height: 28),
                      // Core concepts
                      _buildHeader('🧠 Core Concepts Summary', 'Compounded memory parameters'),
                      const SizedBox(height: 12),
                      _buildConceptsList(),
                      const SizedBox(height: 28),
                      // Common mistakes
                      _buildHeader('⚠️ Common Traps & Mistakes', 'Prevent regression'),
                      const SizedBox(height: 12),
                      _buildMistakesPanel(),
                      const SizedBox(height: 28),
                      // Mind Map Placeholder
                      _buildHeader('🗺️ Cognitive Mind Maps', 'Visual node associations'),
                      const SizedBox(height: 12),
                      _buildMindMapPlaceholder(),
                      const SizedBox(height: 40),
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
              Text('AI Revision Center', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.4)),
              Text('Synaptic memory consolidation', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFlashcardPanel() {
    final fc = _revisionFCs[_activeFlashCardIndex];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _revealed = !_revealed);
      },
      child: Container(
        height: 140,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _revealed ? AppColors.gold : AppColors.darkBorder, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              _revealed ? 'ANSWER' : 'QUESTION',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _revealed ? AppColors.gold : AppColors.textSecondaryDark, letterSpacing: 1.5),
            ),
            const Spacer(),
            Text(
              _revealed ? fc['a']! : fc['q']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textTertiaryDark),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _activeFlashCardIndex = (_activeFlashCardIndex - 1 + _revisionFCs.length) % _revisionFCs.length;
                      _revealed = false;
                    });
                  },
                ),
                Text('${_activeFlashCardIndex + 1} / ${_revisionFCs.length}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiaryDark),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _activeFlashCardIndex = (_activeFlashCardIndex + 1) % _revisionFCs.length;
                      _revealed = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisionModules() {
    final modules = [
      {'title': 'Weekly Quiz Review', 'desc': 'Review 3 wrong MCQ answers from chapter tests', 'status': 'Pending', 'icon': '📝'},
      {'title': 'Hinglish Concept Breakdown', 'desc': 'Neurological synapse formation breakdown', 'status': 'Completed', 'icon': '🧠'},
    ];

    return Column(
      children: modules.map((m) {
        final pending = m['status'] == 'Pending';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkElevated),
                child: Text(m['icon']!, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['title']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 3),
                    Text(m['desc']!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pending ? AppColors.warning.withValues(alpha: 0.12) : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  m['status']!,
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: pending ? AppColors.warning : AppColors.success),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConceptsList() {
    final concepts = [
      {'title': 'Atomic Habits: System vs Goals', 'desc': 'Systems govern iterative daily metrics, while goals are merely benchmarks. Fix systems first.'},
      {'title': 'Deep Work: Concentration Thresholds', 'desc': 'Attention residue prevents rapid context switches. Block 90+ min for focus parameters.'},
    ];

    return Column(
      children: concepts.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['title']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                const SizedBox(height: 6),
                Text(c['desc']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.4)),
              ],
            ),
          )).toList(),
    );
  }

  Widget _buildMistakesPanel() {
    final mistakes = [
      'Forgetting that cues must be physically obvious in the immediate workspace.',
      'Allowing context switches in under 30 minutes, producing high attention residue.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: mistakes.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(m, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error.withValues(alpha: 0.85)))),
                ],
              ),
            )).toList(),
      ),
    );
  }

  Widget _buildMindMapPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visual node outlines
          const Opacity(
            opacity: 0.15,
            child: Icon(Icons.schema_rounded, size: 80, color: AppColors.gold),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Habit Vector Mind Map', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const SizedBox(height: 4),
              Text('Mapped: atomic_habits_ch1.map', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark)),
            ],
          ),
        ],
      ),
    );
  }
}
