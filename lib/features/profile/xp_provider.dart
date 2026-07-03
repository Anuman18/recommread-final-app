import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../models/book_model.dart';

class XpState {
  XpState({
    required this.currentXp,
    required this.skills,
    required this.dailyChallenges,
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentXp;
  final Map<String, double> skills;
  final Map<String, bool> dailyChallenges;
  final bool isLoading;
  final String? errorMessage;

  int get level => (currentXp / 2500).floor() + 1;
  int get xpInCurrentLevel => currentXp % 2500;
  double get levelProgress => xpInCurrentLevel / 2500.0;

  XpState copyWith({
    int? currentXp,
    Map<String, double>? skills,
    Map<String, bool>? dailyChallenges,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return XpState(
      currentXp: currentXp ?? this.currentXp,
      skills: skills ?? this.skills,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class XpNotifier extends StateNotifier<XpState> {
  XpNotifier()
      : super(XpState(
          currentXp: 0,
          skills: {},
          dailyChallenges: {
            'Read 15 Minutes': false,
            'Complete One Chapter': false,
            'Finish One Mission': false,
            'Ask AI One Question': false,
          },
          isLoading: true,
        )) {
    refreshFromBackend();
  }

  Future<void> refreshFromBackend() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final xpJson = await apiClient.get(ApiConstants.gamificationXp);
      await apiClient.get(ApiConstants.gamificationLevel);
      final strongSkillsJson = await apiClient.get(ApiConstants.recommendationsStrongSkills);
      final weakSkillsJson = await apiClient.get(ApiConstants.recommendationsWeakSkills);

      final totalXp = (xpJson['total_xp'] as num?)?.toInt() ?? 0;
      final strongSkills = (strongSkillsJson as List).cast<String>();
      final weakSkills = (weakSkillsJson as List).cast<String>();

      final skills = <String, double>{};
      for (final skill in strongSkills) {
        skills[skill] = 3.5;
      }
      for (final skill in weakSkills) {
        skills[skill] = 1.5;
      }

      state = state.copyWith(
        currentXp: totalXp,
        skills: skills.isEmpty ? state.skills : skills,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load XP data.');
    }
  }

  Future<void> addXp(int amount) async {
    try {
      await apiClient.post(
        ApiConstants.gamificationClaimReward,
        body: {
          'reward_source': 'Activity Completion',
          'xp_reward': amount,
          'coins_reward': (amount ~/ 10).clamp(1, 50),
        },
      );
      await refreshFromBackend();
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to award XP.');
    }
  }

  Future<void> toggleChallenge(String challenge) async {
    final newChallenges = Map<String, bool>.from(state.dailyChallenges);
    final val = !(newChallenges[challenge] ?? false);
    newChallenges[challenge] = val;

    if (val) {
      try {
        await apiClient.post(
          ApiConstants.gamificationClaimReward,
          body: {
            'reward_source': challenge,
            'xp_reward': 150,
            'coins_reward': 15,
          },
        );
        await refreshFromBackend();
      } on ApiException catch (e) {
        state = state.copyWith(errorMessage: e.message);
        return;
      }
    }

    state = state.copyWith(dailyChallenges: newChallenges);
  }

  Future<void> completeMission(Book book) async {
    try {
      await apiClient.post(
        ApiConstants.gamificationClaimReward,
        body: {
          'reward_source': 'mission_${book.id}',
          'xp_reward': book.xpReward,
          'coins_reward': 20,
        },
      );
      await refreshFromBackend();
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }
}

final xpProvider = StateNotifierProvider<XpNotifier, XpState>((ref) {
  return XpNotifier();
});
