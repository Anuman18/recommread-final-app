import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
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
// MOCK PRACTICE DATA (CAREER SPECIFIC FALLBACKS)
// ─────────────────────────────────────────────────────────────────────────────

final Map<String, List<CodingTopic>> _mockTopicsByCareer = {
  'dataScientist': [
    const CodingTopic(id: 'ds_python', name: 'Python Basics', totalQuestions: 6, difficultyDistribution: {'Easy': 4, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ds_numpy', name: 'NumPy Arrays', totalQuestions: 4, difficultyDistribution: {'Easy': 2, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ds_pandas', name: 'Pandas DataFrames', totalQuestions: 5, difficultyDistribution: {'Easy': 2, 'Medium': 2, 'Hard': 1}),
    const CodingTopic(id: 'ds_sql', name: 'SQL Queries', totalQuestions: 6, difficultyDistribution: {'Easy': 3, 'Medium': 2, 'Hard': 1}),
    const CodingTopic(id: 'ds_ml', name: 'Machine Learning', totalQuestions: 5, difficultyDistribution: {'Easy': 1, 'Medium': 3, 'Hard': 1}),
    const CodingTopic(id: 'ds_stats', name: 'Statistics & Math', totalQuestions: 4, difficultyDistribution: {'Easy': 2, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ds_viz', name: 'Data Visualization', totalQuestions: 3, difficultyDistribution: {'Easy': 2, 'Medium': 1, 'Hard': 0}),
  ],
  'uxDesigner': [
    const CodingTopic(id: 'ux_figma', name: 'Figma Dev Handoff', totalQuestions: 5, difficultyDistribution: {'Easy': 3, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ux_systems', name: 'Design Systems', totalQuestions: 4, difficultyDistribution: {'Easy': 2, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ux_html', name: 'HTML Structure', totalQuestions: 6, difficultyDistribution: {'Easy': 4, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ux_css', name: 'CSS Flex & Grid', totalQuestions: 6, difficultyDistribution: {'Easy': 3, 'Medium': 2, 'Hard': 1}),
  ],
  'aiEngineer': [
    const CodingTopic(id: 'ai_python', name: 'Python Algorithms', totalQuestions: 6, difficultyDistribution: {'Easy': 3, 'Medium': 2, 'Hard': 1}),
    const CodingTopic(id: 'ai_linear', name: 'Linear Algebra', totalQuestions: 4, difficultyDistribution: {'Easy': 2, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ai_pytorch', name: 'PyTorch Layers', totalQuestions: 5, difficultyDistribution: {'Easy': 1, 'Medium': 3, 'Hard': 1}),
    const CodingTopic(id: 'ai_llm', name: 'LLM Prompt Engineering', totalQuestions: 5, difficultyDistribution: {'Easy': 3, 'Medium': 2, 'Hard': 0}),
    const CodingTopic(id: 'ai_nn', name: 'Neural Networks', totalQuestions: 4, difficultyDistribution: {'Easy': 1, 'Medium': 2, 'Hard': 1}),
  ],
};

final List<CodingQuestion> _mockQuestions = [
  // Python Basics / Algorithms
  const CodingQuestion(
    id: 'q1',
    title: 'Reverse elements of a List',
    difficulty: 'Easy',
    topicId: 'ds_python',
    companies: ['Google', 'Amazon', 'Meta'],
    timeMin: 10,
    xpReward: 100,
    coinsReward: 10,
    hints: ['You can use slice notation list[::-1] in Python.', 'Alternatively, use list.reverse() in-place.'],
    problemStatement: 'Given an array of integers, return a new array with elements in reversed order.',
    examples: [
      QuestionExample(input: '[1, 2, 3, 4]', output: '[4, 3, 2, 1]'),
      QuestionExample(input: '[7, 8]', output: '[8, 7]'),
    ],
    constraints: ['List size ranges from 0 to 10^5.', 'Values are standard signed integers.'],
    expectedOutput: '[4, 3, 2, 1]',
    editorial: 'Reversing a list in Python is commonly performed via slicing list[::-1] which runs in O(N) time complexity and copies the pointer values.',
    docUrl: 'https://docs.python.org/3/tutorial/datastructures.html',
    videoUrl: 'https://youtube.com',
  ),
  const CodingQuestion(
    id: 'q2',
    title: 'Find Missing Value in Range',
    difficulty: 'Easy',
    topicId: 'ds_python',
    companies: ['Meta', 'Microsoft'],
    timeMin: 15,
    xpReward: 120,
    coinsReward: 12,
    hints: ['Calculate the sum of all elements from 0 to N.', 'Substract the sum of elements present in list.'],
    problemStatement: 'Given a list containing N distinct numbers taken from 0, 1, 2, ..., N, find the one that is missing from the list.',
    examples: [
      QuestionExample(input: '[3, 0, 1]', output: '2', explanation: 'N=3. The range is 0 to 3. 2 is missing.'),
    ],
    constraints: ['N == nums.length', '1 <= N <= 10^4', 'All numbers in list are unique.'],
    expectedOutput: '2',
    editorial: 'Using Gauss summation formula: ExpectedSum = N * (N + 1) / 2. Subtracting the actual sum of the array yields the missing item in O(N) time and O(1) space.',
    docUrl: 'https://docs.python.org',
    videoUrl: 'https://youtube.com',
  ),
  // NumPy Arrays
  const CodingQuestion(
    id: 'q3',
    title: 'Matrix Dot Product Multiplication',
    difficulty: 'Medium',
    topicId: 'ds_numpy',
    companies: ['Tesla', 'Nvidia', 'OpenAI'],
    timeMin: 20,
    xpReward: 200,
    coinsReward: 20,
    hints: ['Ensure inner dimensions match: shape A is (M, K) and shape B is (K, N).', 'Use np.dot(A, B) or the @ operator.'],
    problemStatement: 'Write a function executing dot-product multiplication of two matrices represented as numpy array inputs.',
    examples: [
      QuestionExample(input: 'A = [[1, 2], [3, 4]], B = [[5], [6]]', output: '[[17], [39]]'),
    ],
    constraints: ['Input arrays are numeric only.', 'Matrix dimensions match dot product requirements.'],
    expectedOutput: '[[17], [39]]',
    editorial: 'Matrix multiplication is computed by summing the product of row elements of A with column elements of B. NumPy uses BLAS under the hood for O(N^2.8) optimized multipliers.',
    docUrl: 'https://numpy.org/doc/stable/reference/generated/numpy.dot.html',
    videoUrl: 'https://youtube.com',
  ),
  // Pandas
  const CodingQuestion(
    id: 'q4',
    title: 'Filter Missing DataFrame Ages',
    difficulty: 'Easy',
    topicId: 'ds_pandas',
    companies: ['Netflix', 'Uber'],
    timeMin: 12,
    xpReward: 110,
    coinsReward: 10,
    hints: ['Check out df.dropna() or df[df["age"].notna()].', 'In pandas, missing items are parsed as NaN.'],
    problemStatement: 'Filter rows in a user DataFrame where the column "age" is missing.',
    examples: [
      QuestionExample(input: 'df with ages [25, NaN, 30]', output: 'df with ages [25, 30]'),
    ],
    constraints: ['DataFrame rows <= 10^6.'],
    expectedOutput: '[25, 30]',
    editorial: 'Filtering rows is done via boolean masking: df[df["age"].notna()] which keeps indices matching true boolean rows.',
    docUrl: 'https://pandas.pydata.org',
    videoUrl: 'https://youtube.com',
  ),
  // SQL queries
  const CodingQuestion(
    id: 'q5',
    title: 'Find Second Highest Salary',
    difficulty: 'Medium',
    topicId: 'ds_sql',
    companies: ['Google', 'Meta', 'Amazon'],
    timeMin: 18,
    xpReward: 180,
    coinsReward: 18,
    hints: ['Sort by salary descending and offset by 1.', 'Use DISTINCT to handle duplicates.', 'Ensure you return NULL if no second highest exists.'],
    problemStatement: 'Write an SQL query to retrieve the second highest distinct salary from the Employee table. Return NULL if it doesn\'t exist.',
    examples: [
      QuestionExample(input: 'Employee: [1: 100, 2: 200, 3: 300]', output: '200'),
    ],
    constraints: ['Database columns indexed properly.'],
    expectedOutput: '200',
    editorial: 'Select max(salary) from Employee where salary < (Select max(salary) from Employee) is an index-safe approach.',
    docUrl: 'https://dev.mysql.com/doc',
    videoUrl: 'https://youtube.com',
  ),
];

final List<LeaderboardEntry> _mockWeeklyLeaderboard = [
  const LeaderboardEntry(rank: 1, name: 'Siddharth M.', xp: 3450, avatar: '🦊'),
  const LeaderboardEntry(rank: 2, name: 'Priyanjali S.', xp: 2900, avatar: '🦁'),
  const LeaderboardEntry(rank: 3, name: 'You', xp: 1450, avatar: '⚡', isMe: true),
  const LeaderboardEntry(rank: 4, name: 'Amit Kumar', xp: 1200, avatar: '🐻'),
  const LeaderboardEntry(rank: 5, name: 'Nisha R.', xp: 950, avatar: '🐼'),
];

final List<LeaderboardEntry> _mockMonthlyLeaderboard = [
  const LeaderboardEntry(rank: 1, name: 'Priyanjali S.', xp: 12500, avatar: '🦁'),
  const LeaderboardEntry(rank: 2, name: 'Siddharth M.', xp: 11400, avatar: '🦊'),
  const LeaderboardEntry(rank: 3, name: 'Rohan Gupta', xp: 8700, avatar: '🐯'),
  const LeaderboardEntry(rank: 4, name: 'You', xp: 6200, avatar: '⚡', isMe: true),
  const LeaderboardEntry(rank: 5, name: 'Amit Kumar', xp: 5400, avatar: '🐻'),
];

final List<LeaderboardEntry> _mockFriendsLeaderboard = [
  const LeaderboardEntry(rank: 1, name: 'Rohan Gupta', xp: 2100, avatar: '🐯'),
  const LeaderboardEntry(rank: 2, name: 'You', xp: 1450, avatar: '⚡', isMe: true),
  const LeaderboardEntry(rank: 3, name: 'Nisha R.', xp: 950, avatar: '🐼'),
];

final List<CodingAchievement> _defaultAchievements = [
  const CodingAchievement(id: 'ach1', title: 'First Problem Solved', description: 'Solve 1 coding challenge successfully.', icon: '🎓', isUnlocked: true),
  const CodingAchievement(id: 'ach2', title: 'Code Warrior', description: 'Solve 10 coding challenges.', icon: '⚔️', isUnlocked: true),
  const CodingAchievement(id: 'ach3', title: 'Algorithm Knight', description: 'Solve 50 coding challenges.', icon: '🛡️'),
  const CodingAchievement(id: 'ach4', title: 'Data Grandmaster', description: 'Solve 100 coding challenges.', icon: '👑'),
  const CodingAchievement(id: 'ach5', title: 'Consistent Coder', description: 'Maintain a 7-day learning streak.', icon: '🔥', isUnlocked: true),
  const CodingAchievement(id: 'ach6', title: 'Streak Immortal', description: 'Maintain a 30-day learning streak.', icon: '🏆'),
  const CodingAchievement(id: 'ach7', title: 'XP Millionaire', description: 'Earn a total of 10,000 XP in Coding Practice.', icon: '💎'),
];

// ─────────────────────────────────────────────────────────────────────────────
// CODING PRACTICE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class CodingPracticeNotifier extends StateNotifier<CodingPracticeState> {
  final Ref _ref;

  CodingPracticeNotifier(this._ref) : super(const CodingPracticeState()) {
    loadPracticeData();
  }

  Future<void> loadPracticeData() async {
    state = state.copyWith(isLoading: true);
    final career = _ref.read(profileProvider).readingGoal.name;

    try {
      final careerSlug = career.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      await apiClient.get('/coding/practice?career=$careerSlug');
    } catch (_) {
      // Fallback
      final topicsList = _mockTopicsByCareer[career] ?? _mockTopicsByCareer['aiEngineer']!;

      final prefs = await SharedPreferences.getInstance();
      
      // Sync questions solved status
      final List<CodingQuestion> questions = [];
      final Map<String, int> topicSolvedMap = {};

      for (final q in _mockQuestions) {
        final qStatus = prefs.getString('code_q_status_${q.id}') ?? 'unsolved';
        questions.add(q.copyWith(status: qStatus));

        if (qStatus == 'solved') {
          topicSolvedMap[q.topicId] = (topicSolvedMap[q.topicId] ?? 0) + 1;
        }
      }

      // Sync topic details counts
      final List<CodingTopic> hydratedTopics = [];
      for (final t in topicsList) {
        final solved = topicSolvedMap[t.id] ?? 0;
        hydratedTopics.add(t.copyWith(
          completedQuestions: solved,
          xpEarned: solved * 120,
        ));
      }

      final solvedTotalCount = topicSolvedMap.values.fold<int>(0, (sum, val) => sum + val);

      // Achievements unlocked check
      final updatedAchievements = _defaultAchievements.map((ach) {
        bool unlocked = ach.isUnlocked;
        if (ach.id == 'ach2' && solvedTotalCount >= 10) unlocked = true;
        if (ach.id == 'ach3' && solvedTotalCount >= 50) unlocked = true;
        if (ach.id == 'ach4' && solvedTotalCount >= 100) unlocked = true;
        return ach.copyWith(isUnlocked: unlocked);
      }).toList();

      state = state.copyWith(
        streak: prefs.getInt('code_streak') ?? 3,
        totalXpEarned: prefs.getInt('code_total_xp') ?? 1450,
        totalCoinsEarned: prefs.getInt('code_total_coins') ?? 120,
        solvedCount: solvedTotalCount + 10, // add a baseline of 10 resolved
        weeklyGoalSolved: solvedTotalCount,
        dailyChallenge: _mockQuestions.first,
        topics: hydratedTopics,
        questions: questions,
        weeklyLeaderboard: _mockWeeklyLeaderboard,
        monthlyLeaderboard: _mockMonthlyLeaderboard,
        friendsLeaderboard: _mockFriendsLeaderboard,
        achievements: updatedAchievements,
        isLoading: false,
      );
    }
  }

  Future<void> submitSolution(String questionId, String userCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mark as solved
    await prefs.setString('code_q_status_$questionId', 'solved');
    
    // Find reward values
    final question = _mockQuestions.firstWhere((q) => q.id == questionId);

    // Update state stats
    final nextXp = state.totalXpEarned + question.xpReward;
    final nextCoins = state.totalCoinsEarned + question.coinsReward;
    await prefs.setInt('code_total_xp', nextXp);
    await prefs.setInt('code_total_coins', nextCoins);

    // Sync XP with profile
    await _ref.read(xpProvider.notifier).addXp(question.xpReward);

    // Increment coins balance
    final currentCoins = prefs.getInt('user_coins') ?? 100;
    await prefs.setInt('user_coins', currentCoins + question.coinsReward);

    // Reload list
    await loadPracticeData();
  }

  Future<void> completeDailyChallenge() async {
    if (state.dailyChallenge == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Award bonus rewards
    final bonusXp = 250;
    final bonusCoins = 30;
    
    final nextXp = state.totalXpEarned + bonusXp;
    final nextCoins = state.totalCoinsEarned + bonusCoins;
    final nextStreak = state.streak + 1;

    await prefs.setInt('code_total_xp', nextXp);
    await prefs.setInt('code_total_coins', nextCoins);
    await prefs.setInt('code_streak', nextStreak);

    await _ref.read(xpProvider.notifier).addXp(bonusXp);
    final currentCoins = prefs.getInt('user_coins') ?? 100;
    await prefs.setInt('user_coins', currentCoins + bonusCoins);

    // Reload list
    await loadPracticeData();
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = state.streak + 1;
    await prefs.setInt('code_streak', streak);
    state = state.copyWith(streak: streak);
  }

  Future<void> refresh() async {
    await loadPracticeData();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDER EXPORT
// ─────────────────────────────────────────────────────────────────────────────

final codingPracticeProvider = StateNotifierProvider<CodingPracticeNotifier, CodingPracticeState>((ref) {
  return CodingPracticeNotifier(ref);
});

// Helper detail lookup
CodingQuestion? findQuestionById(String id, List<CodingQuestion> questions) {
  try {
    return questions.firstWhere((q) => q.id == id);
  } catch (_) {
    for (final q in _mockQuestions) {
      if (q.id == id) return q;
    }
  }
  return null;
}
