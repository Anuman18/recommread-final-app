import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../onboarding/onboarding_provider.dart';

// ── Mappings Helpers ────────────────────────────────────────────────────────

ReadingGoal _parseGoal(String goalStr) {
  for (final val in ReadingGoal.values) {
    if (val.name == goalStr) return val;
  }
  return ReadingGoal.aiEngineer;
}

String _goalToString(ReadingGoal goal) {
  return goal.toString().split('.').last;
}

ReadingLevel _parseLevel(String levelStr) {
  switch (levelStr) {
    case 'beginner':
      return ReadingLevel.beginner;
    case 'advanced':
      return ReadingLevel.advanced;
    default:
      return ReadingLevel.intermediate;
  }
}
// ── Profile State Model ────────────────────────────────────────────────────

class ProfileState {
  final String name;
  final String avatarLetter;
  final ReadingLevel readingLevel;
  final int streak;
  final int booksCompleted;
  final int booksSaved;
  final ReadingGoal readingGoal;
  final Set<String> favoriteGenres;
  final List<String> favoriteAuthors;
  final bool isDarkMode;
  final String language;
  final int pagesReadThisMonth;
  final int totalReadingTimeHours;
  final bool isLoading;

  ProfileState({
    required this.name,
    required this.avatarLetter,
    required this.readingLevel,
    required this.streak,
    required this.booksCompleted,
    required this.booksSaved,
    required this.readingGoal,
    required this.favoriteGenres,
    required this.favoriteAuthors,
    required this.isDarkMode,
    required this.language,
    required this.pagesReadThisMonth,
    required this.totalReadingTimeHours,
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? name,
    String? avatarLetter,
    ReadingLevel? readingLevel,
    int? streak,
    int? booksCompleted,
    int? booksSaved,
    ReadingGoal? readingGoal,
    Set<String>? favoriteGenres,
    List<String>? favoriteAuthors,
    bool? isDarkMode,
    String? language,
    int? pagesReadThisMonth,
    int? totalReadingTimeHours,
    bool? isLoading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      avatarLetter: avatarLetter ?? this.avatarLetter,
      readingLevel: readingLevel ?? this.readingLevel,
      streak: streak ?? this.streak,
      booksCompleted: booksCompleted ?? this.booksCompleted,
      booksSaved: booksSaved ?? this.booksSaved,
      readingGoal: readingGoal ?? this.readingGoal,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      favoriteAuthors: favoriteAuthors ?? this.favoriteAuthors,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      pagesReadThisMonth: pagesReadThisMonth ?? this.pagesReadThisMonth,
      totalReadingTimeHours: totalReadingTimeHours ?? this.totalReadingTimeHours,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Profile State Notifier ─────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: 'Alex Reader',
          avatarLetter: 'AR',
          readingLevel: ReadingLevel.intermediate,
          streak: 0,
          booksCompleted: 0,
          booksSaved: 0,
          readingGoal: ReadingGoal.aiEngineer,
          favoriteGenres: {},
          favoriteAuthors: ['James Clear', 'Cal Newport', 'Morgan Housel', 'Marcus Aurelius'],
          isDarkMode: true,
          language: 'English',
          pagesReadThisMonth: 120,
          totalReadingTimeHours: 10,
          isLoading: true,
        )) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final userJson = await apiClient.get('/profile');
      if (userJson != null) {
        final String genresStr = userJson['favorite_genres'] ?? '';
        final genresSet = genresStr.isEmpty 
            ? <String>{} 
            : genresStr.split(',').map((g) => g.trim()).toSet();

        state = state.copyWith(
          name: userJson['name'] ?? 'User Name',
          avatarLetter: userJson['avatar_letter'] ?? 'AR',
          readingGoal: _parseGoal(userJson['reading_goal'] ?? 'selfGrowth'),
          readingLevel: _parseLevel(userJson['reading_level'] ?? 'intermediate'),
          streak: userJson['streak'] ?? 0,
          booksCompleted: userJson['books_completed'] ?? 0,
          booksSaved: userJson['books_saved'] ?? 0,
          favoriteGenres: genresSet,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProfile({
    required String name,
    required ReadingGoal readingGoal,
    required Set<String> favoriteGenres,
    required String avatarLetter,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final updateData = {
        'name': name,
        'reading_goal': _goalToString(readingGoal),
        'avatar_letter': avatarLetter,
        'favorite_genres': favoriteGenres.join(','),
      };

      final result = await apiClient.put('/profile/update', body: updateData);
      if (result != null) {
        final String genresStr = result['favorite_genres'] ?? '';
        final genresSet = genresStr.isEmpty 
            ? <String>{} 
            : genresStr.split(',').map((g) => g.trim()).toSet();

        state = state.copyWith(
          name: result['name'] ?? name,
          avatarLetter: result['avatar_letter'] ?? avatarLetter,
          readingGoal: _parseGoal(result['reading_goal'] ?? 'selfGrowth'),
          favoriteGenres: genresSet,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void updateLanguage(String newLanguage) {
    state = state.copyWith(language: newLanguage);
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
