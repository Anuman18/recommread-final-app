import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      readingGoal: json['reading_goal'] ?? 'selfGrowth',
      readingLevel: json['reading_level'] ?? 'intermediate',
      streak: json['streak'] ?? 0,
      booksCompleted: json['books_completed'] ?? 0,
      booksSaved: json['books_saved'] ?? 0,
      favoriteGenres: json['favorite_genres'] ?? '',
      avatarLetter: json['avatar_letter'] ?? 'AR',
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

  // Auto Login Check
  Future<bool> checkAutoLogin() async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    if (!apiClient.hasToken) {
      state = AuthState(isAuthenticated: false, isLoading: false);
      return false;
    }

    try {
      final userJson = await apiClient.get('/api/v1/auth/me');
      final user = AuthUser.fromJson(userJson);
      state = AuthState(isAuthenticated: true, isLoading: false, user: user);
      return true;
    } catch (_) {
      // Clear invalid token
      await apiClient.clearToken();
      state = AuthState(isAuthenticated: false, isLoading: false);
      return false;
    }
  }

  // Sign In
  Future<bool> login(String email, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      final result = await apiClient.post('/api/v1/auth/login', body: {
        'email': email,
        'password': password,
      });
      final String token = result['access_token'];
      await apiClient.saveToken(token);

      // Fetch user profile
      final userJson = await apiClient.get('/api/v1/auth/me');
      final user = AuthUser.fromJson(userJson);

      state = AuthState(isAuthenticated: true, isLoading: false, user: user);
      return true;
    } on ApiException catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: 'Network connection failed.');
      return false;
    }
  }

  // Sign Up
  Future<bool> signup(String name, String email, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      await apiClient.post('/api/v1/auth/signup', body: {
        'name': name,
        'email': email,
        'password': password,
      });
      
      // Auto login after signup
      return await login(email, password);
    } on ApiException catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState(isAuthenticated: false, isLoading: false, errorMessage: 'Network connection failed.');
      return false;
    }
  }

  // Sign Out
  Future<void> logout() async {
    await apiClient.clearToken();
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
