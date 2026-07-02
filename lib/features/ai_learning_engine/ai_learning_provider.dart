import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Models ─────────────────────────────────────────────────────────────────

class MCQ {
  final String question;
  final List<String> options;
  final int correctIndex;
  const MCQ({required this.question, required this.options, required this.correctIndex});
}

class ScenarioQuestion {
  final String question;
  final String sampleSolution;
  const ScenarioQuestion({required this.question, required this.sampleSolution});
}

class ChapterTutorData {
  final String beginnerExplanation;
  final String advancedExplanation;
  final List<String> takeaways;
  final String summary;
  final List<String> quotes;
  final List<Map<String, String>> flashcards; // Front -> Back
  final List<MCQ> mcqs;
  final List<String> reflectionQuestions;
  final List<String> exercises;
  final List<String> relatedBooks;

  const ChapterTutorData({
    required this.beginnerExplanation,
    required this.advancedExplanation,
    required this.takeaways,
    required this.summary,
    required this.quotes,
    required this.flashcards,
    required this.mcqs,
    required this.reflectionQuestions,
    required this.exercises,
    required this.relatedBooks,
  });
}

class LearningScore {
  final double understanding;
  final double memory;
  final double application;
  final double consistency;
  final double speed;

  const LearningScore({
    required this.understanding,
    required this.memory,
    required this.application,
    required this.consistency,
    required this.speed,
  });

  double get average => (understanding + memory + application + consistency + speed) / 5.0;
}

class LearningAnalytics {
  final double retentionRate;
  final double quizAccuracy;
  final double avgLearningScore;
  final double revisionConsistency;
  final List<String> strongestTopics;
  final List<String> weakestTopics;
  final List<String> recommendedRevision;

  const LearningAnalytics({
    required this.retentionRate,
    required this.quizAccuracy,
    required this.avgLearningScore,
    required this.revisionConsistency,
    required this.strongestTopics,
    required this.weakestTopics,
    required this.recommendedRevision,
  });
}

// ── AI Learning Engine State ────────────────────────────────────────────────

class AiLearningState {
  final Map<String, ChapterTutorData> tutorCache; // BookId_ChIndex -> Data
  final String studyMode; // '10yo', 'Professor', 'Hinglish', 'Analogies', 'CaseStudies'
  final bool isGenerating;
  final LearningScore? lastScore;
  final LearningAnalytics analytics;
  final bool quizCompleted;

  const AiLearningState({
    this.tutorCache = const {},
    this.studyMode = '10yo',
    this.isGenerating = false,
    this.lastScore,
    this.analytics = const LearningAnalytics(
      retentionRate: 0.82,
      quizAccuracy: 0.78,
      avgLearningScore: 4.1,
      revisionConsistency: 0.9,
      strongestTopics: ['Atomic Habits', 'Marginal Gains', 'Time Blocks'],
      weakestTopics: ['Relational Schema', 'Financial Markets'],
      recommendedRevision: ['Review Atomic Habits Chapter 3 Quiz mistakes'],
    ),
    this.quizCompleted = false,
  });

  AiLearningState copyWith({
    Map<String, ChapterTutorData>? tutorCache,
    String? studyMode,
    bool? isGenerating,
    LearningScore? lastScore,
    LearningAnalytics? analytics,
    bool? quizCompleted,
  }) {
    return AiLearningState(
      tutorCache: tutorCache ?? this.tutorCache,
      studyMode: studyMode ?? this.studyMode,
      isGenerating: isGenerating ?? this.isGenerating,
      lastScore: lastScore ?? this.lastScore,
      analytics: analytics ?? this.analytics,
      quizCompleted: quizCompleted ?? this.quizCompleted,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────

class AiLearningNotifier extends StateNotifier<AiLearningState> {
  AiLearningNotifier() : super(const AiLearningState()) {
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final retention = prefs.getDouble('ai_retention_rate') ?? 0.82;
    final accuracy = prefs.getDouble('ai_quiz_accuracy') ?? 0.78;
    final avgScore = prefs.getDouble('ai_avg_learning_score') ?? 4.1;

    state = state.copyWith(
      analytics: LearningAnalytics(
        retentionRate: retention,
        quizAccuracy: accuracy,
        avgLearningScore: avgScore,
        revisionConsistency: 0.9,
        strongestTopics: ['Atomic Habits', 'Marginal Gains', 'Focus Time'],
        weakestTopics: ['Relational Databases', 'Asset Classes'],
        recommendedRevision: ['Review Atomic Habits Chapter 1 Scenario questions'],
      ),
    );
  }

  void changeStudyMode(String mode) {
    state = state.copyWith(studyMode: mode);
  }

  Future<void> completeLearningCheck(
    String bookId,
    int chapterIndex, {
    required int correctMcqCount,
    required bool scenarioPerfect,
    required bool practicalChecked,
  }) async {
    // Calculate custom score
    final double understanding = (correctMcqCount / 5.0) * 5.0;
    final double memory = scenarioPerfect ? 4.8 : 3.2;
    final double application = practicalChecked ? 5.0 : 2.5;
    const double consistency = 4.7;
    const double speed = 4.2;

    final score = LearningScore(
      understanding: understanding,
      memory: memory,
      application: application,
      consistency: consistency,
      speed: speed,
    );

    // Save persistence
    final prefs = await SharedPreferences.getInstance();
    final currentScoreCount = prefs.getInt('ai_score_count') ?? 0;
    final newCount = currentScoreCount + 1;
    await prefs.setInt('ai_score_count', newCount);

    final totalVal = (state.analytics.avgLearningScore * currentScoreCount) + score.average;
    final newAvg = double.parse((totalVal / newCount).toStringAsFixed(2));
    await prefs.setDouble('ai_avg_learning_score', newAvg);

    state = state.copyWith(
      lastScore: score,
      quizCompleted: true,
      analytics: LearningAnalytics(
        retentionRate: (state.analytics.retentionRate * 0.9 + (understanding / 5.0) * 0.1).clamp(0.0, 1.0),
        quizAccuracy: (state.analytics.quizAccuracy * 0.9 + (correctMcqCount / 5.0) * 0.1).clamp(0.0, 1.0),
        avgLearningScore: newAvg,
        revisionConsistency: 0.92,
        strongestTopics: state.analytics.strongestTopics,
        weakestTopics: state.analytics.weakestTopics,
        recommendedRevision: state.analytics.recommendedRevision,
      ),
    );
  }

  void resetQuizState() {
    state = state.copyWith(quizCompleted: false, lastScore: null);
  }

  ChapterTutorData generateTutorDataFor(String bookId, int chapterIndex, String mode) {
    final key = '${bookId}_${chapterIndex}_$mode';
    if (state.tutorCache.containsKey(key)) {
      return state.tutorCache[key]!;
    }

    // Dynamic Mock generation depending on mode chosen
    String beginner = '';
    String advanced = '';

    switch (mode) {
      case '10yo':
        beginner = 'Think of habits like building blocks. Doing one small 1% block every day builds a giant Lego castle over time!';
        advanced = 'Compounding behavior functions identically to exponential growth equations. Minor systemic iterations accumulate high utility yields.';
        break;
      case 'Professor':
        beginner = 'In pedagogical research, habit formulation centers around the habit loop structure: Cue, Craving, Response, Reward.';
        advanced = 'Neurological patterns dictate that automated synapses reinforce behavioral responses to persistent contextual triggers.';
        break;
      case 'Hinglish':
        beginner = 'Habits actually system changes hain. Agar daily sirf 1% improvement karoge, toh after one year you are 37 times better!';
        advanced = 'Identity transition state variable model validation dynamically confirms how daily micro-habits compound identity vectors.';
        break;
      case 'Analogies':
        beginner = 'Habits are like paths in a forest. The more you walk on them, the wider and easier they become to traverse automatically.';
        advanced = 'Synaptic pruning behaves like architectural optimization in networks, clearing less used pathways to stabilize preferred patterns.';
        break;
      case 'CaseStudies':
        beginner = 'British Cycling was failing for 110 years. Dave Brailsford introduced aggregation of marginal gains and they won 66 Olympic gold medals.';
        advanced = 'Underlying structural alignment in organizational operations highlights that marginal optimization shifts global equilibrium states.';
        break;
    }

    final data = ChapterTutorData(
      beginnerExplanation: beginner,
      advancedExplanation: advanced,
      takeaways: [
        'aggregation of marginal gains (1% daily improvements)',
        'Focus on systemic design instead of outcome benchmarks',
        'Tie habits dynamically to identity declarations',
      ],
      summary: 'This chapter highlights how minor structural shifts compound over time to shape global systems and self-realization.',
      quotes: [
        '"Success is the product of daily habits—not once-in-a-lifetime transformations."',
        '"You do not rise to the level of your goals. You fall to the level of your systems."',
      ],
      flashcards: [
        {'front': 'What is the Habit Loop?', 'back': 'Cue -> Craving -> Response -> Reward'},
        {'front': 'Aggregation of Marginal Gains', 'back': '1% improvements across all actions compounding to major positive adjustments'},
      ],
      mcqs: const [
        MCQ(question: 'What is Dave Brailsfords core methodology?', options: ['Radical shifts', 'Marginal gains aggregation', 'Outcome tracking', 'Incentive design'], correctIndex: 1),
        MCQ(question: 'According to Clear, you fall to the level of your...', options: ['Aspirations', 'Execution metrics', 'Systems', 'Incentives'], correctIndex: 2),
        MCQ(question: 'The Habit Loop consists of how many stages?', options: ['Two', 'Three', 'Four', 'Five'], correctIndex: 2),
        MCQ(question: 'Identity-based habits focus on...', options: ['What you want to achieve', 'Who you want to become', 'What you do daily', 'Your social network'], correctIndex: 1),
        MCQ(question: '1% daily improvement makes you how many times better in a year?', options: ['3 times', '10 times', '37 times', '100 times'], correctIndex: 2),
      ],
      reflectionQuestions: [
        'What current systems in your life are misaligned with your dream identity?',
        'How can you make a positive cue obvious in your daily workflow?',
      ],
      exercises: [
        'Map out your habits for tomorrow and flag them as positive, negative, or neutral.',
        'Choose a new habit you want to build and specify its exact cue: "I will [BEHAVIOR] at [TIME] in [LOCATION]."',
      ],
      relatedBooks: ['Deep Work by Cal Newport', 'The Power of Habit by Charles Duhigg'],
    );

    state = state.copyWith(
      tutorCache: {...state.tutorCache, key: data},
    );

    return data;
  }
}

final aiLearningProvider =
    StateNotifierProvider<AiLearningNotifier, AiLearningState>(
  (ref) => AiLearningNotifier(),
);
