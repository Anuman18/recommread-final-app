import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_client.dart';
import '../core/utils/career_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class DailyMission {
  final String id;
  final String title;
  final String difficulty;
  final int timeMin;
  final int xpReward;
  final int coinsReward;
  final double progress;
  final bool isPrimary;
  final String icon;

  const DailyMission({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.timeMin,
    required this.xpReward,
    required this.coinsReward,
    required this.progress,
    this.isPrimary = false,
    this.icon = '📚',
  });

  factory DailyMission.fromJson(Map<String, dynamic> j) => DailyMission(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        difficulty: j['difficulty'] ?? 'Intermediate',
        timeMin: j['time_min'] ?? 20,
        xpReward: j['xp_reward'] ?? j['xp'] ?? 150,
        coinsReward: j['coins_reward'] ?? 10,
        progress: (j['progress'] ?? 0.0).toDouble(),
        isPrimary: j['is_primary'] ?? false,
        icon: j['icon'] ?? '📚',
      );

  factory DailyMission.fromDashboardMission(Map<String, dynamic> j, {bool isPrimary = false}) =>
      DailyMission(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        difficulty: 'Intermediate',
        timeMin: 20,
        xpReward: (j['xp'] as num?)?.toInt() ?? 150,
        coinsReward: 10,
        progress: j['claimed'] == true ? 1.0 : 0.0,
        isPrimary: isPrimary,
        icon: '🎯',
      );
}

class LearningResource {
  final String id;
  final String title;
  final String source;
  final String type;
  final String difficulty;
  final int timeMin;
  final int xp;
  final String url;
  final bool isBookmarked;
  final String? thumbnailColor;
  final String icon;

  const LearningResource({
    required this.id,
    required this.title,
    required this.source,
    required this.type,
    required this.difficulty,
    required this.timeMin,
    required this.xp,
    required this.url,
    this.isBookmarked = false,
    this.thumbnailColor,
    this.icon = '📖',
  });

  LearningResource copyWith({
    bool? isBookmarked,
  }) {
    return LearningResource(
      id: id,
      title: title,
      source: source,
      type: type,
      difficulty: difficulty,
      timeMin: timeMin,
      xp: xp,
      url: url,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      thumbnailColor: thumbnailColor,
      icon: icon,
    );
  }

  factory LearningResource.fromJson(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? j['type'] as String? ?? 'course';
    return LearningResource(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      source: j['source'] ?? j['provider'] ?? category,
      type: category.toLowerCase(),
      difficulty: j['difficulty'] ?? 'Intermediate',
      timeMin: j['time_min'] ?? j['estimated_learning_time_min'] ?? 30,
      xp: j['xp'] ?? j['xp_reward'] ?? 100,
      url: j['url'] ?? '',
      isBookmarked: j['is_bookmarked'] ?? false,
      thumbnailColor: j['thumbnail_color'],
      icon: j['icon'] ?? '📖',
    );
  }
}

class SkillData {
  final String name;
  final int level;
  final int xp;
  final double progress;
  final double weeklyGrowth;
  final String icon;

  const SkillData({
    required this.name,
    required this.level,
    required this.xp,
    required this.progress,
    required this.weeklyGrowth,
    this.icon = '⚡',
  });

  factory SkillData.fromJson(Map<String, dynamic> j) => SkillData(
        name: j['name'] ?? '',
        level: j['level'] ?? 1,
        xp: j['xp'] ?? 0,
        progress: (j['progress'] ?? 0.0).toDouble(),
        weeklyGrowth: (j['weekly_growth'] ?? 0.0).toDouble(),
        icon: j['icon'] ?? '⚡',
      );

  factory SkillData.fromSkillName(String name, {bool isStrong = true}) => SkillData(
        name: name,
        level: isStrong ? 3 : 1,
        xp: isStrong ? 800 : 200,
        progress: isStrong ? 0.7 : 0.3,
        weeklyGrowth: isStrong ? 8.0 : -5.0,
        icon: isStrong ? '💪' : '⚠️',
      );
}

class WeeklyStats {
  final double learningHours;
  final int completedMissions;
  final int codingQuestions;
  final int projects;
  final int xpEarned;

  const WeeklyStats({
    this.learningHours = 0,
    this.completedMissions = 0,
    this.codingQuestions = 0,
    this.projects = 0,
    this.xpEarned = 0,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> j) => WeeklyStats(
        learningHours: (j['learning_hours'] ?? 0).toDouble(),
        completedMissions: j['completed_missions'] ?? 0,
        codingQuestions: j['completed_coding_questions'] ?? j['coding_questions'] ?? 0,
        projects: j['completed_projects'] ?? j['projects'] ?? 0,
        xpEarned: j['xp'] ?? j['xp_earned'] ?? 0,
      );
}

class Milestone {
  final String id;
  final String title;
  final String emoji;
  final int current;
  final int target;
  final String status;

  const Milestone({
    required this.id,
    required this.title,
    required this.emoji,
    required this.current,
    required this.target,
    required this.status,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0.0, 1.0);

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? j['phase_title'] ?? '',
        emoji: j['emoji'] ?? '🎯',
        current: j['current'] ?? j['order'] ?? 0,
        target: j['target'] ?? 10,
        status: j['status'] ?? 'in_progress',
      );
}

class AiRecommendation {
  final String message;
  final String type;
  final String icon;
  final String? ctaLabel;

  const AiRecommendation({
    required this.message,
    required this.type,
    this.icon = '🤖',
    this.ctaLabel,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> j) => AiRecommendation(
        message: j['message'] ?? '',
        type: j['type'] ?? 'suggest',
        icon: j['icon'] ?? '🤖',
        ctaLabel: j['cta_label'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class HomeState {
  final List<DailyMission> missions;
  final LearningResource? continueResource;
  final List<LearningResource> learningResources;
  final List<SkillData> skills;
  final WeeklyStats weeklyStats;
  final List<Milestone> milestones;
  final List<AiRecommendation> aiRecommendations;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.missions = const [],
    this.continueResource,
    this.learningResources = const [],
    this.skills = const [],
    this.weeklyStats = const WeeklyStats(),
    this.milestones = const [],
    this.aiRecommendations = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  bool get isEmpty =>
      !isLoading &&
      errorMessage == null &&
      missions.isEmpty &&
      learningResources.isEmpty;

  HomeState copyWith({
    List<DailyMission>? missions,
    LearningResource? continueResource,
    bool clearContinueResource = false,
    List<LearningResource>? learningResources,
    List<SkillData>? skills,
    WeeklyStats? weeklyStats,
    List<Milestone>? milestones,
    List<AiRecommendation>? aiRecommendations,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      missions: missions ?? this.missions,
      continueResource: clearContinueResource ? null : (continueResource ?? this.continueResource),
      learningResources: learningResources ?? this.learningResources,
      skills: skills ?? this.skills,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      milestones: milestones ?? this.milestones,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData({String career = 'aiEngineer'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final careerSlug = careerToSlug(career);

      final dashboard = await apiClient.get(ApiConstants.profileDashboard);
      final dashboardMap = Map<String, dynamic>.from(dashboard as Map);

      final dailyMissionsRaw = dashboardMap['daily_missions'] as List? ?? [];
      final missions = dailyMissionsRaw
          .asMap()
          .entries
          .map((e) => DailyMission.fromDashboardMission(
                Map<String, dynamic>.from(e.value),
                isPrimary: e.key == 0,
              ))
          .toList();

      final resourcesJson = await apiClient.get('${ApiConstants.resources}?career=$careerSlug');
      final resources = (resourcesJson as List)
          .map((r) => LearningResource.fromJson(Map<String, dynamic>.from(r)))
          .toList();

      final strongSkillsJson = await apiClient.get(ApiConstants.recommendationsStrongSkills);
      final weakSkillsJson = await apiClient.get(ApiConstants.recommendationsWeakSkills);
      final strongSkills = (strongSkillsJson as List).cast<String>();
      final weakSkills = (weakSkillsJson as List).cast<String>();

      final skills = [
        ...strongSkills.map((s) => SkillData.fromSkillName(s, isStrong: true)),
        ...weakSkills.map((s) => SkillData.fromSkillName(s, isStrong: false)),
      ];

      final statsJson = await apiClient.get(ApiConstants.gamificationStatistics);
      final weeklyStats = WeeklyStats.fromJson(Map<String, dynamic>.from(statsJson));

      final pathJson = await apiClient.get(ApiConstants.recommendationsLearningPath);
      final pathMap = Map<String, dynamic>.from(pathJson as Map);
      final roadmaps = pathMap['roadmaps'] as List? ?? [];
      final milestones = roadmaps
          .asMap()
          .entries
          .map((e) {
            final rm = Map<String, dynamic>.from(e.value);
            return Milestone(
              id: 'phase_${e.key}',
              title: rm['phase_title']?.toString() ?? 'Phase ${e.key + 1}',
              emoji: '🗺️',
              current: (rm['order'] as num?)?.toInt() ?? e.key,
              target: roadmaps.length,
              status: e.key == 0 ? 'in_progress' : 'locked',
            );
          })
          .toList();

      final dailyRecJson = await apiClient.get(ApiConstants.recommendationsDaily);
      final dailyMap = Map<String, dynamic>.from(dailyRecJson as Map);
      final aiRecs = <AiRecommendation>[];

      if (dailyMap['ai_tutor_tip'] != null) {
        aiRecs.add(AiRecommendation(
          message: dailyMap['ai_tutor_tip'].toString(),
          type: 'suggest',
          icon: '🤖',
        ));
      }
      if (dailyMap['intensity'] != null) {
        aiRecs.add(AiRecommendation(
          message: 'Today\'s intensity: ${dailyMap['intensity']}',
          type: 'encourage',
          icon: '🔥',
        ));
      }
      if (dailyMap['streak_modifier'] != null) {
        aiRecs.add(AiRecommendation(
          message: dailyMap['streak_modifier'].toString(),
          type: 'celebrate',
          icon: '⭐',
        ));
      }

      LearningResource? continueResource;
      for (final r in resources) {
        if (!r.isBookmarked) {
          continueResource = r;
          break;
        }
      }
      continueResource ??= resources.isNotEmpty ? resources.first : null;

      state = HomeState(
        missions: missions,
        continueResource: continueResource,
        learningResources: resources,
        skills: skills,
        weeklyStats: weeklyStats,
        milestones: milestones,
        aiRecommendations: aiRecs,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load home data.',
      );
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
