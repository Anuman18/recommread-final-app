import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../profile/profile_provider.dart';
import '../profile/xp_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class InterviewType {
  final String id;
  final String name; // Technical, Behavioral, HR, System Design, Case Study, Rapid Fire, Coding, Mock Viva
  final String description;
  final String icon;
  final int questionCount;
  final int durationMin;

  const InterviewType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.questionCount,
    required this.durationMin,
  });

  factory InterviewType.fromJson(Map<String, dynamic> j) {
    return InterviewType(
      id: j['id']?.toString() ?? '',
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      icon: j['icon'] ?? '🎤',
      questionCount: j['question_count'] ?? 5,
      durationMin: j['duration_min'] ?? 15,
    );
  }
}

class InterviewQuestion {
  final String id;
  final String text;
  final String difficulty;
  final String topic;

  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.difficulty,
    required this.topic,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> j) {
    return InterviewQuestion(
      id: j['id']?.toString() ?? '',
      text: j['text'] ?? '',
      difficulty: j['difficulty'] ?? 'Medium',
      topic: j['topic'] ?? 'General',
    );
  }
}

class QuestionFeedback {
  final String questionText;
  final String userAnswer;
  final int communicationScore;
  final int technicalScore;
  final int confidenceScore;
  final int problemSolvingScore;
  final double overallRating; // 0.0 to 10.0
  final String feedbackText;
  final List<String> improvementSuggestions;

  const QuestionFeedback({
    required this.questionText,
    required this.userAnswer,
    required this.communicationScore,
    required this.technicalScore,
    required this.confidenceScore,
    required this.problemSolvingScore,
    required this.overallRating,
    required this.feedbackText,
    required this.improvementSuggestions,
  });
}

class InterviewReport {
  final String id;
  final String typeName;
  final double overallScore; // e.g. 84.5
  final List<String> strengths;
  final List<String> weakAreas;
  final List<String> topicsToRevise;
  final List<String> recommendedProjects;
  final List<String> recommendedCoding;
  final int xpGained;
  final int coinsGained;

  const InterviewReport({
    required this.id,
    required this.typeName,
    required this.overallScore,
    required this.strengths,
    required this.weakAreas,
    required this.topicsToRevise,
    required this.recommendedProjects,
    required this.recommendedCoding,
    required this.xpGained,
    required this.coinsGained,
  });
}

class InterviewHistoryItem {
  final String id;
  final String typeName;
  final String date;
  final double score;
  final double readinessGained;

  const InterviewHistoryItem({
    required this.id,
    required this.typeName,
    required this.date,
    required this.score,
    required this.readinessGained,
  });
}

class InterviewAchievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
  final String icon;

  const InterviewAchievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    required this.icon,
  });

  InterviewAchievement copyWith({bool? isUnlocked}) {
    return InterviewAchievement(
      id: id,
      title: title,
      description: description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      icon: icon,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────────────────────

class InterviewState {
  final double readinessScore; // 0.0 to 100.0
  final double currentScore; // 0.0 to 100.0
  final int completedInterviews;
  final List<String> weakSkills;
  final List<String> strongSkills;
  
  final List<InterviewType> interviewTypes;
  final List<InterviewHistoryItem> history;
  final List<InterviewAchievement> achievements;
  
  // Active Interview state
  final InterviewType? activeType;
  final List<InterviewQuestion> activeQuestions;
  final int currentQuestionIndex;
  final List<String> userAnswers;
  final List<QuestionFeedback> feedbacks;
  final InterviewReport? latestReport;
  
  final bool isLoading;
  final String? errorMessage;

  const InterviewState({
    this.readinessScore = 45.0,
    this.currentScore = 74.0,
    this.completedInterviews = 3,
    this.weakSkills = const ['System Design scalability', 'Quantization metrics'],
    this.strongSkills = const ['Python OOP', 'Heuristic analysis'],
    this.interviewTypes = const [],
    this.history = const [],
    this.achievements = const [],
    this.activeType,
    this.activeQuestions = const [],
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.feedbacks = const [],
    this.latestReport,
    this.isLoading = true,
    this.errorMessage,
  });

  InterviewState copyWith({
    double? readinessScore,
    double? currentScore,
    int? completedInterviews,
    List<String>? weakSkills,
    List<String>? strongSkills,
    List<InterviewType>? interviewTypes,
    List<InterviewHistoryItem>? history,
    List<InterviewAchievement>? achievements,
    InterviewType? activeType,
    List<InterviewQuestion>? activeQuestions,
    int? currentQuestionIndex,
    List<String>? userAnswers,
    List<QuestionFeedback>? feedbacks,
    InterviewReport? latestReport,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InterviewState(
      readinessScore: readinessScore ?? this.readinessScore,
      currentScore: currentScore ?? this.currentScore,
      completedInterviews: completedInterviews ?? this.completedInterviews,
      weakSkills: weakSkills ?? this.weakSkills,
      strongSkills: strongSkills ?? this.strongSkills,
      interviewTypes: interviewTypes ?? this.interviewTypes,
      history: history ?? this.history,
      achievements: achievements ?? this.achievements,
      activeType: activeType ?? this.activeType,
      activeQuestions: activeQuestions ?? this.activeQuestions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      feedbacks: feedbacks ?? this.feedbacks,
      latestReport: latestReport ?? this.latestReport,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK QUESTIONS & INTERVIEWS BY CAREER
// ─────────────────────────────────────────────────────────────────────────────

final List<InterviewType> _defaultInterviewTypes = [
  const InterviewType(id: 'int_tech', name: 'Technical Interview', description: 'Deep-dive into language constraints, model scaling, and optimization.', icon: '💻', questionCount: 3, durationMin: 15),
  const InterviewType(id: 'int_beh', name: 'Behavioral Interview', description: 'Assess communication structure, developer conflict resolution, and leadership.', icon: '🤝', questionCount: 3, durationMin: 12),
  const InterviewType(id: 'int_hr', name: 'HR Interview', description: 'Standard salary review, corporate fitment checklists, and background logs.', icon: '🏢', questionCount: 2, durationMin: 10),
  const InterviewType(id: 'int_sys', name: 'System Design', description: 'Design rate limiters, scale caches, and partition vector databases.', icon: '📐', questionCount: 3, durationMin: 20),
  const InterviewType(id: 'int_case', name: 'Case Study', description: 'Analyze business conversion drops and audit interface user flows.', icon: '📊', questionCount: 2, durationMin: 18),
  const InterviewType(id: 'int_rapid', name: 'Rapid Fire', description: 'Quick-response technical trivia under strict timer constraints.', icon: '⚡', questionCount: 5, durationMin: 5),
  const InterviewType(id: 'int_code', name: 'Coding Interview', description: 'Live coding problem analysis, complexity audits, and test execution.', icon: '🧩', questionCount: 2, durationMin: 15),
  const InterviewType(id: 'int_viva', name: 'Mock Viva', description: 'Verbal theory defense covering model weights and activation math.', icon: '🎤', questionCount: 3, durationMin: 12),
];

final Map<String, List<InterviewQuestion>> _mockQuestionsByCareer = {
  'dataScientist': [
    const InterviewQuestion(id: 'q_ds_1', text: 'Explain the bias-variance tradeoff in machine learning, and how regularization helps.', difficulty: 'Medium', topic: 'ML Theory'),
    const InterviewQuestion(id: 'q_ds_2', text: 'What is customer churn, and how would you evaluate model performance if classes are highly imbalanced?', difficulty: 'Hard', topic: 'Metrics'),
    const InterviewQuestion(id: 'q_ds_3', text: 'How do you check for and handle multicollinearity in a multiple linear regression model?', difficulty: 'Medium', topic: 'Statistics'),
  ],
  'uxDesigner': [
    const InterviewQuestion(id: 'q_ux_1', text: 'How do you conduct user research for a fintech app, and how does it translate to high-fidelity wireframes?', difficulty: 'Medium', topic: 'UX Research'),
    const InterviewQuestion(id: 'q_ux_2', text: 'Explain Nielsen\'s Usability Heuristics and how you apply them when auditing cart checkout pages.', difficulty: 'Easy', topic: 'Heuristics'),
    const InterviewQuestion(id: 'q_ux_3', text: 'How do you resolve feedback conflicts when engineers state that a custom layout micro-interaction is too expensive to code?', difficulty: 'Hard', topic: 'Handoff'),
  ],
  'aiEngineer': [
    const InterviewQuestion(id: 'q_ai_1', text: 'Explain the self-attention matrix query, key, and value multipliers. Why is scale scaling required?', difficulty: 'Hard', topic: 'Transformers'),
    const InterviewQuestion(id: 'q_ai_2', text: 'What is parameter-efficient fine-tuning (LoRA), and how does it optimize training GPU memory bounds?', difficulty: 'Medium', topic: 'LLM Fine-Tuning'),
    const InterviewQuestion(id: 'q_ai_3', text: 'How would you architect a real-time multimodal RAG assistant handling both vector indexing and document structure citations?', difficulty: 'Hard', topic: 'System Design'),
  ],
};

final List<InterviewHistoryItem> _mockHistory = [
  const InterviewHistoryItem(id: 'hist_1', typeName: 'Rapid Fire', date: '2026-06-28', score: 68.0, readinessGained: 4.5),
  const InterviewHistoryItem(id: 'hist_2', typeName: 'HR Interview', date: '2026-06-29', score: 85.0, readinessGained: 6.0),
  const InterviewHistoryItem(id: 'hist_3', typeName: 'Technical Interview', date: '2026-07-01', score: 74.0, readinessGained: 8.0),
];

final List<InterviewAchievement> _defaultAchievements = [
  const InterviewAchievement(id: 'ach_int1', title: 'First Mock Interview', description: 'Complete your first dynamic AI Interview round.', icon: '🎤', isUnlocked: true),
  const InterviewAchievement(id: 'ach_int2', title: 'Consistency Champion', description: 'Complete 10 interview simulation rounds.', icon: '🛡️'),
  const InterviewAchievement(id: 'ach_int3', title: 'Perfect Score', description: 'Score above 95% in any technical or system design round.', icon: '🎯'),
  const InterviewAchievement(id: 'ach_int4', title: 'Interview Master', description: 'Achieve an overall readiness score above 85%.', icon: '🏆'),
];

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

class InterviewNotifier extends StateNotifier<InterviewState> {
  final Ref _ref;

  InterviewNotifier(this._ref) : super(const InterviewState()) {
    loadInterviewDashboard();
  }

  Future<void> loadInterviewDashboard() async {
    state = state.copyWith(isLoading: true);
    final career = _ref.read(profileProvider).readingGoal.name;

    try {
      final careerSlug = career.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      await apiClient.get('/interviews?career=$careerSlug');
    } catch (_) {
      // Fallback
      final prefs = await SharedPreferences.getInstance();
      
      final readiness = prefs.getDouble('int_readiness') ?? 45.0;
      final completed = prefs.getInt('int_completed') ?? 3;
      final avgScore = prefs.getDouble('int_avg_score') ?? 74.0;

      // Unlocks checks
      final achievements = _defaultAchievements.map((ach) {
        bool unlocked = ach.isUnlocked;
        if (ach.id == 'ach_int2' && completed >= 10) unlocked = true;
        if (ach.id == 'ach_int4' && readiness >= 85.0) unlocked = true;
        return ach.copyWith(isUnlocked: unlocked);
      }).toList();

      state = state.copyWith(
        readinessScore: readiness,
        currentScore: avgScore,
        completedInterviews: completed,
        interviewTypes: _defaultInterviewTypes,
        history: _mockHistory,
        achievements: achievements,
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadInterviewDashboard();
  }

  void startInterview(InterviewType type) {
    final career = _ref.read(profileProvider).readingGoal.name;
    final questions = _mockQuestionsByCareer[career] ?? _mockQuestionsByCareer['aiEngineer']!;

    state = state.copyWith(
      activeType: type,
      activeQuestions: questions.take(type.questionCount).toList(),
      currentQuestionIndex: 0,
      userAnswers: [],
      feedbacks: [],
      latestReport: null,
    );
  }

  void submitAnswer(String answer) {
    final answers = List<String>.from(state.userAnswers);
    answers.add(answer);

    final currentQuestion = state.activeQuestions[state.currentQuestionIndex];
    
    // Simulate AI Feedback generation for this question
    final comScore = Random().nextInt(15) + 80;
    final techScore = Random().nextInt(20) + 75;
    final confScore = Random().nextInt(15) + 82;
    final probScore = Random().nextInt(20) + 76;
    final overall = (comScore + techScore + confScore + probScore) / 40.0; // scale to 0-10

    final qFeedback = QuestionFeedback(
      questionText: currentQuestion.text,
      userAnswer: answer,
      communicationScore: comScore,
      technicalScore: techScore,
      confidenceScore: confScore,
      problemSolvingScore: probScore,
      overallRating: double.parse(overall.toStringAsFixed(1)),
      feedbackText: 'You gave a highly structured explanation regarding ${currentQuestion.topic}.\n\n'
          'To improve, verify you explicitly reference efficiency bounds (time & memory complexities) or design system spacing guidelines early in your pitch.',
      improvementSuggestions: const [
        'Reference specific complex constants.',
        'Use the STAR method for behavioral parts.',
        'Pause less during structural logic explanations.',
      ],
    );

    final currentFeedbacks = List<QuestionFeedback>.from(state.feedbacks);
    currentFeedbacks.add(qFeedback);

    state = state.copyWith(
      userAnswers: answers,
      feedbacks: currentFeedbacks,
    );
  }

  void moveToNextQuestion() {
    if (state.currentQuestionIndex + 1 < state.activeQuestions.length) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      _generateFinalReport();
    }
  }

  void _generateFinalReport() async {
    final prefs = await SharedPreferences.getInstance();
    final typeName = state.activeType?.name ?? 'Mock Interview';

    // Calculate overall average score
    final totalOverall = state.feedbacks.fold<double>(0, (sum, f) => sum + f.overallRating);
    final overallPercentage = (totalOverall / state.feedbacks.length) * 10.0;

    final report = InterviewReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      typeName: typeName,
      overallScore: double.parse(overallPercentage.toStringAsFixed(1)),
      strengths: const [
        'Clear layout structure & modularized logic concepts',
        'Strong vocal confidence, minimal speech fillers',
        'Solid architectural foundations & constraint limits matching',
      ],
      weakAreas: const [
        'Deep parameter configurations details validation',
        'Visual alignment details definitions description',
      ],
      topicsToRevise: const [
        'Bias-variance mathematics details',
        'Figma Auto layout nested constraints',
      ],
      recommendedProjects: const [
        'Multimodal RAG Knowledge Assistant',
      ],
      recommendedCoding: const [
        'Matrix Dot Product Multiplication',
      ],
      xpGained: 500,
      coinsGained: 50,
    );

    // Save records
    final nextCompleted = state.completedInterviews + 1;
    final nextReadiness = (state.readinessScore + 3.5).clamp(0.0, 100.0);
    final nextAvgScore = (state.currentScore * 0.7) + (overallPercentage * 0.3);

    await prefs.setInt('int_completed', nextCompleted);
    await prefs.setDouble('int_readiness', nextReadiness);
    await prefs.setDouble('int_avg_score', nextAvgScore);

    // Award rewards
    await _ref.read(xpProvider.notifier).addXp(500);
    final currentCoins = prefs.getInt('user_coins') ?? 100;
    await prefs.setInt('user_coins', currentCoins + 50);

    state = state.copyWith(
      readinessScore: double.parse(nextReadiness.toStringAsFixed(1)),
      currentScore: double.parse(nextAvgScore.toStringAsFixed(1)),
      completedInterviews: nextCompleted,
      latestReport: report,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD EXPORT
// ─────────────────────────────────────────────────────────────────────────────

final interviewProvider = StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  return InterviewNotifier(ref);
});
