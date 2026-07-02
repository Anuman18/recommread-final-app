import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

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

  factory QuestionFeedback.fromJson(Map<String, dynamic> j) {
    return QuestionFeedback(
      questionText: j['question_text'] ?? '',
      userAnswer: j['user_answer'] ?? '',
      communicationScore: j['communication_score'] ?? 80,
      technicalScore: j['technical_score'] ?? 80,
      confidenceScore: j['confidence_score'] ?? 80,
      problemSolvingScore: j['problem_solving_score'] ?? 80,
      overallRating: (j['overall_rating'] as num?)?.toDouble() ?? 8.0,
      feedbackText: j['feedback_text'] ?? '',
      improvementSuggestions: List<String>.from(j['improvement_suggestions'] ?? []),
    );
  }
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

  factory InterviewReport.fromJson(Map<String, dynamic> j) {
    return InterviewReport(
      id: j['id']?.toString() ?? '',
      typeName: j['type_name'] ?? '',
      overallScore: (j['overall_score'] as num?)?.toDouble() ?? 75.0,
      strengths: List<String>.from(j['strengths'] ?? []),
      weakAreas: List<String>.from(j['weak_areas'] ?? []),
      topicsToRevise: List<String>.from(j['topics_to_revise'] ?? []),
      recommendedProjects: List<String>.from(j['recommended_projects'] ?? []),
      recommendedCoding: List<String>.from(j['recommended_coding'] ?? []),
      xpGained: j['xp_gained'] ?? 500,
      coinsGained: j['coins_gained'] ?? 50,
    );
  }
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

  factory InterviewHistoryItem.fromJson(Map<String, dynamic> j) {
    return InterviewHistoryItem(
      id: j['id']?.toString() ?? '',
      typeName: j['type_name'] ?? '',
      date: j['date'] ?? '',
      score: (j['score'] as num?)?.toDouble() ?? 0.0,
      readinessGained: (j['readiness_gained'] as num?)?.toDouble() ?? 3.5,
    );
  }
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

class InterviewNotifier extends StateNotifier<InterviewState> {
  String? _currentRoundId;

  InterviewNotifier() : super(const InterviewState()) {
    loadInterviewDashboard();
  }

  Future<void> loadInterviewDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dash = await apiClient.get(ApiConstants.interviews);
      final dashMap = Map<String, dynamic>.from(dash as Map);

      final typesList = (dashMap['interview_types'] as List)
          .map((t) => InterviewType.fromJson(Map<String, dynamic>.from(t)))
          .toList();

      final histJson = await apiClient.get(ApiConstants.interviewsHistory);
      final historyList = (histJson as List)
          .map((h) => InterviewHistoryItem.fromJson(Map<String, dynamic>.from(h)))
          .toList();

      final achievementsJson = await apiClient.get(ApiConstants.gamificationAchievements);
      final achievements = (achievementsJson as List)
          .map((a) {
            final map = Map<String, dynamic>.from(a);
            return InterviewAchievement(
              id: map['slug']?.toString() ?? '',
              title: map['title']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
              icon: map['icon']?.toString() ?? '🏆',
              isUnlocked: true,
            );
          })
          .toList();

      state = state.copyWith(
        readinessScore: (dashMap['readiness_score'] as num?)?.toDouble() ?? 0,
        currentScore: (dashMap['current_score'] as num?)?.toDouble() ?? 0,
        completedInterviews: (dashMap['completed_interviews'] as num?)?.toInt() ?? 0,
        weakSkills: List<String>.from(dashMap['weak_skills'] ?? []),
        strongSkills: List<String>.from(dashMap['strong_skills'] ?? []),
        interviewTypes: typesList,
        history: historyList,
        achievements: achievements,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load interview dashboard.');
    }
  }

  Future<void> refresh() async {
    await loadInterviewDashboard();
  }

  Future<void> startInterview(InterviewType type) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final startResp = await apiClient.post(
        ApiConstants.interviewsStart,
        body: {'type_id': type.id},
      );
      _currentRoundId = startResp['round_id']?.toString();
      final qList = (startResp['questions'] as List)
          .map((q) => InterviewQuestion.fromJson(Map<String, dynamic>.from(q)))
          .toList();

      state = state.copyWith(
        activeType: type,
        activeQuestions: qList,
        currentQuestionIndex: 0,
        userAnswers: [],
        feedbacks: [],
        latestReport: null,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> submitAnswer(String answer) async {
    final answers = List<String>.from(state.userAnswers)..add(answer);
    final currentQuestion = state.activeQuestions[state.currentQuestionIndex];

    try {
      final feedbackResp = await apiClient.post(
        ApiConstants.interviewsSubmitAnswer,
        body: {
          'round_id': _currentRoundId,
          'question_id': currentQuestion.id,
          'answer': answer,
        },
      );
      final qFeedback = QuestionFeedback.fromJson(Map<String, dynamic>.from(feedbackResp));
      final currentFeedbacks = List<QuestionFeedback>.from(state.feedbacks)..add(qFeedback);

      state = state.copyWith(
        userAnswers: answers,
        feedbacks: currentFeedbacks,
      );
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  void moveToNextQuestion() {
    if (state.currentQuestionIndex + 1 < state.activeQuestions.length) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    } else {
      _generateFinalReport();
    }
  }

  Future<void> _generateFinalReport() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final reportResp = await apiClient.post(
        ApiConstants.interviewsReport,
        body: {'round_id': _currentRoundId},
      );
      final report = InterviewReport.fromJson(Map<String, dynamic>.from(reportResp));

      state = state.copyWith(
        latestReport: report,
        completedInterviews: state.completedInterviews + 1,
        isLoading: false,
      );
      await refresh();
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }
}

final interviewProvider = StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  return InterviewNotifier();
});
