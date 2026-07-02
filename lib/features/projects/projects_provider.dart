import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../profile/profile_provider.dart';
import '../profile/xp_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROJECT MODELS
// ─────────────────────────────────────────────────────────────────────────────

class ProjectMilestone {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final int xpGained;
  final int coinsGained;
  final bool isUnlocked;

  const ProjectMilestone({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    this.xpGained = 150,
    this.coinsGained = 15,
    this.isUnlocked = false,
  });

  ProjectMilestone copyWith({
    bool? isCompleted,
    bool? isUnlocked,
  }) {
    return ProjectMilestone(
      id: id,
      name: name,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      xpGained: xpGained,
      coinsGained: coinsGained,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  factory ProjectMilestone.fromJson(Map<String, dynamic> j) {
    return ProjectMilestone(
      id: j['id']?.toString() ?? '',
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      isCompleted: j['is_completed'] ?? false,
      xpGained: j['xp_gained'] ?? 150,
      coinsGained: j['coins_gained'] ?? 15,
      isUnlocked: j['is_unlocked'] ?? false,
    );
  }
}

class ProjectResource {
  final String type; // documentation, video, course
  final String name;
  final String url;

  const ProjectResource({required this.type, required this.name, required this.url});

  factory ProjectResource.fromJson(Map<String, dynamic> j) {
    return ProjectResource(
      type: j['type'] ?? 'documentation',
      name: j['name'] ?? '',
      url: j['url'] ?? '',
    );
  }
}

class MentorMessage {
  final String sender; // 'user' or 'mentor'
  final String text;
  final DateTime timestamp;

  const MentorMessage({required this.sender, required this.text, required this.timestamp});
}

class Project {
  final String id;
  final String name;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String duration; // e.g. "2 weeks", "12 hours"
  final List<String> requiredSkills;
  final int xpReward;
  final int coinsReward;
  final String portfolioValue; // Crucial, High, Medium
  final String status; // not_started, in_progress, completed
  final String imageGradientStart;
  final String imageGradientEnd;
  final String icon;
  
  final String overview;
  final String problemStatement;
  final String whatYouWillBuild;
  final List<String> techStack;
  final List<String> prerequisites;
  final List<ProjectResource> resources;
  final String? datasetUrl;
  final List<ProjectMilestone> milestones;
  final String expectedOutput;

  const Project({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.duration,
    required this.requiredSkills,
    required this.xpReward,
    required this.coinsReward,
    required this.portfolioValue,
    this.status = 'not_started',
    required this.imageGradientStart,
    required this.imageGradientEnd,
    this.icon = '🚀',
    required this.overview,
    required this.problemStatement,
    required this.whatYouWillBuild,
    required this.techStack,
    required this.prerequisites,
    required this.resources,
    this.datasetUrl,
    required this.milestones,
    required this.expectedOutput,
  });

  int get completedMilestoneCount => milestones.where((m) => m.isCompleted).length;
  double get progressPercentage => milestones.isEmpty ? 0.0 : completedMilestoneCount / milestones.length;

  Project copyWith({
    String? status,
    List<ProjectMilestone>? milestones,
  }) {
    return Project(
      id: id,
      name: name,
      difficulty: difficulty,
      duration: duration,
      requiredSkills: requiredSkills,
      xpReward: xpReward,
      coinsReward: coinsReward,
      portfolioValue: portfolioValue,
      status: status ?? this.status,
      imageGradientStart: imageGradientStart,
      imageGradientEnd: imageGradientEnd,
      icon: icon,
      overview: overview,
      problemStatement: problemStatement,
      whatYouWillBuild: whatYouWillBuild,
      techStack: techStack,
      prerequisites: prerequisites,
      resources: resources,
      datasetUrl: datasetUrl,
      milestones: milestones ?? this.milestones,
      expectedOutput: expectedOutput,
    );
  }

  factory Project.fromJson(Map<String, dynamic> j) {
    return Project(
      id: j['id']?.toString() ?? '',
      name: j['name'] ?? '',
      difficulty: j['difficulty'] ?? 'Intermediate',
      duration: j['duration'] ?? '10 hours',
      requiredSkills: List<String>.from(j['required_skills'] ?? []),
      xpReward: j['xp_reward'] ?? 500,
      coinsReward: j['coins_reward'] ?? 50,
      portfolioValue: j['portfolio_value'] ?? 'High',
      status: j['status'] ?? 'not_started',
      imageGradientStart: j['gradient_start'] ?? '0xFF1A1F3C',
      imageGradientEnd: j['gradient_end'] ?? '0xFF0D0F1F',
      icon: j['icon'] ?? '🚀',
      overview: j['overview'] ?? '',
      problemStatement: j['problem_statement'] ?? '',
      whatYouWillBuild: j['what_you_will_build'] ?? '',
      techStack: List<String>.from(j['tech_stack'] ?? []),
      prerequisites: List<String>.from(j['prerequisites'] ?? []),
      resources: (j['resources'] as List? ?? [])
          .map((r) => ProjectResource.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
      datasetUrl: j['dataset_url'],
      milestones: (j['milestones'] as List? ?? [])
          .map((m) => ProjectMilestone.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      expectedOutput: j['expected_output'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class ProjectsState {
  final List<Project> projects;
  final String selectedFilter; // All, Beginner, Intermediate, Advanced, Completed, In Progress, Recommended
  final Map<String, List<MentorMessage>> projectMentorChats; // ProjectID -> ChatMessages
  final bool isLoading;
  final bool isSendingMessage;
  final String? errorMessage;

  const ProjectsState({
    this.projects = const [],
    this.selectedFilter = 'All',
    this.projectMentorChats = const {},
    this.isLoading = true,
    this.isSendingMessage = false,
    this.errorMessage,
  });

  ProjectsState copyWith({
    List<Project>? projects,
    String? selectedFilter,
    Map<String, List<MentorMessage>>? projectMentorChats,
    bool? isLoading,
    bool? isSendingMessage,
    String? errorMessage,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      projectMentorChats: projectMentorChats ?? this.projectMentorChats,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK PROJECTS DATA (CAREER SPECIFIC FALLBACKS)
// ─────────────────────────────────────────────────────────────────────────────

final List<ProjectMilestone> _defaultMilestones = [
  const ProjectMilestone(id: 'm1', name: 'Environment Setup', description: 'Configure development environment, install libraries, and prepare directories.', isUnlocked: true),
  const ProjectMilestone(id: 'm2', name: 'Learn Core Basics', description: 'Study prerequisites, official documentation guidelines, and setup variables.'),
  const ProjectMilestone(id: 'm3', name: 'Core Implementation', description: 'Code the primary architectural logic and implement the core functions.'),
  const ProjectMilestone(id: 'm4', name: 'Rigorous Testing', description: 'Write unit tests, handle extreme inputs, and verify visual edge cases.'),
  const ProjectMilestone(id: 'm5', name: 'Optimization & Speed', description: 'Refactor code, index queries, cache properties, and measure frame rates.'),
  const ProjectMilestone(id: 'm6', name: 'Portfolio Submission', description: 'Export screenshots, prepare README documentation, and submit repository links.'),
];

final Map<String, List<Project>> _mockProjectsByCareer = {
  'dataScientist': [
    Project(
      id: 'proj_ds_1',
      name: 'Customer Churn Analytics Engine',
      difficulty: 'Intermediate',
      duration: '12 hours',
      requiredSkills: ['Python', 'Pandas', 'Scikit-Learn', 'Feature Engineering'],
      xpReward: 800,
      coinsReward: 70,
      portfolioValue: 'Crucial',
      imageGradientStart: '0xFF1A362B',
      imageGradientEnd: '0xFF0A1F16',
      icon: '📉',
      overview: 'Develop an end-to-end predictive classification pipeline to identify subscription customers at high risk of churning.',
      problemStatement: 'Telecom subscription business loses 4% recurring monthly revenue due to customer churn. You must predict churners 30 days in advance to allow target marketing campaigns to save them.',
      whatYouWillBuild: 'A serialized Python library deploying a Random Forest classifier, evaluating recall metrics, and generating prediction score spreadsheets.',
      techStack: ['Python', 'Scikit-Learn', 'Pandas', 'Jupyter', 'Joblib'],
      prerequisites: ['Basic Python scripts', 'Understand classification matrices (F1, Recall)'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'Scikit-Learn Classifier docs', url: 'https://scikit-learn.org'),
        ProjectResource(type: 'video', name: 'Visual Classification Metrics (YouTube)', url: 'https://youtube.com'),
        ProjectResource(type: 'course', name: 'Data Science Feature Engineering BootCamp', url: 'https://udemy.com'),
      ],
      datasetUrl: 'https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv',
      milestones: _defaultMilestones,
      expectedOutput: 'A complete GitHub repository hosting: (1) Jupyter notebook detailing EDA, (2) Python prediction API scripts, (3) A model pickle binary, (4) Model audit graphs showing ROC score > 0.85.',
    ),
    Project(
      id: 'proj_ds_2',
      name: 'Dynamic Real Estate Price Predictor',
      difficulty: 'Beginner',
      duration: '6 hours',
      requiredSkills: ['Python', 'NumPy', 'Matplotlib', 'Linear Regression'],
      xpReward: 400,
      coinsReward: 40,
      portfolioValue: 'High',
      imageGradientStart: '0xFF3E2723',
      imageGradientEnd: '0xFF1B0000',
      icon: '🏡',
      overview: 'Learn basic machine learning mechanics by building a linear model to predict house valuation from square footage.',
      problemStatement: 'Sellers list homes with arbitrary values, creating massive market inefficiency. We need a mathematical model matching regional price averages.',
      whatYouWillBuild: 'A clean univariate regression model drawing visual scatterplots mapping property size to projected pricing.',
      techStack: ['Python', 'NumPy', 'Matplotlib', 'Scikit-Learn'],
      prerequisites: ['Basic high school algebra', 'Python list loops'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'NumPy Quickstart API', url: 'https://numpy.org'),
        ProjectResource(type: 'video', name: 'Linear Regression visual equations', url: 'https://youtube.com'),
      ],
      milestones: _defaultMilestones,
      expectedOutput: 'A single script loading property lists, fitting regression slopes, and outputting price valuations with Mean Squared Error scores.',
    ),
  ],
  'uxDesigner': [
    Project(
      id: 'proj_ux_1',
      name: 'Neobank Wallet App Case Study',
      difficulty: 'Intermediate',
      duration: '15 hours',
      requiredSkills: ['Figma', 'Wireframing', 'User Interviews', 'Prototyping'],
      xpReward: 1000,
      coinsReward: 90,
      portfolioValue: 'Crucial',
      imageGradientStart: '0xFF1E2837',
      imageGradientEnd: '0xFF0B111A',
      icon: '💳',
      overview: 'Run UX research and design interactive high-fidelity frames for a banking app dedicated to Gen-Z customers.',
      problemStatement: 'Gen-Z users find legacy banking apps intimidating, complicated, and slow. They require simple micro-savings features, zero transaction friction, and gamified budget tracking.',
      whatYouWillBuild: 'An end-to-end case study detailing: UX Persona studies, paper wireframe sketches, dynamic Figma component design systems, and an interactive prototype link.',
      techStack: ['Figma', 'FigJam', 'Miro', 'Adobe Illustrator'],
      prerequisites: ['Figma Auto Layout mastery', 'Cognitive psychology basic principles'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'Figma Prototyping Interactions Guide', url: 'https://help.figma.com'),
        ProjectResource(type: 'video', name: 'Building UX Case Studies (The Futur)', url: 'https://youtube.com'),
      ],
      milestones: _defaultMilestones,
      expectedOutput: 'A Behance/Medium case study link showcasing: (1) Research insights map, (2) User flow journey, (3) 8 High-fidelity designed interactive screens, (4) Figma prototyping link showing micro-animations.',
    ),
    Project(
      id: 'proj_ux_2',
      name: 'E-Commerce Cart Conversion Audit',
      difficulty: 'Beginner',
      duration: '8 hours',
      requiredSkills: ['Heuristic Evaluation', 'Wireframing', 'Figma'],
      xpReward: 500,
      coinsReward: 45,
      portfolioValue: 'High',
      imageGradientStart: '0xFF3E1F47',
      imageGradientEnd: '0xFF1E0A24',
      icon: '🛒',
      overview: 'Audit a checkout process using Nielsen\'s heuristics and re-design wireframes solving conversion bottlenecks.',
      problemStatement: 'Cart abandonment reaches 72% on mobile web stores due to forced registration and complex payment forms.',
      whatYouWillBuild: 'A design presentation proposing single-page guest checkouts and visual progress indicators.',
      techStack: ['Figma', 'Google Slides / Canva'],
      prerequisites: ['Nielsen\'s 10 Usability Heuristics understanding'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'Nielsen Norman Usability Heuristics', url: 'https://nngroup.com'),
      ],
      milestones: _defaultMilestones,
      expectedOutput: 'A PDF audit presentation deck detailing checkout flaws, and a before/after wireframe side-by-side design comparison.',
    ),
  ],
  'aiEngineer': [
    Project(
      id: 'proj_ai_1',
      name: 'Multimodal RAG Knowledge Assistant',
      difficulty: 'Advanced',
      duration: '25 hours',
      requiredSkills: ['Python', 'LangChain', 'VectorDB (Chroma)', 'Gemini API'],
      xpReward: 1200,
      coinsReward: 100,
      portfolioValue: 'Crucial',
      imageGradientStart: '0xFF1C2237',
      imageGradientEnd: '0xFF0C0E1A',
      icon: '🧠',
      overview: 'Build a system that parses pdf guidelines, indexes vector segments, and answers natural language queries with citations.',
      problemStatement: 'Manual parsing of company documentation consumes hours of analyst work. We need an autonomous AI assistant reading both text and diagram schematics instantly.',
      whatYouWillBuild: 'An indexer pipeline extracting layout segments, storing embeddings inside a local vector db, and running inference through LangChain.',
      techStack: ['Python', 'LangChain', 'ChromaDB', 'Gemini API', 'PyPDF'],
      prerequisites: ['Python intermediate OOP', 'Understand API keys & environment variables'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'LangChain Retrieval Docs', url: 'https://js.langchain.com'),
        ProjectResource(type: 'video', name: 'Vector databases explained simply', url: 'https://youtube.com'),
      ],
      milestones: _defaultMilestones,
      expectedOutput: 'A complete GitHub repo hosting the indexing CLI scripts, Chroma DB integration code, and a chat interface script giving answers with matched source documents.',
    ),
    Project(
      id: 'proj_ai_2',
      name: 'Neural Network Optimizer from Scratch',
      difficulty: 'Intermediate',
      duration: '15 hours',
      requiredSkills: ['Python', 'NumPy', 'Calculus', 'Matrix Multiplications'],
      xpReward: 900,
      coinsReward: 80,
      portfolioValue: 'High',
      imageGradientStart: '0xFF3A1F1F',
      imageGradientEnd: '0xFF1B0C0C',
      icon: '🧮',
      overview: 'Understand model training mechanics by building a dense neural network layer using pure NumPy matrix math.',
      problemStatement: 'Relying exclusively on high-level APIs (Keras, PyTorch) creates engineers who cannot optimize low-level tensor compilers.',
      whatYouWillBuild: 'A Python class structure mapping nodes, weights, bias parameters, sigmoid activation, and custom backpropagation.',
      techStack: ['Python', 'NumPy'],
      prerequisites: ['Linear Algebra (Dot Product)', 'Derivative calculus rules'],
      resources: const [
        ProjectResource(type: 'documentation', name: 'Calculus derivatives cheat sheet', url: 'https://mathworld.wolfram.com'),
      ],
      milestones: _defaultMilestones,
      expectedOutput: 'A raw Python file validating training loops, showing learning loss curves decreasing over 500 epochs.',
    ),
  ],
};

// Helper career resolver
List<Project> _getCareerMockList(String career) {
  return _mockProjectsByCareer[career] ?? _mockProjectsByCareer['aiEngineer']!;
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECTS STATE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final Ref _ref;

  ProjectsNotifier(this._ref) : super(const ProjectsState()) {
    loadProjectsData();
  }

  Future<void> loadProjectsData() async {
    state = state.copyWith(isLoading: true);
    final career = _ref.read(profileProvider).readingGoal.name;

    try {
      final careerSlug = career.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );

      final response = await apiClient.get('/projects?career=$careerSlug');
      final list = (response as List)
          .map((item) => Project.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      state = state.copyWith(projects: list, isLoading: false);
    } catch (_) {
      // Graceful fallback to career-specific mock data
      final fallbacks = _getCareerMockList(career);

      // Load bookmark/progress from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final List<Project> hydrated = [];

      for (final p in fallbacks) {
        final status = prefs.getString('proj_status_${p.id}') ?? 'not_started';
        
        final List<ProjectMilestone> updatedMilestones = [];
        bool previousCompleted = true; // The first milestone is unlocked by default

        for (int i = 0; i < p.milestones.length; i++) {
          final m = p.milestones[i];
          final completed = prefs.getBool('proj_${p.id}_mile_${m.id}_comp') ?? false;
          final unlocked = i == 0 || previousCompleted;
          
          updatedMilestones.add(m.copyWith(
            isCompleted: completed,
            isUnlocked: unlocked,
          ));

          previousCompleted = completed;
        }

        hydrated.add(p.copyWith(
          status: status,
          milestones: updatedMilestones,
        ));
      }

      state = state.copyWith(projects: hydrated, isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadProjectsData();
  }

  Future<void> startProject(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('proj_status_$projectId', 'in_progress');

    final updated = state.projects.map((p) {
      if (p.id == projectId) {
        return p.copyWith(status: 'in_progress');
      }
      return p;
    }).toList();

    state = state.copyWith(projects: updated);

    // Seed initial mentor greetings
    _seedMentorGreetings(projectId);
  }

  void _seedMentorGreetings(String id) {
    final project = state.projects.firstWhere((p) => p.id == id);
    final greeting = MentorMessage(
      sender: 'mentor',
      text: 'Hello! I am your AI Mentor for "${project.name}". 🤖\n\n'
          'I\'ve broken this project down into ${project.milestones.length} milestones.\n'
          'Your first task is "${project.milestones.first.name}". Let me know if you need setup guides or hints to get started!',
      timestamp: DateTime.now(),
    );

    final chats = Map<String, List<MentorMessage>>.from(state.projectMentorChats);
    chats[id] = [greeting];
    state = state.copyWith(projectMentorChats: chats);
  }

  Future<void> completeMilestone(String projectId, String milestoneId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completion state locally
    await prefs.setBool('proj_${projectId}_mile_${milestoneId}_comp', true);

    Project? updatedProject;
    final list = state.projects.map((p) {
      if (p.id == projectId) {
        // Complete current milestone & unlock next milestone
        final List<ProjectMilestone> updatedMiles = [];
        bool previousCompleted = true;
        
        for (int i = 0; i < p.milestones.length; i++) {
          final m = p.milestones[i];
          bool isCompleted = m.id == milestoneId ? true : m.isCompleted;
          bool isUnlocked = i == 0 || previousCompleted;

          updatedMiles.add(m.copyWith(
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
          ));

          previousCompleted = isCompleted;
        }

        // Check if all milestones are completed -> project complete
        final allDone = updatedMiles.every((m) => m.isCompleted);
        final status = allDone ? 'completed' : 'in_progress';
        if (allDone) {
          prefs.setString('proj_status_$projectId', 'completed');
        }

        final nextProj = p.copyWith(
          status: status,
          milestones: updatedMiles,
        );

        updatedProject = nextProj;
        return nextProj;
      }
      return p;
    }).toList();

    state = state.copyWith(projects: list);

    // Award rewards of the milestone
    if (updatedProject != null) {
      final currentMilestone = updatedProject!.milestones.firstWhere((m) => m.id == milestoneId);
      
      // Award XP
      await _ref.read(xpProvider.notifier).addXp(currentMilestone.xpGained);

      // Award Coins
      final currentCoins = prefs.getInt('user_coins') ?? 100;
      await prefs.setInt('user_coins', currentCoins + currentMilestone.coinsGained);

      // Trigger standard AI Mentor notification of next step
      final nextMileIndex = updatedProject!.milestones.indexWhere((m) => m.id == milestoneId) + 1;
      if (nextMileIndex < updatedProject!.milestones.length) {
        final nextMilestone = updatedProject!.milestones[nextMileIndex];
        _sendMentorSystemAlert(
          projectId,
          'Awesome! You completed "${currentMilestone.name}" (+${currentMilestone.xpGained} XP, +${currentMilestone.coinsGained} Coins).\n\n'
          'The next milestone is now unlocked: "${nextMilestone.name}". Here is what you need to do:\n${nextMilestone.description}',
        );
      } else {
        _sendMentorSystemAlert(
          projectId,
          'Congratulations! 🎉 You completed the final milestone and finished the entire project!\n\n'
          'Your portfolio value is officially set to: ${updatedProject!.portfolioValue}.\n'
          'Make sure to push your code to GitHub and add this to your CV.',
        );
      }
    }
  }

  void _sendMentorSystemAlert(String projectId, String text) {
    final chats = Map<String, List<MentorMessage>>.from(state.projectMentorChats);
    final list = List<MentorMessage>.from(chats[projectId] ?? []);
    list.add(MentorMessage(
      sender: 'mentor',
      text: text,
      timestamp: DateTime.now(),
    ));
    chats[projectId] = list;
    state = state.copyWith(projectMentorChats: chats);
  }

  Future<void> sendMentorMessage(String projectId, String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = MentorMessage(sender: 'user', text: text, timestamp: DateTime.now());
    final chats = Map<String, List<MentorMessage>>.from(state.projectMentorChats);
    final chatList = List<MentorMessage>.from(chats[projectId] ?? []);
    chatList.add(userMsg);
    chats[projectId] = chatList;
    state = state.copyWith(projectMentorChats: chats, isSendingMessage: true);

    // Simulate AI Mentor typing/reply delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Get current project milestone/context to generate smart responses
    final project = state.projects.firstWhere((p) => p.id == projectId);
    final activeMilestone = project.milestones.firstWhere(
      (m) => !m.isCompleted,
      orElse: () => project.milestones.last,
    );

    String responseText = '';
    final query = text.toLowerCase();

    if (query.contains('code') || query.contains('review') || query.contains('error')) {
      responseText = 'Here is a quick code review/hint for you. 🛠️\n\n'
          'Since you are currently in the "${activeMilestone.name}" stage, check that your variables are correctly instantiated and all dependencies in your tech stack (${project.techStack.join(', ')}) are initialized.\n\n'
          'Tip: Avoid hardcoding configuration paths. Set up environment config variables.';
    } else if (query.contains('hint') || query.contains('help')) {
      responseText = 'No problem! Here is a hint for "${activeMilestone.name}":\n\n'
          '${activeMilestone.description}\n\n'
          'Make sure you read the official references in the details page documentation. Let me know if you need specific step guidance!';
    } else if (query.contains('next') || query.contains('milestone')) {
      responseText = 'Your current milestone is: "${activeMilestone.name}".\n\n'
          'To unlock the next step, complete this checklist:\n'
          '• ${activeMilestone.description}\n\n'
          'Once completed, tap "Complete Milestone" on the project page to claim your rewards!';
    } else {
      responseText = 'Got it! Regarding "${project.name}", here is what you should focus on:\n\n'
          'For the active milestone "${activeMilestone.name}", make sure you follow the problem statement guidelines:\n'
          '"${project.problemStatement.substring(0, project.problemStatement.length > 100 ? 100 : project.problemStatement.length)}..."\n\n'
          'Ask me any specific questions about set-up, coding patterns, or unit testing!';
    }

    final mentorMsg = MentorMessage(sender: 'mentor', text: responseText, timestamp: DateTime.now());
    chatList.add(mentorMsg);
    chats[projectId] = chatList;
    state = state.copyWith(projectMentorChats: chats, isSendingMessage: false);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER EXPORT
// ─────────────────────────────────────────────────────────────────────────────

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ref);
});

// Helper detail lookup
Project? findProjectById(String id, List<Project> projects) {
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    for (final list in _mockProjectsByCareer.values) {
      for (final p in list) {
        if (p.id == id) return p;
      }
    }
  }
  return null;
}
