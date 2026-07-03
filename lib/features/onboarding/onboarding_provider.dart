import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';

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
  OnboardingNotifier() : super(const OnboardingState()) {
    loadFromBackend();
  }

  DailyTime _minToDailyTime(int mins) {
    if (mins <= 30) return DailyTime.min30;
    if (mins <= 60) return DailyTime.min60;
    if (mins <= 120) return DailyTime.min120;
    return DailyTime.min240plus;
  }

  PreferredLanguage _parseLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'english': return PreferredLanguage.english;
      case 'hindi': return PreferredLanguage.hindi;
      default: return PreferredLanguage.both;
    }
  }

  int _dailyTimeToMin(DailyTime time) {
    switch (time) {
      case DailyTime.min30: return 30;
      case DailyTime.min60: return 60;
      case DailyTime.min120: return 120;
      case DailyTime.min240plus: return 240;
    }
  }

  Future<void> loadFromBackend() async {
    try {
      final profileJson = await apiClient.get('/api/v1/profile');
      final map = Map<String, dynamic>.from(profileJson as Map);
      
      final goalStr = map['career_slug']?.toString();
      final levelStr = map['skill_level']?.toString();
      final dailyTimeMin = (map['daily_learning_time_min'] as num?)?.toInt();
      final langStr = map['preferred_language']?.toString();
      
      state = OnboardingState(
        goal: goalStr != null ? parseReadingGoal(goalStr) : null,
        level: levelStr != null ? parseReadingLevel(levelStr) : null,
        dailyTime: dailyTimeMin != null ? _minToDailyTime(dailyTimeMin) : null,
        language: langStr != null ? _parseLanguage(langStr) : null,
      );
    } catch (_) {
      // Local state is preserved
    }
  }

  Future<void> _saveToBackend() async {
    try {
      final updateData = {
        'career_slug': state.goal != null ? readingGoalToSlug(state.goal!) : null,
        'skill_level': state.level != null ? readingLevelToApi(state.level!) : null,
        'daily_learning_time_min': state.dailyTime != null ? _dailyTimeToMin(state.dailyTime!) : null,
        'preferred_language': state.language?.label,
      };
      await apiClient.put('/api/v1/profile/update', body: updateData);
    } catch (_) {}
  }

  void setGoal(ReadingGoal goal) {
    state = state.copyWith(goal: goal);
    _saveToBackend();
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
    _saveToBackend();
  }

  void setDailyTime(DailyTime time) {
    state = state.copyWith(dailyTime: time);
    _saveToBackend();
  }

  void setLanguage(PreferredLanguage lang) {
    state = state.copyWith(language: lang);
    _saveToBackend();
  }

  Future<void> saveAndComplete() async {
    final updateData = {
      'career_slug': state.goal != null ? readingGoalToSlug(state.goal!) : null,
      'skill_level': state.level != null ? readingLevelToApi(state.level!) : null,
      'daily_learning_time_min': state.dailyTime != null ? _dailyTimeToMin(state.dailyTime!) : null,
      'preferred_language': state.language?.label,
      'onboarding_completed': true,
    };
    await apiClient.put('/api/v1/profile/update', body: updateData);

    final prefs = await SharedPreferences.getInstance();
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
