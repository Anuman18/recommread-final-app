import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../models/book_model.dart';
import '../ai_learning_provider.dart';
import '../../profile/xp_provider.dart';

class AiTutorSheet extends ConsumerStatefulWidget {
  const AiTutorSheet({super.key, required this.book, required this.chapterIndex});
  final Book book;
  final int chapterIndex;

  @override
  ConsumerState<AiTutorSheet> createState() => _AiTutorSheetState();
}

class _AiTutorSheetState extends ConsumerState<AiTutorSheet> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _flashCardIndex = 0;
  bool _showFCAnswer = false;

  final List<Map<String, dynamic>> _modes = [
    {'id': '10yo', 'label': '10yo', 'icon': '👶'},
    {'id': 'Professor', 'label': 'Professor', 'icon': '👨‍🏫'},
    {'id': 'Hinglish', 'label': 'Hinglish', 'icon': '🗣️'},
    {'id': 'Analogies', 'label': 'Analogy', 'icon': '💡'},
    {'id': 'CaseStudies', 'label': 'Case Study', 'icon': '💼'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiLearningProvider);
    final data = ref.read(aiLearningProvider.notifier).generateTutorDataFor(
          widget.book.id,
          widget.chapterIndex,
          state.studyMode,
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top pull handle
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 18),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gold.withValues(alpha: 0.1)),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal AI Tutor', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
                      Text('Mastering Chapter ${widget.chapterIndex + 1}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
                    ],
                  ),
                  const Spacer(),
                  // Mode Selector Tab
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(10)),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(color: AppColors.darkElevated, borderRadius: BorderRadius.circular(8)),
                      labelColor: AppColors.gold,
                      unselectedLabelColor: AppColors.textSecondaryDark,
                      labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                      tabs: const [Tab(text: 'Beginner'), Tab(text: 'Advanced')],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // AI Study Modes Row
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _modes.length,
                itemBuilder: (context, i) {
                  final m = _modes[i];
                  final active = state.studyMode == m['id'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(aiLearningProvider.notifier).changeStudyMode(m['id']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.gold : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? Colors.transparent : AppColors.darkBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Text(m['icon'], style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            m['label'],
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.black87 : AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Content Scrolling Pane
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Content (Beginner vs Advanced Explanation)
                    SizedBox(
                      height: 120,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildExplanationCard(data.beginnerExplanation),
                          _buildExplanationCard(data.advancedExplanation),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Summary section
                    _buildSectionHeader('🧠 Chapter Synthesis', 'Summary of key concepts'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
                      child: Text(data.summary, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                    // Key Takeaways list
                    _buildSectionHeader('🎯 Core Takeaways', 'Practical rules to deploy'),
                    const SizedBox(height: 12),
                    ...data.takeaways.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(t, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    // Important Quotes
                    _buildSectionHeader('✍️ Key Quotation', 'Wisdom vectors'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.quotes.map((q) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(q, style: GoogleFonts.inter(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.gold)),
                            )).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Interactive Flashcard Swipe
                    _buildSectionHeader('🃏 Dynamic Flashcards', 'Test knowledge retention'),
                    const SizedBox(height: 12),
                    _buildFlashcardCell(data.flashcards),
                    const SizedBox(height: 24),
                    // Reflection Questions & Exercises
                    _buildSectionHeader('✏️ Reflection & Practice', 'Practical application'),
                    const SizedBox(height: 12),
                    ...data.reflectionQuestions.map((q) => _buildBulletRow(q, icon: '❓')),
                    const SizedBox(height: 8),
                    ...data.exercises.map((ex) => _buildBulletRow(ex, icon: '🛠️')),
                    const SizedBox(height: 24),
                    // Recommendations
                    _buildSectionHeader('📖 Recommended Missions', 'Expand your vector search'),
                    const SizedBox(height: 12),
                    ...data.relatedBooks.map((b) => _buildBulletRow(b, icon: '➕')),
                    const SizedBox(height: 36),
                    // Launch quiz mastery button
                    AnimatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startQuizFlow(context, data);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.quiz_rounded, color: AppColors.darkBg),
                          const SizedBox(width: 8),
                          Text('Test Chapter Mastery (+500 XP)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark, height: 1.5)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBulletRow(String text, {required String icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark))),
        ],
      ),
    );
  }

  Widget _buildFlashcardCell(List<Map<String, String>> fcList) {
    if (fcList.isEmpty) return const SizedBox.shrink();
    final card = fcList[_flashCardIndex];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _showFCAnswer = !_showFCAnswer);
      },
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _showFCAnswer ? AppColors.gold : AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Text(
              _showFCAnswer ? 'Answer' : 'Question',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _showFCAnswer ? AppColors.gold : AppColors.textTertiaryDark),
            ),
            const Spacer(),
            Text(
              _showFCAnswer ? card['back']! : card['front']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _flashCardIndex = (_flashCardIndex - 1 + fcList.length) % fcList.length;
                      _showFCAnswer = false;
                    });
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: AppColors.textSecondaryDark),
                ),
                Text('${_flashCardIndex + 1} / ${fcList.length}', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textTertiaryDark)),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _flashCardIndex = (_flashCardIndex + 1) % fcList.length;
                      _showFCAnswer = false;
                    });
                  },
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startQuizFlow(BuildContext context, ChapterTutorData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MasteryQuizSheet(book: widget.book, chapterIndex: widget.chapterIndex, data: data),
    );
  }
}

// ── Mastery Quiz Sheet ──────────────────────────────────────────────────────

class _MasteryQuizSheet extends ConsumerStatefulWidget {
  const _MasteryQuizSheet({required this.book, required this.chapterIndex, required this.data});
  final Book book;
  final int chapterIndex;
  final ChapterTutorData data;

  @override
  ConsumerState<_MasteryQuizSheet> createState() => _MasteryQuizSheetState();
}

class _MasteryQuizSheetState extends ConsumerState<_MasteryQuizSheet> {
  int _currentStep = 0; // 0-4: MCQs, 5: Scenario Questions, 6: Practical Task, 7: Final Score
  int _correctMcqCount = 0;
  int? _selectedMcqIndex;
  final _scenarioController = TextEditingController();

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: mq.size.height * 0.78,
        decoration: BoxDecoration(
          color: AppColors.darkBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top pull handle
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            // Header stats
            Row(
              children: [
                Text('Learning Check', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
                const Spacer(),
                Text('Step ${_currentStep + 1} / 8', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryDark)),
              ],
            ),
            const SizedBox(height: 12),
            // Step Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 4, color: AppColors.darkCard),
                  FractionallySizedBox(
                    widthFactor: (_currentStep + 1) / 8.0,
                    child: Container(height: 4, decoration: const BoxDecoration(gradient: AppColors.goldGradient)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Active Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildActiveStepView(),
              ),
            ),
            const SizedBox(height: 20),
            // Next Button
            if (_currentStep < 7)
              AnimatedButton(
                onPressed: _advanceStep,
                child: Text(
                  _currentStep == 6 ? 'Submit Check' : 'Next Question',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                ),
              )
            else
              AnimatedButton(
                onPressed: () {
                  ref.read(aiLearningProvider.notifier).resetQuizState();
                  Navigator.pop(context);
                },
                child: Text('Close & Complete', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStepView() {
    if (_currentStep < 5) {
      // MCQ Step
      final mcq = widget.data.mcqs[_currentStep];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MCQ ${_currentStep + 1}',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            mcq.question,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 20),
          ...List.generate(mcq.options.length, (i) {
            final active = _selectedMcqIndex == i;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMcqIndex = i);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: active ? AppColors.gold.withValues(alpha: 0.1) : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: active ? AppColors.gold : AppColors.darkBorder, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: active ? AppColors.gold : AppColors.textTertiaryDark, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.gold : Colors.transparent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        mcq.options[i],
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    } else if (_currentStep == 5) {
      // Scenario Question
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scenario Challenge', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(
            'Case: Dave wants to start journaling daily. He places his notebook on his desk before sleeping and sets a prompt "After I make coffee, I will write 3 lines". Detail why this structure works.',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _scenarioController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkCard,
              hintText: 'Enter your logical solution explaining Cue, Craving, Response, Reward alignment...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiaryDark),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.darkBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.gold)),
            ),
          ),
        ],
      );
    } else if (_currentStep == 6) {
      // Practical Task
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Practical Execution Task', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(
            'Write down 1 core habit you want to implement this week and align it using implementation intentions: "I will [BEHAVIOR] at [TIME] in [LOCATION]."',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
            child: Row(
              children: [
                const Icon(Icons.assignment_turned_in_rounded, color: AppColors.gold, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Action Step Check', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                      Text('Confirm you mapped your habit system', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Final Score Step
      final tutorState = ref.watch(aiLearningProvider);
      final score = tutorState.lastScore;

      if (score == null) return const Center(child: CircularProgressIndicator(color: AppColors.gold));

      final poor = score.average < 3.5;

      return Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: poor ? AppColors.warning.withValues(alpha: 0.12) : AppColors.gold.withValues(alpha: 0.12)),
            child: Center(
              child: Icon(
                poor ? Icons.info_outline_rounded : Icons.offline_bolt_rounded,
                color: poor ? AppColors.warning : AppColors.gold,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            poor ? 'Revision Required' : 'Mastery Confirmed!',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            poor
                ? 'Your understanding scores were below threshold. Let\'s revisit.'
                : 'Excellent! You gained +500 XP and unlocked new skill metrics.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 28),
          // Scores grid
          _buildScoreBar('Understanding', score.understanding),
          _buildScoreBar('Memory Retention', score.memory),
          _buildScoreBar('Practical Application', score.application),
          _buildScoreBar('Speed Metrics', score.speed),
        ],
      );
    }
  }

  Widget _buildScoreBar(String label, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
              Text('${(val / 5.0 * 100).round()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 5, color: AppColors.darkCard),
                FractionallySizedBox(
                  widthFactor: val / 5.0,
                  child: Container(height: 5, decoration: const BoxDecoration(gradient: AppColors.goldGradient)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _advanceStep() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 5) {
      // Validate MCQ choice
      if (_selectedMcqIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an option to proceed.')));
        return;
      }
      final correct = widget.data.mcqs[_currentStep].correctIndex == _selectedMcqIndex;
      if (correct) _correctMcqCount++;

      setState(() {
        _currentStep++;
        _selectedMcqIndex = null;
      });
    } else if (_currentStep == 5) {
      if (_scenarioController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a brief explanation.')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 6) {
      // Complete learning check on state provider
      ref.read(aiLearningProvider.notifier).completeLearningCheck(
            widget.book.id,
            widget.chapterIndex,
            correctMcqCount: _correctMcqCount,
            scenarioPerfect: true,
            practicalChecked: true,
          );
      ref.read(xpProvider.notifier).addXp(500); // add XP reward
      setState(() => _currentStep++);
    }
  }
}
