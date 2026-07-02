import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Agenda Item ───────────────────────────────────────────────────────────────

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

  AgendaItem copyWith({bool? completed}) =>
      AgendaItem(id: id, title: title, subtitle: subtitle, icon: icon, xpReward: xpReward, completed: completed ?? this.completed);
}

// ── Achievement ───────────────────────────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;
  final double progress; // 0.0 - 1.0
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

// ── Daily Reward ──────────────────────────────────────────────────────────────

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

  DailyReward copyWith({bool? claimed}) =>
      DailyReward(id: id, title: title, emoji: emoji, xp: xp, claimed: claimed ?? this.claimed);
}

// ── Life Dashboard State ──────────────────────────────────────────────────────

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
  final List<int> weeklyXpChart; // 7 day XP per day
  final List<int> monthlyXpChart; // 4 week XP per week
  final String bestCategory;
  final String weakestSkill;
  final String nextRecommendation;
  final bool isLoaded;

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
    this.isLoaded = false,
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
    bool? isLoaded,
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
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

// ── Life Dashboard Notifier ───────────────────────────────────────────────────

class LifeDashboardNotifier extends StateNotifier<LifeDashboardState> {
  LifeDashboardNotifier() : super(const LifeDashboardState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final agendaCompleted = <String>{};
    for (final item in _defaultAgenda) {
      if (prefs.getBool('agenda_${item.id}') ?? false) agendaCompleted.add(item.id);
    }

    final rewardsClaimed = <String>{};
    for (final r in _defaultRewards) {
      if (prefs.getBool('reward_${r.id}') ?? false) rewardsClaimed.add(r.id);
    }

    final agenda = _defaultAgenda.map((a) => a.copyWith(completed: agendaCompleted.contains(a.id))).toList();
    final rewards = _defaultRewards.map((r) => r.copyWith(claimed: rewardsClaimed.contains(r.id))).toList();

    if (mounted) {
      state = state.copyWith(
        agenda: agenda,
        achievements: _defaultAchievements,
        dailyRewards: rewards,
        weeklyXp: 2340,
        monthlyXp: 9800,
        weeklyHours: 4.5,
        monthlyHours: 18.2,
        weeklyMissions: 3,
        monthlyMissions: 11,
        weeklyXpChart: [120, 340, 180, 560, 420, 700, 320],
        monthlyXpChart: [1800, 2400, 3200, 2400],
        bestCategory: 'AI & Machine Learning',
        weakestSkill: 'Finance',
        nextRecommendation: 'Start "Rich Dad Poor Dad" to boost Finance by 0.8',
        isLoaded: true,
      );
    }
  }

  Future<void> toggleAgendaItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = state.agenda.map((a) {
      if (a.id == id) {
        final newVal = !a.completed;
        prefs.setBool('agenda_$id', newVal);
        return a.copyWith(completed: newVal);
      }
      return a;
    }).toList();
    state = state.copyWith(agenda: updated);
  }

  Future<void> claimReward(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = state.dailyRewards.map((r) {
      if (r.id == id && !r.claimed) {
        prefs.setBool('reward_$id', true);
        return r.copyWith(claimed: true);
      }
      return r;
    }).toList();
    state = state.copyWith(dailyRewards: updated);
  }

  Future<void> refresh() async {
    state = const LifeDashboardState();
    await _init();
  }
}

final lifeDashboardProvider =
    StateNotifierProvider<LifeDashboardNotifier, LifeDashboardState>(
  (ref) => LifeDashboardNotifier(),
);

// ── Default Data ──────────────────────────────────────────────────────────────

const _defaultAgenda = [
  AgendaItem(id: 'a1', title: 'Read Chapter 3', subtitle: 'Atomic Habits · 20 min', icon: '📖', xpReward: 360),
  AgendaItem(id: 'a2', title: 'Complete AI Quiz', subtitle: 'Mentor AI · 5 min', icon: '🧠', xpReward: 200),
  AgendaItem(id: 'a3', title: 'Review Yesterday\'s Notes', subtitle: 'Deep Work · 10 min', icon: '📝', xpReward: 150),
  AgendaItem(id: 'a4', title: 'Unlock New Skill', subtitle: 'Reach 2.0 in AI attribute', icon: '⚡', xpReward: 500),
  AgendaItem(id: 'a5', title: 'Ask AI Coach', subtitle: 'Growth Mentor · 5 min', icon: '✨', xpReward: 100),
  AgendaItem(id: 'a6', title: 'Log Learning Time', subtitle: 'Track your daily progress', icon: '⏱️', xpReward: 50),
];

const _defaultRewards = [
  DailyReward(id: 'r1', title: 'Daily Login Bonus', emoji: '🌟', xp: 100),
  DailyReward(id: 'r2', title: 'Reading Streak', emoji: '🔥', xp: 250),
  DailyReward(id: 'r3', title: 'Skill Progress Bonus', emoji: '⚡', xp: 150),
  DailyReward(id: 'r4', title: 'AI Coach Session', emoji: '🧠', xp: 200),
];

const _defaultAchievements = [
  Achievement(id: 'ach1', title: '7 Day Streak', description: 'Read every day for a week', emoji: '🔥', unlocked: true, progress: 1.0, progressLabel: 'Unlocked'),
  Achievement(id: 'ach2', title: '30 Day Streak', description: 'Read every day for a month', emoji: '💎', unlocked: false, progress: 0.23, progressLabel: '7/30 days'),
  Achievement(id: 'ach3', title: '100 Hours Learned', description: 'Reach 100 hours of total learning', emoji: '⏱️', unlocked: false, progress: 0.18, progressLabel: '18.2/100 hrs'),
  Achievement(id: 'ach4', title: 'First Mission Complete', description: 'Finish your first mission', emoji: '🏆', unlocked: true, progress: 1.0, progressLabel: 'Unlocked'),
  Achievement(id: 'ach5', title: '10 Missions Done', description: 'Complete 10 full missions', emoji: '🚀', unlocked: false, progress: 0.4, progressLabel: '4/10 missions'),
  Achievement(id: 'ach6', title: '1000 XP Earned', description: 'Accumulate 1000 XP', emoji: '🌟', unlocked: true, progress: 1.0, progressLabel: 'Unlocked'),
  Achievement(id: 'ach7', title: '50 AI Chats', description: 'Have 50 sessions with AI Mentor', emoji: '✨', unlocked: false, progress: 0.16, progressLabel: '8/50 chats'),
  Achievement(id: 'ach8', title: 'Level 5 Reached', description: 'Achieve Level 5 on your journey', emoji: '⚡', unlocked: false, progress: 0.42 / 5, progressLabel: 'Level 1'),
];
