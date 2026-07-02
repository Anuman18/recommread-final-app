import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'interview_provider.dart';

class ActiveInterviewScreen extends ConsumerStatefulWidget {
  const ActiveInterviewScreen({super.key, required this.type});
  final InterviewType type;

  @override
  ConsumerState<ActiveInterviewScreen> createState() => _ActiveInterviewScreenState();
}

class _ActiveInterviewScreenState extends ConsumerState<ActiveInterviewScreen> {
  final TextEditingController _ansCtrl = TextEditingController();
  
  // Timers
  Timer? _questionTimer;
  int _timeRemainingSeconds = 60; // 60s question limit
  bool _introState = true;
  bool _feedbackState = false;
  bool _isRecordingVoice = false;
  bool _isRecordingVideo = false;

  @override
  void initState() {
    super.initState();
    _startIntro();
  }

  @override
  void dispose() {
    _stopTimer();
    _ansCtrl.dispose();
    super.dispose();
  }

  void _startIntro() {
    setState(() {
      _introState = true;
      _feedbackState = false;
    });
  }

  void _startQuestionLoop() {
    setState(() {
      _introState = false;
      _feedbackState = false;
      _ansCtrl.clear();
      _timeRemainingSeconds = 60;
    });
    _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        if (_timeRemainingSeconds > 0) {
          setState(() {
            _timeRemainingSeconds--;
          });
        } else {
          // Time expired -> auto submit empty/part answer
          _stopTimer();
          _submitCurrentAnswer();
        }
      }
    });
  }

  void _stopTimer() {
    _questionTimer?.cancel();
  }

  void _submitCurrentAnswer() {
    _stopTimer();
    final ansText = _ansCtrl.text.trim().isEmpty ? '[No written response provided]' : _ansCtrl.text;
    ref.read(interviewProvider.notifier).submitAnswer(ansText);
    setState(() {
      _feedbackState = true;
    });
  }

  void _triggerNextStep() {
    final state = ref.read(interviewProvider);
    if (state.currentQuestionIndex + 1 < state.activeQuestions.length) {
      ref.read(interviewProvider.notifier).moveToNextQuestion();
      _startQuestionLoop();
    } else {
      // Completed last question -> generate report and navigate
      ref.read(interviewProvider.notifier).moveToNextQuestion(); // generates latestReport
      context.pushReplacement('/ai-interview/report');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);

    if (state.activeQuestions.isEmpty) {
      return const Scaffold(backgroundColor: AppColors.darkBg, body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    }

    final currentQuestion = state.activeQuestions[state.currentQuestionIndex.clamp(0, state.activeQuestions.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator
              _buildAppBar(state),

              // Dynamic content box
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _introState
                        ? _buildIntroView()
                        : _feedbackState
                            ? _buildFeedbackView(state)
                            : _buildQuestionInputView(currentQuestion),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header indicator ───────────────────────────────────────────────────────

  Widget _buildAppBar(InterviewState s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.type.name,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
          ),
          if (!_introState)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.darkBorder)),
              child: Text(
                'Question ${s.currentQuestionIndex + 1} / ${s.activeQuestions.length}',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }

  // ── Step 0: Introduction ───────────────────────────────────────────────────

  Widget _buildIntroView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('🎤', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 24),
        Text(
          'Simulated Interview Ready',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Your AI Interview Mentor will prompt you with ${widget.type.questionCount} dynamic questions. You can choose to type your responses, or enable voice/video capture mocks to simulate live assessment conditions.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.55),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Metas List
        _metaIntroRow(Icons.timer_outlined, 'Question Timer limits response to 60 seconds.'),
        const SizedBox(height: 12),
        _metaIntroRow(Icons.feedback_outlined, 'AI assesses speech structure, tech terms, and accuracy.'),
        const SizedBox(height: 40),

        // Start trigger
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _startQuestionLoop();
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 16)]),
            child: Center(
              child: Text('Begin Simulation', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.darkBg)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaIntroRow(IconData icon, String desc) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
        ),
      ],
    );
  }

  // ── Step 1: Question Input View ────────────────────────────────────────────

  Widget _buildQuestionInputView(InterviewQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // Timer Circle
        Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _timeRemainingSeconds < 15 ? AppColors.error : AppColors.gold, width: 2)),
            child: Center(
              child: Text(
                '${_timeRemainingSeconds}s',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: _timeRemainingSeconds < 15 ? AppColors.error : AppColors.gold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Question Statement
        Text('QUESTION:', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.0)),
        const SizedBox(height: 6),
        Text(
          q.text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark, height: 1.35),
        ),
        const SizedBox(height: 24),

        // Input Mode Toggles (Text, Voice, Video)
        Row(
          children: [
            _inputModeButton(Icons.text_fields_rounded, 'TEXT INPUT', !_isRecordingVoice && !_isRecordingVideo, () {
              setState(() {
                _isRecordingVoice = false;
                _isRecordingVideo = false;
              });
            }),
            const SizedBox(width: 8),
            _inputModeButton(Icons.mic_rounded, 'MOCK VOICE', _isRecordingVoice, () {
              HapticFeedback.selectionClick();
              setState(() {
                _isRecordingVoice = !_isRecordingVoice;
                _isRecordingVideo = false;
              });
            }),
            const SizedBox(width: 8),
            _inputModeButton(Icons.videocam_rounded, 'MOCK VIDEO', _isRecordingVideo, () {
              HapticFeedback.selectionClick();
              setState(() {
                _isRecordingVideo = !_isRecordingVideo;
                _isRecordingVoice = false;
              });
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Mock state banners
        if (_isRecordingVoice)
          _mockCaptureBanner('🎙️ Capturing vocal stream... (mocking audio buffer)'),
        if (_isRecordingVideo)
          _mockCaptureBanner('📹 Capturing camera feeds... (mocking video canvas)'),

        // Text Answer box
        if (!_isRecordingVoice && !_isRecordingVideo)
          Container(
            height: 140,
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: _ansCtrl,
              maxLines: null,
              style: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: GoogleFonts.inter(color: AppColors.textTertiaryDark, fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        const SizedBox(height: 32),

        // Submit answer trigger
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _submitCurrentAnswer();
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text('Submit Response', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputModeButton(IconData icon, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: active ? AppColors.gold.withValues(alpha: 0.1) : AppColors.darkCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.gold : AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? AppColors.gold : AppColors.textTertiaryDark, size: 14),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: active ? AppColors.gold : AppColors.textTertiaryDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mockCaptureBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.22))),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF2196F3), fontWeight: FontWeight.w600)),
    );
  }

  // ── Step 2: AI Feedback View ───────────────────────────────────────────────

  Widget _buildFeedbackView(InterviewState s) {
    if (s.feedbacks.isEmpty) return const SizedBox();
    final f = s.feedbacks.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'AI Real-Time Feedback',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Rating bars (vocal, technical, confidence, problem solving)
        _feedbackMeter('Communication Score', f.communicationScore),
        _feedbackMeter('Technical Vocabulary', f.technicalScore),
        _feedbackMeter('Vocal Confidence', f.confidenceScore),
        _feedbackMeter('Problem Solving Structure', f.problemSolvingScore),
        const SizedBox(height: 24),

        // Comments Overview
        Text('MENTOR OBSERVATIONS:', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Text(f.feedbackText, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.5)),
        const SizedBox(height: 24),

        // Suggested Improvements
        Text('KEY SUGGESTIONS:', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        ...f.improvementSuggestions.map((sug) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(sug, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryDark)),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 40),

        // Next Trigger
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _triggerNextStep();
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                s.currentQuestionIndex + 1 < s.activeQuestions.length ? 'Next Question' : 'Complete Interview & View Report',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.darkBg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedbackMeter(String label, int val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600)),
              Text('$val%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: AppColors.darkElevated),
                FractionallySizedBox(
                  widthFactor: val / 100.0,
                  child: Container(height: 6, decoration: const BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.all(Radius.circular(4)))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
