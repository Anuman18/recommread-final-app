import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/book_details/book_details_screen.dart';
import '../../navigation/main_shell.dart';
import '../../home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/library/library_provider.dart';
import '../../features/ai_coach/ai_coach_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reading/reading_screen.dart';
import '../../features/future_self/future_self_intro_screen.dart';
import '../../features/future_self/future_self_dashboard_screen.dart';
import '../../features/future_self/future_self_chat_screen.dart';
import '../../features/life_dashboard/life_dashboard_screen.dart';
import '../../features/ai_learning_engine/ai_revision_center_screen.dart';
import '../../features/ai_learning_engine/learning_analytics_screen.dart';
import '../../models/book_model.dart';
import '../../data/mock_data.dart';

/// Custom fade + slide page transition.
CustomTransitionPage<T> _fadeSlide<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Slide-up transition used for Book Details (feels like a modal push).
CustomTransitionPage<T> _slideUp<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade =
          CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// No-animation transition for tab switching (instant switch within shell).
NoTransitionPage<T> _noTransition<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(key: state.pageKey, child: child);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── Pre-auth screens ─────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // ── Future Self Experience ─────────────────────────────────────────
      GoRoute(
        path: '/future-self/intro',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const FutureSelfIntroScreen(),
        ),
      ),
      GoRoute(
        path: '/future-self/dashboard',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const FutureSelfDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/future-self/chat',
        pageBuilder: (context, state) => _slideUp(
          state: state,
          child: const FutureSelfChatScreen(),
        ),
      ),
      GoRoute(
        path: '/life-dashboard',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const LifeDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/life-dashboard/revision-center',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const AiRevisionCenterScreen(),
        ),
      ),
      GoRoute(
        path: '/life-dashboard/analytics',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const LearningAnalyticsScreen(),
        ),
      ),

      GoRoute(
        path: '/book/:id',
        pageBuilder: (context, state) {
          final extra = state.extra;
          final resources = ref.read(libraryProvider).resources;
          final resource = extra is LearningResource
              ? extra
              : findResourceById(state.pathParameters['id'] ?? '', resources) ??
                  (resources.isNotEmpty
                      ? resources.first
                      : const LearningResource(
                          id: 'fallback',
                          title: 'Learning Resource',
                          provider: 'AI OS',
                          type: 'Documentation',
                          difficulty: 'Beginner',
                          timeMin: 10,
                          xpReward: 100,
                          coinsReward: 10,
                          skills: [],
                          url: 'https://github.com',
                        ));
          return _slideUp(state: state, child: BookDetailsScreen(resource: resource));
        },
      ),
      // ── Reading View (top-level push, no shell) ───────────────────────
      GoRoute(
        path: '/read/:id',
        pageBuilder: (context, state) {
          final extra = state.extra;
          final book = extra is Book
              ? extra
              : findBookById(state.pathParameters['id'] ?? '') ??
                  kAllBooks.first;
          return _slideUp(state: state, child: ReadingScreen(book: book));
        },
      ),
      // ── Main shell with bottom navigation (5 tabs) ───────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 – Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    _noTransition(state: state, child: const HomeScreen()),
              ),
            ],
          ),
          // Tab 1 – Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) =>
                    _noTransition(state: state, child: const SearchScreen()),
              ),
            ],
          ),
          // Tab 2 – Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                pageBuilder: (context, state) =>
                    _noTransition(state: state, child: const LibraryScreen()),
              ),
            ],
          ),
          // Tab 3 – AI Coach
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-coach',
                pageBuilder: (context, state) =>
                    _noTransition(state: state, child: const AiCoachScreen()),
              ),
            ],
          ),
          // Tab 4 – Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    _noTransition(state: state, child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
