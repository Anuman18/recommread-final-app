import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';
import '../profile/profile_provider.dart';
import '../profile/xp_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class CodingTopic {
  final String id;
  final String name;
  final int completedQuestions;
  final int totalQuestions;
  final int xpEarned;
  final Map<String, int> difficultyDistribution; // e.g. {'Easy': 4, 'Medium': 2, 'Hard': 1}

  const CodingTopic({
    required this.id,
    required this.name,
    this.completedQuestions = 0,
    required this.totalQuestions,
    this.xpEarned = 0,
    required this.difficultyDistribution,
  });

  double get progress => totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;

  CodingTopic copyWith({
    int? completedQuestions,
    int? xpEarned,
  }) {
    return CodingTopic(
      id: id,
      name: name,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      totalQuestions: totalQuestions,
      xpEarned: xpEarned ?? this.xpEarned,
      difficultyDistribution: difficultyDistribution,
    );
  }

  factory CodingTopic.fromJson(Map<String, dynamic> j) {
    return CodingTopic(
      id: j['id']?.toString() ?? '',
      name: j['name'] ?? '',
      completedQuestions: j['completed_questions'] ?? 0,
      totalQuestions: j['total_questions'] ?? 0,
      xpEarned: j['xp_earned'] ?? 0,
      difficultyDistribution: Map<String, int>.from(j['difficulty_distribution'] ?? {}),
    );
  }
}

class QuestionExample {
  final String input;
  final String output;
  final String? explanation;

  const QuestionExample({required this.input, required this.output, this.explanation});

  factory QuestionExample.fromJson(Map<String, dynamic> j) {
    return QuestionExample(
      input: j['input'] ?? '',
      output: j['output'] ?? '',
      explanation: j['explanation'],
    );
  }
}

class CodingQuestion {
  final String id;
  final String title;
  final String difficulty; // Easy, Medium, Hard
  final String topicId;
  final List<String> companies;
  final int timeMin;
  final int xpReward;
  final int coinsReward;
  final List<String> hints;
  final String status; // unsolved, in_progress, solved
  final String problemStatement;
  final List<QuestionExample> examples;
  final List<String> constraints;
  final String expectedOutput;
  final String editorial;
  final String docUrl;
  final String videoUrl;

  const CodingQuestion({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.topicId,
    required this.companies,
    required this.timeMin,
    required this.xpReward,
    required this.coinsReward,
    required this.hints,
    this.status = 'unsolved',
    required this.problemStatement,
    required this.examples,
    required this.constraints,
    required this.expectedOutput,
    required this.editorial,
    required this.docUrl,
    required this.videoUrl,
  });

  CodingQuestion copyWith({
    String? status,
  }) {
    return CodingQuestion(
      id: id,
      title: title,
      difficulty: difficulty,
      topicId: topicId,
      companies: companies,
      timeMin: timeMin,
      xpReward: xpReward,
      coinsReward: coinsReward,
      hints: hints,
      status: status ?? this.status,
      problemStatement: problemStatement,
      examples: examples,
      constraints: constraints,
      expectedOutput: expectedOutput,
      editorial: editorial,
      docUrl: docUrl,
      videoUrl: videoUrl,
    );
  }

  factory CodingQuestion.fromJson(Map<String, dynamic> j) {
    return CodingQuestion(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      difficulty: j['difficulty'] ?? 'Easy',
      topicId: j['topic_id'] ?? '',
      companies: List<String>.from(j['companies'] ?? []),
      timeMin: j['time_min'] ?? 15,
      xpReward: j['xp_reward'] ?? 100,
      coinsReward: j['coins_reward'] ?? 10,
      hints: List<String>.from(j['hints'] ?? []),
      status: j['status'] ?? 'unsolved',
      problemStatement: j['problem_statement'] ?? '',
      examples: (j['examples'] as List? ?? [])
          .map((e) => QuestionExample.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      constraints: List<String>.from(j['constraints'] ?? []),
      expectedOutput: j['expected_output'] ?? '',
      editorial: j['editorial'] ?? '',
      docUrl: j['doc_url'] ?? '',
      videoUrl: j['video_url'] ?? '',
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final String avatar;
  final bool isMe;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        name: j['name'] ?? '',
        xp: (j['xp'] as num?)?.toInt() ?? 0,
        avatar: j['avatar'] ?? '⚡',
        isMe: j['is_me'] ?? false,
      );
}

class CodingAchievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
  final String icon;

  const CodingAchievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    required this.icon,
  });

  CodingAchievement copyWith({bool? isUnlocked}) {
    return CodingAchievement(
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

class CodingPracticeState {
  final int streak;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final int solvedCount;
  final int weeklyGoalSolved; // e.g. 5
  final int weeklyGoalTotal; // e.g. 10
  final CodingQuestion? dailyChallenge;
  
  final List<CodingTopic> topics;
  final List<CodingQuestion> questions;
  final List<LeaderboardEntry> weeklyLeaderboard;
  final List<LeaderboardEntry> monthlyLeaderboard;
  final List<LeaderboardEntry> friendsLeaderboard;
  final List<CodingAchievement> achievements;
  
  final bool isLoading;
  final String? errorMessage;

  const CodingPracticeState({
    this.streak = 3,
    this.totalXpEarned = 1450,
    this.totalCoinsEarned = 120,
    this.solvedCount = 14,
    this.weeklyGoalSolved = 4,
    this.weeklyGoalTotal = 10,
    this.dailyChallenge,
    this.topics = const [],
    this.questions = const [],
    this.weeklyLeaderboard = const [],
    this.monthlyLeaderboard = const [],
    this.friendsLeaderboard = const [],
    this.achievements = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  CodingPracticeState copyWith({
    int? streak,
    int? totalXpEarned,
    int? totalCoinsEarned,
    int? solvedCount,
    int? weeklyGoalSolved,
    CodingQuestion? dailyChallenge,
    List<CodingTopic>? topics,
    List<CodingQuestion>? questions,
    List<LeaderboardEntry>? weeklyLeaderboard,
    List<LeaderboardEntry>? monthlyLeaderboard,
    List<LeaderboardEntry>? friendsLeaderboard,
    List<CodingAchievement>? achievements,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CodingPracticeState(
      streak: streak ?? this.streak,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      solvedCount: solvedCount ?? this.solvedCount,
      weeklyGoalSolved: weeklyGoalSolved ?? this.weeklyGoalSolved,
      weeklyGoalTotal: weeklyGoalTotal,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      topics: topics ?? this.topics,
      questions: questions ?? this.questions,
      weeklyLeaderboard: weeklyLeaderboard ?? this.weeklyLeaderboard,
      monthlyLeaderboard: monthlyLeaderboard ?? this.monthlyLeaderboard,
      friendsLeaderboard: friendsLeaderboard ?? this.friendsLeaderboard,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CODING PRACTICE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class CodingPracticeNotifier extends StateNotifier<CodingPracticeState> {
  final Ref _ref;

  CodingPracticeNotifier(this._ref) : super(const CodingPracticeState()) {
    loadPracticeData();
  }

  Future<List<CodingQuestion>> _fetchAllQuestions(List<CodingTopic> topics) async {
    final allQuestions = <CodingQuestion>[];
    for (final topic in topics) {
      final questionsJson = await apiClient.get(
        '${ApiConstants.codingQuestions}?topic_id=${topic.id}',
      );
      allQuestions.addAll(
        (questionsJson as List)
            .map((q) => CodingQuestion.fromJson(Map<String, dynamic>.from(q))),
      );
    }
    return allQuestions;
  }

  List<CodingTopic> _hydrateTopics(List<CodingTopic> topics, List<CodingQuestion> questions) {
    return topics.map((topic) {
      final topicQuestions = questions.where((q) => q.topicId == topic.id).toList();
      final solved = topicQuestions.where((q) => q.status == 'solved').length;
      return topic.copyWith(
        completedQuestions: solved,
        xpEarned: topicQuestions
            .where((q) => q.status == 'solved')
            .fold<int>(0, (sum, q) => sum + q.xpReward),
      );
    }).toList();
  }

  List<CodingAchievement> _mapAchievements(List<dynamic> raw) {
    return raw
        .map((a) {
          final map = Map<String, dynamic>.from(a);
          return CodingAchievement(
            id: map['slug']?.toString() ?? map['achievement_slug']?.toString() ?? '',
            title: map['title']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            icon: map['icon']?.toString() ?? '🏆',
            isUnlocked: true,
          );
        })
        .toList();
  }

  Future<void> loadPracticeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final careerSlug = readingGoalToSlug(_ref.read(profileProvider).readingGoal);

    try {
      final topicsJson = await apiClient.get('${ApiConstants.codingTopics}?career=$careerSlug');
      final fetchedTopics = (topicsJson as List)
          .map((t) => CodingTopic.fromJson(Map<String, dynamic>.from(t)))
          .toList();

      final fetchedQuestions = fetchedTopics.isEmpty ? <CodingQuestion>[] : await _fetchAllQuestions(fetchedTopics);
      final hydratedTopics = _hydrateTopics(fetchedTopics, fetchedQuestions);

      CodingQuestion? dailyChallenge;
      try {
        final dailyJson = await apiClient.get(ApiConstants.codingDailyChallenge);
        dailyChallenge = CodingQuestion.fromJson(Map<String, dynamic>.from(dailyJson));
      } catch (_) {}

      final weeklyJson = await apiClient.get(ApiConstants.leaderboardWeekly);
      final monthlyJson = await apiClient.get(ApiConstants.leaderboardMonthly);
      final friendsJson = await apiClient.get(ApiConstants.leaderboardFriends);

      final streakJson = await apiClient.get(ApiConstants.gamificationStreak);
      final xpJson = await apiClient.get(ApiConstants.gamificationXp);
      final coinsJson = await apiClient.get(ApiConstants.gamificationCoins);
      final achievementsJson = await apiClient.get(ApiConstants.gamificationAchievements);

      final solvedCount = fetchedQuestions.where((q) => q.status == 'solved').length;

      state = state.copyWith(
        streak: (streakJson['daily_streak'] as num?)?.toInt() ?? 0,
        totalXpEarned: (xpJson['total_xp'] as num?)?.toInt() ?? 0,
        totalCoinsEarned: (coinsJson['total_coins'] as num?)?.toInt() ?? 0,
        solvedCount: solvedCount,
        weeklyGoalSolved: solvedCount,
        dailyChallenge: dailyChallenge ?? (fetchedQuestions.isEmpty ? null : fetchedQuestions.first),
        topics: hydratedTopics,
        questions: fetchedQuestions,
        weeklyLeaderboard: (weeklyJson as List)
            .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        monthlyLeaderboard: (monthlyJson as List)
            .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        friendsLeaderboard: (friendsJson as List)
            .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        achievements: _mapAchievements(achievementsJson as List),
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load coding practice data.');
    }
  }

  Future<void> submitSolution(String questionId, String userCode) async {
    final result = await apiClient.post(
      '${ApiConstants.codingQuestions}/$questionId/submit',
      body: {'user_code': userCode},
    );

    final xpEarned = (result['xp_earned'] as num?)?.toInt() ?? 0;
    if (xpEarned > 0) {
      await _ref.read(xpProvider.notifier).refreshFromBackend();
    }
    await loadPracticeData();
  }

  Future<void> completeDailyChallenge() async {
    if (state.dailyChallenge == null) return;

    final result = await apiClient.post(ApiConstants.codingDailyComplete);
    final bonusXp = (result['bonus_xp'] as num?)?.toInt() ?? 0;
    if (bonusXp > 0) {
      await _ref.read(xpProvider.notifier).refreshFromBackend();
    }
    await loadPracticeData();
  }

  Future<void> updateStreak() async {
    await loadPracticeData();
  }

  Future<void> refresh() async {
    await loadPracticeData();
  }
}

final codingPracticeProvider = StateNotifierProvider<CodingPracticeNotifier, CodingPracticeState>((ref) {
  return CodingPracticeNotifier(ref);
});

CodingQuestion? findQuestionById(String id, List<CodingQuestion> questions) {
  try {
    return questions.firstWhere((q) => q.id == id);
  } catch (_) {
    return null;
  }
}
