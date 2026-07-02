import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';
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
    final text = j['name'] ?? j['text'] ?? '';
    return ProjectMilestone(
      id: j['id']?.toString() ?? '',
      name: text,
      description: j['description'] ?? text,
      isCompleted: j['is_completed'] ?? false,
      xpGained: (j['xp_gained'] as num?)?.toInt() ?? (j['xp_reward'] as num?)?.toInt() ?? 150,
      coinsGained: (j['coins_gained'] as num?)?.toInt() ?? (j['coins_reward'] as num?)?.toInt() ?? 15,
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
    final status = j['status']?.toString() ?? 'not_started';
    return Project(
      id: j['id']?.toString() ?? '',
      name: j['name'] ?? '',
      difficulty: j['difficulty'] ?? 'Intermediate',
      duration: j['duration'] ?? '10 hours',
      requiredSkills: List<String>.from(j['required_skills'] ?? j['skills'] ?? []),
      xpReward: j['xp_reward'] ?? 500,
      coinsReward: j['coins_reward'] ?? 50,
      portfolioValue: j['portfolio_value'] ?? 'High',
      status: status == 'unstarted' ? 'not_started' : status,
      imageGradientStart: j['gradient_start'] ?? '0xFF1A1F3C',
      imageGradientEnd: j['gradient_end'] ?? '0xFF0D0F1F',
      icon: j['icon'] ?? '🚀',
      overview: j['overview'] ?? j['problem_statement'] ?? '',
      problemStatement: j['problem_statement'] ?? '',
      whatYouWillBuild: j['what_you_will_build'] ?? j['what_you_build'] ?? '',
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


class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final Ref _ref;

  ProjectsNotifier(this._ref) : super(const ProjectsState()) {
    loadProjectsData();
  }

  Future<void> loadProjectsData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final careerSlug = readingGoalToSlug(_ref.read(profileProvider).readingGoal);

    try {
      final response = await apiClient.get('${ApiConstants.projects}?career=$careerSlug');
      final list = (response as List)
          .map((item) => Project.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      state = state.copyWith(projects: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load projects.');
    }
  }

  Future<void> refresh() async {
    await loadProjectsData();
  }

  Future<void> startProject(String projectId) async {
    final updated = state.projects.map((p) {
      if (p.id == projectId) {
        return p.copyWith(status: 'in_progress');
      }
      return p;
    }).toList();

    state = state.copyWith(projects: updated);
    _seedMentorGreetings(projectId);
  }

  void _seedMentorGreetings(String id) {
    final project = state.projects.firstWhere((p) => p.id == id);
    if (project.milestones.isEmpty) return;
    final greeting = MentorMessage(
      sender: 'mentor',
      text: 'Hello! I am your AI Mentor for "${project.name}".\n\n'
          'Your first task is "${project.milestones.first.name}". Let me know if you need setup guides or hints!',
      timestamp: DateTime.now(),
    );

    final chats = Map<String, List<MentorMessage>>.from(state.projectMentorChats);
    chats[id] = [greeting];
    state = state.copyWith(projectMentorChats: chats);
  }

  Future<void> completeMilestone(String projectId, String milestoneId) async {
    try {
      final result = await apiClient.post(
        '${ApiConstants.projects}/$projectId/milestones/complete',
        body: {'milestone_id': milestoneId},
      );
      final updatedProject = Project.fromJson(Map<String, dynamic>.from(result));
      final list = state.projects.map((p) => p.id == projectId ? updatedProject : p).toList();
      state = state.copyWith(projects: list);
      await _ref.read(xpProvider.notifier).refreshFromBackend();
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  Future<void> sendMentorMessage(String projectId, String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = MentorMessage(sender: 'user', text: text, timestamp: DateTime.now());
    final chats = Map<String, List<MentorMessage>>.from(state.projectMentorChats);
    final chatList = List<MentorMessage>.from(chats[projectId] ?? []);
    chatList.add(userMsg);
    chats[projectId] = chatList;
    state = state.copyWith(projectMentorChats: chats, isSendingMessage: true);

    try {
      final chatResp = await apiClient.post(
        '${ApiConstants.projects}/$projectId/mentor/chat',
        body: {'message': text},
      );
      final reply = chatResp['reply']?.toString() ?? '';
      chatList.add(MentorMessage(sender: 'mentor', text: reply, timestamp: DateTime.now()));
      chats[projectId] = chatList;
      state = state.copyWith(projectMentorChats: chats, isSendingMessage: false);
    } on ApiException catch (e) {
      chatList.add(MentorMessage(
        sender: 'mentor',
        text: e.message,
        timestamp: DateTime.now(),
      ));
      chats[projectId] = chatList;
      state = state.copyWith(projectMentorChats: chats, isSendingMessage: false, errorMessage: e.message);
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ref);
});

Project? findProjectById(String id, List<Project> projects) {
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
