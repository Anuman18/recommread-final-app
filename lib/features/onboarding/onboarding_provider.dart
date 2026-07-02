import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Career Goal (Target Identity) ────────────────────────────────────────────

enum ReadingGoal {
  aiEngineer,
  dataScientist,
  softwareEngineer,
  fullStackDeveloper,
  backendEngineer,
  frontendEngineer,
  uxDesigner,
  productManager,
  cyberSecurityEngineer,
  devOpsEngineer,
  cloudEngineer,
  startupFounder,
  entrepreneur,
  digitalMarketer,
  contentCreator,
  iasOfficer,
  doctor,
  lawyer,
}

extension ReadingGoalExt on ReadingGoal {
  String get label {
    switch (this) {
      case ReadingGoal.aiEngineer:           return 'AI Engineer';
      case ReadingGoal.dataScientist:        return 'Data Scientist';
      case ReadingGoal.softwareEngineer:     return 'Software Engineer';
      case ReadingGoal.fullStackDeveloper:   return 'Full Stack Developer';
      case ReadingGoal.backendEngineer:      return 'Backend Engineer';
      case ReadingGoal.frontendEngineer:     return 'Frontend Engineer';
      case ReadingGoal.uxDesigner:           return 'UI/UX Designer';
      case ReadingGoal.productManager:       return 'Product Manager';
      case ReadingGoal.cyberSecurityEngineer:return 'Cyber Security Engineer';
      case ReadingGoal.devOpsEngineer:       return 'DevOps Engineer';
      case ReadingGoal.cloudEngineer:        return 'Cloud Engineer';
      case ReadingGoal.startupFounder:       return 'Startup Founder';
      case ReadingGoal.entrepreneur:         return 'Entrepreneur';
      case ReadingGoal.digitalMarketer:      return 'Digital Marketer';
      case ReadingGoal.contentCreator:       return 'Content Creator';
      case ReadingGoal.iasOfficer:           return 'IAS Officer';
      case ReadingGoal.doctor:               return 'Doctor';
      case ReadingGoal.lawyer:               return 'Lawyer';
    }
  }

  String get emoji {
    switch (this) {
      case ReadingGoal.aiEngineer:           return '🧠';
      case ReadingGoal.dataScientist:        return '📊';
      case ReadingGoal.softwareEngineer:     return '💻';
      case ReadingGoal.fullStackDeveloper:   return '🌐';
      case ReadingGoal.backendEngineer:      return '⚙️';
      case ReadingGoal.frontendEngineer:     return '🎨';
      case ReadingGoal.uxDesigner:           return '✏️';
      case ReadingGoal.productManager:       return '📋';
      case ReadingGoal.cyberSecurityEngineer:return '🔐';
      case ReadingGoal.devOpsEngineer:       return '🚀';
      case ReadingGoal.cloudEngineer:        return '☁️';
      case ReadingGoal.startupFounder:       return '🏗️';
      case ReadingGoal.entrepreneur:         return '💼';
      case ReadingGoal.digitalMarketer:      return '📣';
      case ReadingGoal.contentCreator:       return '🎬';
      case ReadingGoal.iasOfficer:           return '🏛️';
      case ReadingGoal.doctor:               return '🩺';
      case ReadingGoal.lawyer:               return '⚖️';
    }
  }

  String get category {
    switch (this) {
      case ReadingGoal.aiEngineer:
      case ReadingGoal.dataScientist:
      case ReadingGoal.softwareEngineer:
      case ReadingGoal.fullStackDeveloper:
      case ReadingGoal.backendEngineer:
      case ReadingGoal.frontendEngineer:
      case ReadingGoal.cyberSecurityEngineer:
      case ReadingGoal.devOpsEngineer:
      case ReadingGoal.cloudEngineer:        return 'Tech';
      case ReadingGoal.uxDesigner:
      case ReadingGoal.productManager:
      case ReadingGoal.startupFounder:
      case ReadingGoal.entrepreneur:
      case ReadingGoal.digitalMarketer:
      case ReadingGoal.contentCreator:       return 'Business';
      case ReadingGoal.iasOfficer:
      case ReadingGoal.doctor:
      case ReadingGoal.lawyer:               return 'Professional';
    }
  }
}

// ── Skill Level ───────────────────────────────────────────────────────────────

enum ReadingLevel { beginner, intermediate, advanced }

extension ReadingLevelExt on ReadingLevel {
  String get label {
    switch (this) {
      case ReadingLevel.beginner:     return 'Beginner';
      case ReadingLevel.intermediate: return 'Intermediate';
      case ReadingLevel.advanced:     return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case ReadingLevel.beginner:
        return 'Just starting out, exploring the basics';
      case ReadingLevel.intermediate:
        return 'Have some experience, ready to level up';
      case ReadingLevel.advanced:
        return 'Deep expertise, aiming for mastery';
    }
  }

  String get techDescription {
    switch (this) {
      case ReadingLevel.beginner:
        return '0–6 months of experience • Learning fundamentals';
      case ReadingLevel.intermediate:
        return '6 months–2 years • Built projects, knows basics';
      case ReadingLevel.advanced:
        return '2+ years • Production experience, seeks mastery';
    }
  }
}

// ── Daily Learning Time ───────────────────────────────────────────────────────

enum DailyTime { min30, min60, min120, min240plus }

extension DailyTimeExt on DailyTime {
  String get label {
    switch (this) {
      case DailyTime.min30:     return '30 Minutes';
      case DailyTime.min60:     return '1 Hour';
      case DailyTime.min120:    return '2 Hours';
      case DailyTime.min240plus:return '4+ Hours';
    }
  }

  String get subtitle {
    switch (this) {
      case DailyTime.min30:     return 'Casual learner';
      case DailyTime.min60:     return 'Consistent grower';
      case DailyTime.min120:    return 'Dedicated builder';
      case DailyTime.min240plus:return 'Full-time learner';
    }
  }

  String get emoji {
    switch (this) {
      case DailyTime.min30:     return '⚡';
      case DailyTime.min60:     return '🎯';
      case DailyTime.min120:    return '🔥';
      case DailyTime.min240plus:return '🏆';
    }
  }
}

// ── Preferred Language ────────────────────────────────────────────────────────

enum PreferredLanguage { english, hindi, both }

extension PreferredLanguageExt on PreferredLanguage {
  String get label {
    switch (this) {
      case PreferredLanguage.english: return 'English';
      case PreferredLanguage.hindi:   return 'Hindi';
      case PreferredLanguage.both:    return 'Both';
    }
  }

  String get subtitle {
    switch (this) {
      case PreferredLanguage.english: return 'Learn entirely in English';
      case PreferredLanguage.hindi:   return 'Learn in Hindi / Hinglish';
      case PreferredLanguage.both:    return 'Mix of English & Hindi';
    }
  }

  String get emoji {
    switch (this) {
      case PreferredLanguage.english: return '🇬🇧';
      case PreferredLanguage.hindi:   return '🇮🇳';
      case PreferredLanguage.both:    return '🌐';
    }
  }
}

// ── State ──────────────────────────────────────────────────────────────────

class OnboardingState {
  final ReadingGoal? goal;
  final Set<String> genres;
  final ReadingLevel? level;
  final DailyTime? dailyTime;
  final PreferredLanguage? language;

  const OnboardingState({
    this.goal,
    this.genres = const {},
    this.level,
    this.dailyTime,
    this.language,
  });

  OnboardingState copyWith({
    ReadingGoal? goal,
    Set<String>? genres,
    ReadingLevel? level,
    DailyTime? dailyTime,
    PreferredLanguage? language,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      genres: genres ?? this.genres,
      level: level ?? this.level,
      dailyTime: dailyTime ?? this.dailyTime,
      language: language ?? this.language,
    );
  }

  bool get isComplete =>
      goal != null && level != null && dailyTime != null && language != null;
}

// ── Notifier ───────────────────────────────────────────────────────────────

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setGoal(ReadingGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void toggleGenre(String genre) {
    final genres = Set<String>.from(state.genres);
    if (genres.contains(genre)) {
      genres.remove(genre);
    } else {
      genres.add(genre);
    }
    state = state.copyWith(genres: genres);
  }

  void setLevel(ReadingLevel level) {
    state = state.copyWith(level: level);
  }

  void setDailyTime(DailyTime time) {
    state = state.copyWith(dailyTime: time);
  }

  void setLanguage(PreferredLanguage lang) {
    state = state.copyWith(language: lang);
  }

  Future<void> saveAndComplete() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.goal != null) {
      await prefs.setString('onboarding_goal', state.goal!.name);
    }
    if (state.level != null) {
      await prefs.setString('onboarding_level', state.level!.name);
    }
    if (state.dailyTime != null) {
      await prefs.setString('onboarding_time', state.dailyTime!.name);
    }
    if (state.language != null) {
      await prefs.setString('onboarding_language', state.language!.name);
    }
    await prefs.setStringList('onboarding_genres', state.genres.toList());
    await prefs.setBool('onboarding_complete', true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

// ── Genre list (kept for compatibility) ───────────────────────────────────────

const List<String> kAllGenres = [
  '💻 Programming',
  '🧠 AI & ML',
  '📊 Data Science',
  '☁️ Cloud Computing',
  '🔐 Cyber Security',
  '🎨 Design',
  '📋 Product Management',
  '💼 Entrepreneurship',
  '📣 Marketing',
  '💰 Finance',
  '🏛️ Government & Policy',
  '🩺 Medicine & Health',
];
