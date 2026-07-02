import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../../models/book_model.dart';
import '../profile/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMPATIBILITY MODELS (OLD BOOKS MODULE)
// ─────────────────────────────────────────────────────────────────────────────

class CompletedBook {
  final Book book;
  final String completedDate;
  final double userRating;

  CompletedBook({
    required this.book,
    required this.completedDate,
    required this.userRating,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW MODEL DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

class LearningResource {
  final String id;
  final String title;
  final String provider;
  final String type; // documentation, youtube, courses, coding practice, projects, blogs, research papers, interview questions
  final String difficulty; // Beginner, Intermediate, Advanced
  final int timeMin;
  final int xpReward;
  final int coinsReward;
  final List<String> skills;
  final String url;
  final bool isBookmarked;
  final String completionStatus; // not_started, in_progress, completed
  final String icon;
  final String description;
  final String aiReason;
  final String? missionLink; // Link to a related mission
  final List<String> relatedResourceIds;

  const LearningResource({
    required this.id,
    required this.title,
    required this.provider,
    required this.type,
    required this.difficulty,
    required this.timeMin,
    required this.xpReward,
    required this.coinsReward,
    required this.skills,
    required this.url,
    this.isBookmarked = false,
    this.completionStatus = 'not_started',
    this.icon = '📖',
    this.description = '',
    this.aiReason = '',
    this.missionLink,
    this.relatedResourceIds = const [],
  });

  LearningResource copyWith({
    bool? isBookmarked,
    String? completionStatus,
  }) {
    return LearningResource(
      id: id,
      title: title,
      provider: provider,
      type: type,
      difficulty: difficulty,
      timeMin: timeMin,
      xpReward: xpReward,
      coinsReward: coinsReward,
      skills: skills,
      url: url,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      completionStatus: completionStatus ?? this.completionStatus,
      icon: icon,
      description: description,
      aiReason: aiReason,
      missionLink: missionLink,
      relatedResourceIds: relatedResourceIds,
    );
  }

  factory LearningResource.fromJson(Map<String, dynamic> j) {
    return LearningResource(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      provider: j['provider'] ?? j['source'] ?? '',
      type: j['type'] ?? 'courses',
      difficulty: j['difficulty'] ?? 'Intermediate',
      timeMin: j['time_min'] ?? 30,
      xpReward: j['xp_reward'] ?? 100,
      coinsReward: j['coins_reward'] ?? 10,
      skills: List<String>.from(j['skills'] ?? []),
      url: j['url'] ?? '',
      isBookmarked: j['is_bookmarked'] ?? false,
      completionStatus: j['completion_status'] ?? 'not_started',
      icon: j['icon'] ?? '📖',
      description: j['description'] ?? '',
      aiReason: j['ai_reason'] ?? '',
      missionLink: j['mission_link'],
      relatedResourceIds: List<String>.from(j['related_resource_ids'] ?? []),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

class LibraryState {
  final List<LearningResource> resources;
  final String selectedCategory; // All or a specific type
  final String selectedFilter; // All, Beginner, Intermediate, Advanced, Completed, Bookmarked, Recommended
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  // Compatibility fields for old books module
  final List<Book> continueReading;
  final List<Book> saved;
  final List<CompletedBook> completed;

  const LibraryState({
    this.resources = const [],
    this.selectedCategory = 'All',
    this.selectedFilter = 'All',
    this.searchQuery = '',
    this.isLoading = true,
    this.errorMessage,
    this.continueReading = const [],
    this.saved = const [],
    this.completed = const [],
  });

  LibraryState copyWith({
    List<LearningResource>? resources,
    String? selectedCategory,
    String? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    List<Book>? continueReading,
    List<Book>? saved,
    List<CompletedBook>? completed,
  }) {
    return LibraryState(
      resources: resources ?? this.resources,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      continueReading: continueReading ?? this.continueReading,
      saved: saved ?? this.saved,
      completed: completed ?? this.completed,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAREER-SPECIFIC MOCK DATA
// ─────────────────────────────────────────────────────────────────────────────

final Map<String, List<LearningResource>> _mockResourcesByCareer = {
  'dataScientist': [
    const LearningResource(
      id: 'ds1',
      title: 'Pandas Data Wrangling Cheat Sheet',
      provider: 'Pandas Dev Team',
      type: 'Documentation',
      difficulty: 'Beginner',
      timeMin: 15,
      xpReward: 150,
      coinsReward: 10,
      skills: ['Python', 'Pandas', 'Data Cleaning'],
      url: 'https://pandas.pydata.org/Pandas_Cheat_Sheet.pdf',
      icon: '🐼',
      description: 'The definitive quick-reference guide to indexing, reshaping, and cleaning data frames using Pandas.',
      aiReason: 'Pandas is the bedrock of 90% of Data Science pipelines. Mastering the basic APIs first prevents syntax blockers.',
      missionLink: 'Complete Pandas Basics',
      relatedResourceIds: ['ds2', 'ds3'],
    ),
    const LearningResource(
      id: 'ds2',
      title: 'StatQuest: Linear Regression Explained Visually',
      provider: 'YouTube (Josh Starmer)',
      type: 'YouTube',
      difficulty: 'Beginner',
      timeMin: 22,
      xpReward: 200,
      coinsReward: 15,
      skills: ['Statistics', 'Linear Regression', 'Math'],
      url: 'https://youtube.com',
      icon: '📊',
      description: 'A visual walkthrough of regression algorithms, residuals, and cost functions with zero math intimidation.',
      aiReason: 'Your statistics assessment shows a slight gap in regression residuals. This video is the highest-rated visual explanation.',
      missionLink: 'Watch Regression Tutorials',
      relatedResourceIds: ['ds1', 'ds4'],
    ),
    const LearningResource(
      id: 'ds3',
      title: 'SQL for Data Analysis Mastery Course',
      provider: 'Udemy (Jose Portilla)',
      type: 'Courses',
      difficulty: 'Intermediate',
      timeMin: 180,
      xpReward: 1000,
      coinsReward: 80,
      skills: ['SQL', 'PostgreSQL', 'Joins', 'Aggregations'],
      url: 'https://udemy.com',
      icon: '🗃️',
      description: 'A comprehensive video course covering group by, joins, subqueries, and window functions for real analyst tasks.',
      aiReason: 'Data scientist roles require expert-level SQL. This structured course maps directly to interview queries.',
      missionLink: 'Complete SQL Masterclass',
      relatedResourceIds: ['ds1', 'ds8'],
    ),
    const LearningResource(
      id: 'ds4',
      title: 'Solve 15 SQL Aggregations Tasks',
      provider: 'LeetCode / Hackerrank',
      type: 'Coding Practice',
      difficulty: 'Intermediate',
      timeMin: 60,
      xpReward: 400,
      coinsReward: 30,
      skills: ['SQL', 'Problem Solving', 'Aggregations'],
      url: 'https://leetcode.com',
      icon: '🧩',
      description: '15 aggregated database problems targeting Group By, Having, and Window functions under time constraint.',
      aiReason: 'Practical practice solidifies SQL syntax. Completing this unlocks the Level 3 SQL Badge.',
      missionLink: 'Solve 5 SQL Hard Problems',
      relatedResourceIds: ['ds3'],
    ),
    const LearningResource(
      id: 'ds5',
      title: 'Predicting Housing Prices on Kaggle',
      provider: 'Kaggle Competition',
      type: 'Projects',
      difficulty: 'Intermediate',
      timeMin: 150,
      xpReward: 800,
      coinsReward: 60,
      skills: ['Python', 'Scikit-Learn', 'Feature Engineering'],
      url: 'https://kaggle.com',
      icon: '🏡',
      description: 'Build a random forest regressor to predict house prices, clean structural outliers, and score under top 20%.',
      aiReason: 'This project is the golden standard for intermediate portfolios. It tests end-to-end data pipelines.',
      missionLink: 'Submit Housing Predictions',
      relatedResourceIds: ['ds1', 'ds2'],
    ),
    const LearningResource(
      id: 'ds6',
      title: 'Machine Learning Engineering Trends 2026',
      provider: 'Towards Data Science',
      type: 'Blogs',
      difficulty: 'Advanced',
      timeMin: 12,
      xpReward: 100,
      coinsReward: 5,
      skills: ['MLOps', 'Vector Databases', 'Future Trends'],
      url: 'https://towardsdatascience.com',
      icon: '📝',
      description: 'An industry overview of how real-time inference, vector indexes, and LLM fine-tuning are shaping data roles.',
      aiReason: 'Keeping up with industry shifts is key to standing out during engineering interviews.',
      missionLink: 'Read Weekly Trends',
      relatedResourceIds: ['ds7'],
    ),
    const LearningResource(
      id: 'ds7',
      title: 'XGBoost: A Scalable Tree Boosting System Paper',
      provider: 'ArXiv (Tianqi Chen)',
      type: 'Research Papers',
      difficulty: 'Advanced',
      timeMin: 45,
      xpReward: 600,
      coinsReward: 45,
      skills: ['Machine Learning', 'Gradient Boosting', 'Math'],
      url: 'https://arxiv.org/abs/1603.02754',
      icon: '📄',
      description: 'The original paper introducing the XGBoost algorithm, covering mathematical derivations and parallel split finding.',
      aiReason: 'Understanding the underlying math behind models is what differentiates advanced data scientists from beginners.',
      missionLink: 'Study Boosting Papers',
      relatedResourceIds: ['ds2', 'ds6'],
    ),
    const LearningResource(
      id: 'ds8',
      title: '30 Data Science Interview Prep Qs',
      provider: 'InterviewQuery',
      type: 'Interview Questions',
      difficulty: 'Advanced',
      timeMin: 50,
      xpReward: 500,
      coinsReward: 35,
      skills: ['A/B Testing', 'Overfitting', 'Probability'],
      url: 'https://interviewquery.com',
      icon: '🎤',
      description: 'Curated list of real questions asked at Google, Meta, and Netflix, covering statistics, ML, and product sense.',
      aiReason: 'A/B testing theory is heavily tested in tier-1 tech companies. This review covers the 5 most common traps.',
      missionLink: 'Practice Interview Questions',
      relatedResourceIds: ['ds3', 'ds4'],
    ),
  ],
  'uxDesigner': [
    const LearningResource(
      id: 'ux1',
      title: 'Figma Auto Layout v5 Deep Dive',
      provider: 'Figma Learning Hub',
      type: 'Figma Resources',
      difficulty: 'Beginner',
      timeMin: 20,
      xpReward: 150,
      coinsReward: 10,
      skills: ['Figma', 'UI Design', 'Responsiveness'],
      url: 'https://figma.com',
      icon: '📐',
      description: 'Master advanced responsive spacing, wrapping, fill constraints, and absolute positioning in Figma components.',
      aiReason: 'Figma Auto Layout is critical for handoff. Your profile shows you can speed up screen mockups by 30% using these shortcuts.',
      missionLink: 'Figma Basics Track',
      relatedResourceIds: ['ux2', 'ux4'],
    ),
    const LearningResource(
      id: 'ux2',
      title: 'Material Design 3 Guidelines',
      provider: 'Google Design',
      type: 'Design Systems',
      difficulty: 'Intermediate',
      timeMin: 40,
      xpReward: 300,
      coinsReward: 20,
      skills: ['Design Systems', 'Typography', 'Color Theory'],
      url: 'https://m3.material.io',
      icon: '🎨',
      description: 'Comprehensive guidelines for adaptive layouts, dynamic color palettes, micro-interactions, and visual tokens.',
      aiReason: 'A dynamic system is what gives apps their professional edge. M3 rules are standard across Android and web development.',
      missionLink: 'Study Design Systems',
      relatedResourceIds: ['ux1', 'ux3'],
    ),
    const LearningResource(
      id: 'ux3',
      title: 'Uber Mobile Redesign Case Study',
      provider: 'Medium (UX Collective)',
      type: 'Case Studies',
      difficulty: 'Intermediate',
      timeMin: 25,
      xpReward: 200,
      coinsReward: 15,
      skills: ['User Research', 'Information Architecture', 'Handoff'],
      url: 'https://medium.com',
      icon: '🚗',
      description: 'A breakdown of Uber\'s interface overhaul, mapping out user journeys, cognitive loads, and usability studies.',
      aiReason: 'Understanding real-world product decisions is crucial to passing design case study interviews.',
      missionLink: 'Read Case Studies',
      relatedResourceIds: ['ux2', 'ux6'],
    ),
    const LearningResource(
      id: 'ux4',
      title: 'Daily UI Challenge: Day 1 to 10',
      provider: 'DailyUI.co',
      type: 'UI Challenges',
      difficulty: 'Beginner',
      timeMin: 60,
      xpReward: 400,
      coinsReward: 30,
      skills: ['Visual Design', 'Figma', 'High Fidelity'],
      url: 'https://dailyui.co',
      icon: '🎯',
      description: 'Design a sign-up page, checkout flow, landing page, and calculators daily to establish visual speed.',
      aiReason: 'Fast UI generation builds design intuition. This challenge will boost your Figma creation speed.',
      missionLink: 'Complete 3 UI Challenges',
      relatedResourceIds: ['ux1'],
    ),
    const LearningResource(
      id: 'ux5',
      title: 'Typography & Layout Essentials',
      provider: 'YouTube Tutorials',
      type: 'YouTube Tutorials',
      difficulty: 'Beginner',
      timeMin: 18,
      xpReward: 150,
      coinsReward: 10,
      skills: ['Typography', 'Grid Systems', 'Hierarchy'],
      url: 'https://youtube.com',
      icon: '▶️',
      description: 'Learn how to utilize baseline grids, contrasting fonts, and whitespace to elevate basic designs.',
      aiReason: 'Visual hierarchy is the most common critique in portfolios. This video shows common rookie typography mistakes.',
      missionLink: 'Watch Typography Playlist',
      relatedResourceIds: ['ux2'],
    ),
    const LearningResource(
      id: 'ux6',
      title: 'UX Laws You Must Follow',
      provider: 'UX Laws (Jon Yablonski)',
      type: 'Blogs',
      difficulty: 'Intermediate',
      timeMin: 15,
      xpReward: 120,
      coinsReward: 8,
      skills: ['Cognitive Psychology', 'Fitts\'s Law', 'Jakob\'s Law'],
      url: 'https://lawsofux.com',
      icon: '📝',
      description: 'An interactive handbook detailing Fitts\'s Law, Hick\'s Law, and mental models that direct human behaviors.',
      aiReason: 'Design decisions must be backed by psychology. These laws justify your layouts to developers and stakeholders.',
      missionLink: 'Review UX Psychology',
      relatedResourceIds: ['ux3'],
    ),
    const LearningResource(
      id: 'ux7',
      title: 'Redesigning a Local Business App',
      provider: 'Portfolio Prompt',
      type: 'Portfolio Tasks',
      difficulty: 'Advanced',
      timeMin: 120,
      xpReward: 700,
      coinsReward: 50,
      skills: ['Wireframing', 'User Testing', 'High Fidelity'],
      url: 'https://github.com',
      icon: '💼',
      description: 'Identify a local business website, audit its current navigation errors, wireframe solutions, and present mockups.',
      aiReason: 'Recruiters hire based on portfolio quality. This prompt tests your end-to-end design thinking.',
      missionLink: 'Complete First Portfolio Project',
      relatedResourceIds: ['ux1', 'ux3', 'ux4'],
    ),
  ],
  'aiEngineer': [
    const LearningResource(
      id: 'ai1',
      title: 'NumPy Quickstart Guide',
      provider: 'NumPy.org',
      type: 'Documentation',
      difficulty: 'Beginner',
      timeMin: 15,
      xpReward: 150,
      coinsReward: 10,
      skills: ['Python', 'NumPy', 'Arrays'],
      url: 'https://numpy.org/doc/stable/user/quickstart.html',
      icon: '🧮',
      description: 'Master multi-dimensional array operations, vectorization, slicing, indexing, and basic algebraic matrices.',
      aiReason: 'AI engineering starts with matrix mathematics. Vectorized operations are 100x faster than traditional loops.',
      missionLink: 'Complete NumPy Basics',
      relatedResourceIds: ['ai2', 'ai4'],
    ),
    const LearningResource(
      id: 'ai2',
      title: '3Blue1Brown: Neural Networks Deep Dive',
      provider: 'YouTube',
      type: 'YouTube',
      difficulty: 'Beginner',
      timeMin: 30,
      xpReward: 250,
      coinsReward: 15,
      skills: ['Neural Networks', 'Math', 'Backpropagation'],
      url: 'https://youtube.com',
      icon: '🧠',
      description: 'A beautiful visual breakdown of layers, weights, biases, cost functions, gradient descent, and backpropagation.',
      aiReason: 'Visualizing gradient descent makes tuning real training parameters significantly easier.',
      missionLink: 'Watch Neural Networks Series',
      relatedResourceIds: ['ai1', 'ai7'],
    ),
    const LearningResource(
      id: 'ai3',
      title: 'PyTorch Deep Learning Boot Camp',
      provider: 'Udemy (Daniel Bourke)',
      type: 'Courses',
      difficulty: 'Intermediate',
      timeMin: 210,
      xpReward: 1100,
      coinsReward: 90,
      skills: ['Python', 'PyTorch', 'Model Building'],
      url: 'https://udemy.com',
      icon: '🎓',
      description: 'A comprehensive coding course on tensors, computer vision, binary classification, and model custom architectures.',
      aiReason: 'PyTorch is the leading library for AI research and deployment. This course maps directly to real-world pipelines.',
      missionLink: 'Complete PyTorch Bootcamp',
      relatedResourceIds: ['ai1', 'ai5'],
    ),
    const LearningResource(
      id: 'ai4',
      title: 'Implement SGD from Scratch',
      provider: 'HackerRank AI Track',
      type: 'Coding Practice',
      difficulty: 'Intermediate',
      timeMin: 45,
      xpReward: 350,
      coinsReward: 25,
      skills: ['Python', 'Linear Algebra', 'Gradient Descent'],
      url: 'https://hackerrank.com',
      icon: '🧩',
      description: 'Write a raw python implementation of stochastic gradient descent without scikit-learn, optimizing MSE loss.',
      aiReason: 'Understanding the mechanics behind optimizers is highly sought after in senior AI engineer interviews.',
      missionLink: 'Solve 2 ML Coding Problems',
      relatedResourceIds: ['ai1', 'ai2'],
    ),
    const LearningResource(
      id: 'ai5',
      title: 'Fine-Tuning Llama 3 with LoRA',
      provider: 'GitHub Open Source',
      type: 'Projects',
      difficulty: 'Advanced',
      timeMin: 180,
      xpReward: 900,
      coinsReward: 70,
      skills: ['LLMs', 'Fine-Tuning', 'HuggingFace', 'LoRA'],
      url: 'https://github.com',
      icon: '🦙',
      description: 'Build a custom fine-tuning script to train Llama 3 on a specialized dataset using Parameter-Efficient Fine-Tuning.',
      aiReason: 'Fine-tuning LLMs is a top skill in 2026. This portfolio project proves you can optimize production inference budgets.',
      missionLink: 'Deploy Fine-Tuned LLM',
      relatedResourceIds: ['ai3', 'ai7'],
    ),
    const LearningResource(
      id: 'ai6',
      title: 'HuggingFace NLP Blog: Optimizing Transformers',
      provider: 'HuggingFace Blog',
      type: 'Blogs',
      difficulty: 'Intermediate',
      timeMin: 15,
      xpReward: 120,
      coinsReward: 10,
      skills: ['NLP', 'Quantization', 'Transformers'],
      url: 'https://huggingface.co/blog',
      icon: '📝',
      description: 'An overview of network quantization (INT8/FP4), flash attention, and pruning methods for edge deployment.',
      aiReason: 'AI engineers must know hardware constraints. This post explains how to fit models on consumer GPUs.',
      missionLink: 'Read Optimization Blogs',
      relatedResourceIds: ['ai5'],
    ),
    const LearningResource(
      id: 'ai7',
      title: 'Attention Is All You Need',
      provider: 'ArXiv (Google Research)',
      type: 'Research Papers',
      difficulty: 'Advanced',
      timeMin: 60,
      xpReward: 700,
      coinsReward: 50,
      skills: ['Deep Learning', 'Transformers', 'Self-Attention'],
      url: 'https://arxiv.org/abs/1706.03762',
      icon: '📄',
      description: 'The seminal paper that introduced the Transformer architecture, replacing recurrent models with self-attention networks.',
      aiReason: 'This is the most important paper in modern AI history. Understanding query, key, and value matrices is a must-know.',
      missionLink: 'Study Seminal AI Papers',
      relatedResourceIds: ['ai2', 'ai5'],
    ),
    const LearningResource(
      id: 'ai8',
      title: 'Transformer Architecture Interview Review',
      provider: 'KDNuggets / Medium',
      type: 'Interview Questions',
      difficulty: 'Advanced',
      timeMin: 40,
      xpReward: 400,
      coinsReward: 25,
      skills: ['NLP', 'Transformers', 'Attention Complexity'],
      url: 'https://kdnuggets.com',
      icon: '🎤',
      description: 'Common technical questions covering positional encoding, KV caching, rotary embeddings, and attention scale math.',
      aiReason: 'AI interviews focus heavily on mechanical attention details. This document covers the top 15 technical traps.',
      missionLink: 'Practice LLM Interview Qs',
      relatedResourceIds: ['ai7'],
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// LIBRARY NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;

  LibraryNotifier(this._ref) : super(const LibraryState()) {
    loadLibraryData();
  }

  Future<void> loadLibraryData() async {
    state = state.copyWith(isLoading: true);
    final career = _ref.read(profileProvider).readingGoal.name;

    try {
      final careerSlug = career.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      final resourcesJson = await apiClient.get('/home/resources?career=$careerSlug');
      final fetchedList = (resourcesJson as List)
          .map((r) => LearningResource.fromJson(Map<String, dynamic>.from(r)))
          .toList();

      state = state.copyWith(
        resources: fetchedList,
        isLoading: false,
      );
    } catch (_) {
      final fallbacks = _mockResourcesByCareer[career] ?? _mockResourcesByCareer['aiEngineer']!;

      final prefs = await SharedPreferences.getInstance();
      final updatedList = fallbacks.map((r) {
        final isBookmarked = prefs.getBool('res_bookmarked_${r.id}') ?? r.isBookmarked;
        final completionStatus = prefs.getString('res_status_${r.id}') ?? r.completionStatus;
        return r.copyWith(
          isBookmarked: isBookmarked,
          completionStatus: completionStatus,
        );
      }).toList();

      state = state.copyWith(
        resources: updatedList,
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadLibraryData();
  }

  Future<void> toggleBookmark(String resourceId) async {
    final updatedList = state.resources.map((r) {
      if (r.id == resourceId) {
        final nextVal = !r.isBookmarked;
        _saveBookmarkLocal(resourceId, nextVal);
        return r.copyWith(isBookmarked: nextVal);
      }
      return r;
    }).toList();

    state = state.copyWith(resources: updatedList);
  }

  Future<void> _saveBookmarkLocal(String id, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('res_bookmarked_$id', val);
    
    try {
      if (val) {
        await apiClient.post('/library/save?book_id=$id');
      } else {
        await apiClient.delete('/library/remove/$id');
      }
    } catch (_) {}
  }

  Future<void> updateCompletionStatus(String resourceId, String nextStatus) async {
    final updatedList = state.resources.map((r) {
      if (r.id == resourceId) {
        _saveStatusLocal(resourceId, nextStatus);
        return r.copyWith(completionStatus: nextStatus);
      }
      return r;
    }).toList();

    state = state.copyWith(resources: updatedList);
  }

  Future<void> _saveStatusLocal(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('res_status_$id', status);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // COMPATIBILITY METHODS (OLD BOOKS MODULE)
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> updateProgress(String bookId, int readPages) async {}
  Future<void> removeSavedBook(String bookId) async {}
  Future<void> toggleSaveBook(dynamic book) async {}
  void readAgain(String bookId) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDER EXPORT
// ─────────────────────────────────────────────────────────────────────────────

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier(ref);
});

// Helper for detail lookup
LearningResource? findResourceById(String id, List<LearningResource> resources) {
  try {
    return resources.firstWhere((r) => r.id == id);
  } catch (_) {
    for (final list in _mockResourcesByCareer.values) {
      for (final r in list) {
        if (r.id == id) return r;
      }
    }
  }
  return null;
}
