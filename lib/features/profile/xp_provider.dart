import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book_model.dart';

class XpState {
  XpState({
    required this.currentXp,
    required this.skills,
    required this.dailyChallenges,
  });

  final int currentXp;
  final Map<String, double> skills; // Skill Name -> Level (e.g. 1.2)
  final Map<String, bool> dailyChallenges;

  int get level => (currentXp / 3000).floor() + 1;
  int get xpInCurrentLevel => currentXp % 3000;
  double get levelProgress => xpInCurrentLevel / 3000.0;

  XpState copyWith({
    int? currentXp,
    Map<String, double>? skills,
    Map<String, bool>? dailyChallenges,
  }) {
    return XpState(
      currentXp: currentXp ?? this.currentXp,
      skills: skills ?? this.skills,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
    );
  }
}

class XpNotifier extends StateNotifier<XpState> {
  XpNotifier()
      : super(XpState(
          currentXp: 1250,
          skills: {
            'Communication': 1.0,
            'Leadership': 1.0,
            'Finance': 1.0,
            'AI': 1.0,
            'Programming': 1.0,
            'Business': 1.0,
            'Psychology': 1.0,
            'Productivity': 1.0,
            'Critical Thinking': 1.0,
          },
          dailyChallenges: {
            'Read 15 Minutes': false,
            'Complete One Chapter': false,
            'Finish One Mission': false,
            'Ask AI One Question': false,
          },
        )) {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt('user_xp') ?? 1250;
    
    final Map<String, double> loadedSkills = {};
    state.skills.forEach((key, val) {
      loadedSkills[key] = prefs.getDouble('skill_$key') ?? val;
    });

    final Map<String, bool> loadedChallenges = {};
    state.dailyChallenges.forEach((key, val) {
      loadedChallenges[key] = prefs.getBool('challenge_$key') ?? val;
    });

    state = XpState(
      currentXp: xp,
      skills: loadedSkills,
      dailyChallenges: loadedChallenges,
    );
  }

  Future<void> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newXp = state.currentXp + amount;
    await prefs.setInt('user_xp', newXp);

    state = state.copyWith(currentXp: newXp);
  }

  Future<void> toggleChallenge(String challenge) async {
    final prefs = await SharedPreferences.getInstance();
    final newChallenges = Map<String, bool>.from(state.dailyChallenges);
    final val = !(newChallenges[challenge] ?? false);
    newChallenges[challenge] = val;
    
    await prefs.setBool('challenge_$challenge', val);
    
    // Grant 150 XP if challenge is completed
    if (val) {
      await addXp(150);
    } else {
      await addXp(-150);
    }
    
    state = state.copyWith(dailyChallenges: newChallenges);
  }

  Future<void> completeMission(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Add mission XP
    await addXp(book.xpReward);
    
    // Increase related skills
    final newSkills = Map<String, double>.from(state.skills);
    for (final skill in book.skillsUnlocked) {
      if (newSkills.containsKey(skill)) {
        final currentVal = newSkills[skill] ?? 1.0;
        final newVal = currentVal + 0.3;
        newSkills[skill] = double.parse(newVal.toStringAsFixed(1));
        await prefs.setDouble('skill_$skill', newSkills[skill]!);
      }
    }
    
    // Update finish mission challenge
    if (state.dailyChallenges.containsKey('Finish One Mission') && 
        !(state.dailyChallenges['Finish One Mission'] ?? false)) {
      await toggleChallenge('Finish One Mission');
    }

    state = state.copyWith(skills: newSkills);
  }
}

final xpProvider = StateNotifierProvider<XpNotifier, XpState>((ref) {
  return XpNotifier();
});
