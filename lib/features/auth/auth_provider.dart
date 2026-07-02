import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class AuthUser {
  final int id;
  final String name;
  final String email;
  final String readingGoal;
  final String readingLevel;
  final int streak;
  final int booksCompleted;
  final int booksSaved;
  final String favoriteGenres;
  final String avatarLetter;
  final bool onboardingCompleted;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.readingGoal,
    required this.readingLevel,
    required this.streak,
    required this.booksCompleted,
    required this.booksSaved,
    required this.favoriteGenres,
    required this.avatarLetter,
    required this.onboardingCompleted,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'] ?? 'User',
      email: json['email'],
      readingGoal: json['reading_goal'] ?? 'ai_engineer',
      readingLevel: json['reading_level'] ?? 'intermediate',
      streak: json['streak'] ?? 0,
      booksCompleted: json['books_completed'] ?? 0,
      booksSaved: json['books_saved'] ?? 0,
      favoriteGenres: json['favorite_genres'] ?? '',
      avatarLetter: json['avatar_letter'] ?? 'U',
      onboardingCompleted: json['onboarding_completed'] ?? false,
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          isAuthenticated: false,
          isLoading: false,
        ));

  Future<bool> checkAutoLogin() async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    if (!apiClient.hasToken) {
      state = AuthState(isAuthenticated: false, isLoading: false);
      return false;
    }

    try {
      final userJson = await apiClient.get(ApiConstants.authMe);
      final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));
      state = AuthState(isAuthenticated: true, isLoading: false, user: user);
      return true;
    } catch (_) {
      await apiClient.clearToken();
      state = AuthState(isAuthenticated: false, isLoading: false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      final result = await apiClient.post(ApiConstants.authLogin, body: {
        'email': email,
        'password': password,
      });
      final String token = result['access_token'];
      await apiClient.saveToken(token);

      final userJson = await apiClient.get(ApiConstants.authMe);
      final user = AuthUser.fromJson(Map<String, dynamic>.from(userJson));

      state = AuthState(isAuthenticated: true, isLoading: false, user: user);
      return true;
    } on ApiException catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Unable to connect to the server.',
      );
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      await apiClient.post(ApiConstants.authSignup, body: {
        'email': email,
        'password': password,
      });

      final loggedIn = await login(email, password);
      if (loggedIn && name.trim().isNotEmpty) {
        try {
          await apiClient.put(ApiConstants.profileUpdate, body: {'name': name.trim()});
        } catch (_) {}
      }
      return loggedIn;
    } on ApiException catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Unable to connect to the server.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await apiClient.clearToken();
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
