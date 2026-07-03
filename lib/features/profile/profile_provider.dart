import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';
import '../onboarding/onboarding_provider.dart';

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
  final String? errorMessage;

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
    this.errorMessage,
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
    String? errorMessage,
    bool clearError = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: '',
          avatarLetter: 'U',
          readingLevel: ReadingLevel.intermediate,
          streak: 0,
          booksCompleted: 0,
          booksSaved: 0,
          readingGoal: ReadingGoal.aiEngineer,
          favoriteGenres: {},
          favoriteAuthors: [],
          isDarkMode: true,
          language: 'English',
          pagesReadThisMonth: 0,
          totalReadingTimeHours: 0,
          isLoading: true,
        )) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userJson = await apiClient.get(ApiConstants.authMe);
      final profileJson = await apiClient.get(ApiConstants.profile);

      final userMap = Map<String, dynamic>.from(userJson as Map);
      final profileMap = Map<String, dynamic>.from(profileJson as Map);

      final name = profileMap['name']?.toString() ?? userMap['name']?.toString() ?? 'User';
      final avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

      final prefs = await SharedPreferences.getInstance();
      final localDark = prefs.getBool('theme_dark_mode') ?? true;

      state = state.copyWith(
        name: name,
        avatarLetter: avatarLetter,
        readingGoal: parseReadingGoal(
          profileMap['career_slug']?.toString() ?? userMap['reading_goal']?.toString() ?? 'ai_engineer',
        ),
        readingLevel: parseReadingLevel(
          profileMap['skill_level']?.toString() ?? userMap['reading_level']?.toString() ?? 'intermediate',
        ),
        streak: (profileMap['streak'] as num?)?.toInt() ?? (userMap['streak'] as num?)?.toInt() ?? 0,
        booksCompleted: (userMap['books_completed'] as num?)?.toInt() ?? 0,
        booksSaved: (userMap['books_saved'] as num?)?.toInt() ?? 0,
        language: profileMap['preferred_language']?.toString() ?? 'English',
        isDarkMode: localDark,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load profile.');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required ReadingGoal readingGoal,
    required Set<String> favoriteGenres,
    required String avatarLetter,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updateData = {
        'name': name,
        'career_slug': readingGoalToSlug(readingGoal),
        'skill_level': readingLevelToApi(state.readingLevel),
        'preferred_language': state.language,
      };

      final result = await apiClient.put(ApiConstants.profileUpdate, body: updateData);
      final resultMap = Map<String, dynamic>.from(result as Map);

      state = state.copyWith(
        name: resultMap['name']?.toString() ?? name,
        avatarLetter: avatarLetter.isNotEmpty ? avatarLetter : name[0].toUpperCase(),
        readingGoal: parseReadingGoal(resultMap['career_slug']?.toString() ?? readingGoalToSlug(readingGoal)),
        favoriteGenres: favoriteGenres,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to update profile.');
      return false;
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = !state.isDarkMode;
    state = state.copyWith(isDarkMode: nextMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark_mode', nextMode);
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
