import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class AgendaItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int xpReward;
  final bool completed;

  const AgendaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.xpReward,
    this.completed = false,
  });

  AgendaItem copyWith({bool? completed}) => AgendaItem(
        id: id,
        title: title,
        subtitle: subtitle,
        icon: icon,
        xpReward: xpReward,
        completed: completed ?? this.completed,
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;
  final double progress;
  final String progressLabel;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlocked = false,
    this.progress = 0.0,
    this.progressLabel = '',
  });
}

class DailyReward {
  final String id;
  final String title;
  final String emoji;
  final int xp;
  final bool claimed;

  const DailyReward({
    required this.id,
    required this.title,
    required this.emoji,
    required this.xp,
    this.claimed = false,
  });

  DailyReward copyWith({bool? claimed}) => DailyReward(
        id: id,
        title: title,
        emoji: emoji,
        xp: xp,
        claimed: claimed ?? this.claimed,
      );
}

class LifeDashboardState {
  final List<AgendaItem> agenda;
  final List<Achievement> achievements;
  final List<DailyReward> dailyRewards;
  final int weeklyXp;
  final int monthlyXp;
  final double weeklyHours;
  final double monthlyHours;
  final int weeklyMissions;
  final int monthlyMissions;
  final List<int> weeklyXpChart;
  final List<int> monthlyXpChart;
  final String bestCategory;
  final String weakestSkill;
  final String nextRecommendation;
  final Map<String, dynamic> dailyRecommendations;
  final bool isLoaded;
  final bool isLoading;
  final String? errorMessage;

  const LifeDashboardState({
    this.agenda = const [],
    this.achievements = const [],
    this.dailyRewards = const [],
    this.weeklyXp = 0,
    this.monthlyXp = 0,
    this.weeklyHours = 0,
    this.monthlyHours = 0,
    this.weeklyMissions = 0,
    this.monthlyMissions = 0,
    this.weeklyXpChart = const [],
    this.monthlyXpChart = const [],
    this.bestCategory = '',
    this.weakestSkill = '',
    this.nextRecommendation = '',
    this.dailyRecommendations = const {},
    this.isLoaded = false,
    this.isLoading = true,
    this.errorMessage,
  });

  LifeDashboardState copyWith({
    List<AgendaItem>? agenda,
    List<Achievement>? achievements,
    List<DailyReward>? dailyRewards,
    int? weeklyXp,
    int? monthlyXp,
    double? weeklyHours,
    double? monthlyHours,
    int? weeklyMissions,
    int? monthlyMissions,
    List<int>? weeklyXpChart,
    List<int>? monthlyXpChart,
    String? bestCategory,
    String? weakestSkill,
    String? nextRecommendation,
    Map<String, dynamic>? dailyRecommendations,
    bool? isLoaded,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LifeDashboardState(
      agenda: agenda ?? this.agenda,
      achievements: achievements ?? this.achievements,
      dailyRewards: dailyRewards ?? this.dailyRewards,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      monthlyXp: monthlyXp ?? this.monthlyXp,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      monthlyHours: monthlyHours ?? this.monthlyHours,
      weeklyMissions: weeklyMissions ?? this.weeklyMissions,
      monthlyMissions: monthlyMissions ?? this.monthlyMissions,
      weeklyXpChart: weeklyXpChart ?? this.weeklyXpChart,
      monthlyXpChart: monthlyXpChart ?? this.monthlyXpChart,
      bestCategory: bestCategory ?? this.bestCategory,
      weakestSkill: weakestSkill ?? this.weakestSkill,
      nextRecommendation: nextRecommendation ?? this.nextRecommendation,
      dailyRecommendations: dailyRecommendations ?? this.dailyRecommendations,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LifeDashboardNotifier extends StateNotifier<LifeDashboardState> {
  LifeDashboardNotifier() : super(const LifeDashboardState()) {
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashboard = await apiClient.get(ApiConstants.profileDashboard);
      final stats = await apiClient.get(ApiConstants.gamificationStatistics);
      final achievementsJson = await apiClient.get(ApiConstants.gamificationAchievements);
      final weakSkillsJson = await apiClient.get(ApiConstants.recommendationsWeakSkills);
      final strongSkillsJson = await apiClient.get(ApiConstants.recommendationsStrongSkills);
      final dailyRec = await apiClient.get(ApiConstants.recommendationsDaily);
      final streakJson = await apiClient.get(ApiConstants.gamificationStreak);

      final dashboardMap = Map<String, dynamic>.from(dashboard as Map);
      final statsMap = Map<String, dynamic>.from(stats as Map);
      final dailyMap = Map<String, dynamic>.from(dailyRec as Map);

      final missions = (dashboardMap['daily_missions'] as List? ?? [])
          .asMap()
          .entries
          .map((e) {
            final m = Map<String, dynamic>.from(e.value);
            return AgendaItem(
              id: m['id']?.toString() ?? 'm_${e.key}',
              title: m['title']?.toString() ?? '',
              subtitle: 'Daily mission',
              icon: '🎯',
              xpReward: (m['xp'] as num?)?.toInt() ?? 150,
              completed: m['claimed'] == true,
            );
          })
          .toList();

      final achievements = (achievementsJson as List)
          .map((a) {
            final map = Map<String, dynamic>.from(a);
            return Achievement(
              id: map['slug']?.toString() ?? '',
              title: map['title']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
              emoji: map['icon']?.toString() ?? '🏆',
              unlocked: true,
              progress: 1.0,
              progressLabel: 'Unlocked',
            );
          })
          .toList();

      final streak = (streakJson['daily_streak'] as num?)?.toInt() ?? 0;
      final dailyRewards = [
        DailyReward(
          id: 'login',
          title: 'Daily Login Bonus',
          emoji: '🌟',
          xp: 100,
          claimed: streak > 0,
        ),
        DailyReward(
          id: 'streak',
          title: 'Streak Bonus',
          emoji: '🔥',
          xp: 250,
          claimed: streak >= 7,
        ),
      ];

      final weakSkills = (weakSkillsJson as List).cast<String>();
      final strongSkills = (strongSkillsJson as List).cast<String>();

      state = LifeDashboardState(
        agenda: missions,
        achievements: achievements,
        dailyRewards: dailyRewards,
        weeklyXp: (statsMap['xp'] as num?)?.toInt() ?? 0,
        monthlyXp: ((statsMap['xp'] as num?)?.toInt() ?? 0) * 4,
        weeklyHours: (statsMap['learning_hours'] as num?)?.toDouble() ?? 0,
        monthlyHours: ((statsMap['learning_hours'] as num?)?.toDouble() ?? 0) * 4,
        weeklyMissions: (statsMap['completed_missions'] as num?)?.toInt() ?? 0,
        monthlyMissions: ((statsMap['completed_missions'] as num?)?.toInt() ?? 0) * 4,
        weeklyXpChart: List.generate(7, (i) => ((statsMap['xp'] as num?)?.toInt() ?? 0) ~/ 7),
        monthlyXpChart: List.generate(4, (i) => ((statsMap['xp'] as num?)?.toInt() ?? 0) ~/ 4),
        bestCategory: strongSkills.isNotEmpty ? strongSkills.first : '',
        weakestSkill: weakSkills.isNotEmpty ? weakSkills.first : '',
        nextRecommendation: dailyMap['ai_tutor_tip']?.toString() ?? '',
        dailyRecommendations: dailyMap,
        isLoaded: true,
        isLoading: false,
      );
      
      // Track impression automatically on load
      trackRecommendation('view', 'dashboard', 'daily_recommendations');
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, isLoaded: true, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoaded: true,
        errorMessage: 'Failed to load life dashboard.',
      );
    }
  }

  Future<void> trackRecommendation(String eventType, String itemType, String itemId) async {
    try {
      await apiClient.post(
        '/api/v1/recommendations/track',
        body: {
          'event_type': eventType,
          'item_type': itemType,
          'item_id': itemId,
        },
      );
    } catch (_) {}
  }

  Future<void> toggleAgendaItem(String id) async {
    final updated = state.agenda.map((a) {
      if (a.id == id) {
        return a.copyWith(completed: !a.completed);
      }
      return a;
    }).toList();
    state = state.copyWith(agenda: updated);
  }

  Future<void> claimReward(String id) async {
    try {
      await apiClient.post(
        ApiConstants.gamificationClaimReward,
        body: {
          'reward_source': id,
          'xp_reward': 100,
          'coins_reward': 10,
        },
      );
      final updated = state.dailyRewards.map((r) {
        if (r.id == id && !r.claimed) {
          return r.copyWith(claimed: true);
        }
        return r;
      }).toList();
      state = state.copyWith(dailyRewards: updated);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  Future<void> refresh() async {
    await _loadFromBackend();
  }
}

final lifeDashboardProvider =
    StateNotifierProvider<LifeDashboardNotifier, LifeDashboardState>(
  (ref) => LifeDashboardNotifier(),
);
