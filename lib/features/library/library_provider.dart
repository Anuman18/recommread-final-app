import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/utils/career_utils.dart';
import '../../models/book_model.dart';
import '../profile/profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMPATIBILITY MODELS (OLD BOOKS MODULE)
// ─────────────────────────────────────────────────────────────────────────────

class CompletedBook {
  final Book book;
  final String completedDate;
  final double userRating;

  CompletedBook({
    required this.book,
    required this.completedDate,
    required this.userRating,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW MODEL DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

class LearningResource {
  final String id;
  final String title;
  final String provider;
  final String type; // documentation, youtube, courses, coding practice, projects, blogs, research papers, interview questions
  final String difficulty; // Beginner, Intermediate, Advanced
  final int timeMin;
  final int xpReward;
  final int coinsReward;
  final List<String> skills;
  final String url;
  final bool isBookmarked;
  final String completionStatus; // not_started, in_progress, completed
  final String icon;
  final String description;
  final String aiReason;
  final String? missionLink; // Link to a related mission
  final List<String> relatedResourceIds;

  const LearningResource({
    required this.id,
    required this.title,
    required this.provider,
    required this.type,
    required this.difficulty,
    required this.timeMin,
    required this.xpReward,
    required this.coinsReward,
    required this.skills,
    required this.url,
    this.isBookmarked = false,
    this.completionStatus = 'not_started',
    this.icon = '📖',
    this.description = '',
    this.aiReason = '',
    this.missionLink,
    this.relatedResourceIds = const [],
  });

  LearningResource copyWith({
    bool? isBookmarked,
    String? completionStatus,
  }) {
    return LearningResource(
      id: id,
      title: title,
      provider: provider,
      type: type,
      difficulty: difficulty,
      timeMin: timeMin,
      xpReward: xpReward,
      coinsReward: coinsReward,
      skills: skills,
      url: url,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      completionStatus: completionStatus ?? this.completionStatus,
      icon: icon,
      description: description,
      aiReason: aiReason,
      missionLink: missionLink,
      relatedResourceIds: relatedResourceIds,
    );
  }

  factory LearningResource.fromJson(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? j['type'] as String? ?? 'courses';
    final isCompleted = j['is_completed'] == true;
    return LearningResource(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      provider: j['provider'] ?? j['source'] ?? category,
      type: category,
      difficulty: j['difficulty'] ?? 'Intermediate',
      timeMin: j['time_min'] ?? 30,
      xpReward: j['xp_reward'] ?? 100,
      coinsReward: j['coins_reward'] ?? 10,
      skills: List<String>.from(j['skills'] ?? []),
      url: j['url'] ?? '',
      isBookmarked: j['is_bookmarked'] ?? false,
      completionStatus: j['completion_status'] ??
          (isCompleted ? 'completed' : 'not_started'),
      icon: j['icon'] ?? '📖',
      description: j['description'] ?? '',
      aiReason: j['ai_reason'] ?? j['why_recommended'] ?? '',
      missionLink: j['mission_link'],
      relatedResourceIds: List<String>.from(j['related_resource_ids'] ?? []),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE DEFINITIONS
// ─────────────────────────────────────────────────────────────────────────────

class LibraryState {
  final List<LearningResource> resources;
  final String selectedCategory; // All or a specific type
  final String selectedFilter; // All, Beginner, Intermediate, Advanced, Completed, Bookmarked, Recommended
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  // Compatibility fields for old books module
  final List<Book> continueReading;
  final List<Book> saved;
  final List<CompletedBook> completed;

  const LibraryState({
    this.resources = const [],
    this.selectedCategory = 'All',
    this.selectedFilter = 'All',
    this.searchQuery = '',
    this.isLoading = true,
    this.errorMessage,
    this.continueReading = const [],
    this.saved = const [],
    this.completed = const [],
  });

  LibraryState copyWith({
    List<LearningResource>? resources,
    String? selectedCategory,
    String? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    List<Book>? continueReading,
    List<Book>? saved,
    List<CompletedBook>? completed,
  }) {
    return LibraryState(
      resources: resources ?? this.resources,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      continueReading: continueReading ?? this.continueReading,
      saved: saved ?? this.saved,
      completed: completed ?? this.completed,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIBRARY NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;

  LibraryNotifier(this._ref) : super(const LibraryState()) {
    loadLibraryData();
  }

  Book resourceToBook(LearningResource r) {
    final genre = r.type;
    final tags = r.skills;
    
    final val = r.id.hashCode % 5;
    List<Color> colors;
    switch (val) {
      case 0: colors = [const Color(0xFF1565C0), const Color(0xFF0D47A1)]; break;
      case 1: colors = [const Color(0xFFAD1457), const Color(0xFF6A1B29)]; break;
      case 2: colors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]; break;
      case 3: colors = [const Color(0xFFEF6C00), const Color(0xFFE65100)]; break;
      default: colors = [const Color(0xFF6A1B9A), const Color(0xFF4A148C)]; break;
    }
    
    int totalPages = r.timeMin * 2;
    if (totalPages <= 0) totalPages = 100;
    int readPages = 0;
    if (r.completionStatus == 'completed') {
      readPages = totalPages;
    } else if (r.completionStatus == 'in_progress') {
      readPages = (totalPages * 0.4).toInt();
    }

    return Book(
      id: r.id,
      title: r.title,
      author: r.provider,
      genre: genre,
      rating: 4.5,
      description: r.description.isNotEmpty ? r.description : r.aiReason,
      coverColors: colors,
      coverEmoji: r.icon,
      totalPages: totalPages,
      readPages: readPages,
      tags: tags,
    );
  }

  void _updateDerivedLists(List<LearningResource> resources) {
    final continueReadingList = resources
        .where((r) => r.completionStatus == 'in_progress')
        .map((r) => resourceToBook(r))
        .toList();

    final savedList = resources
        .where((r) => r.isBookmarked)
        .map((r) => resourceToBook(r))
        .toList();

    final completedList = resources
        .where((r) => r.completionStatus == 'completed')
        .map((r) => CompletedBook(
              book: resourceToBook(r),
              completedDate: 'Recent',
              userRating: 4.5,
            ))
        .toList();

    state = state.copyWith(
      resources: resources,
      continueReading: continueReadingList,
      saved: savedList,
      completed: completedList,
    );
  }

  Future<void> loadLibraryData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final careerSlug = readingGoalToSlug(_ref.read(profileProvider).readingGoal);

    try {
      final resourcesJson = await apiClient.get('${ApiConstants.resources}?career=$careerSlug');
      final fetchedList = (resourcesJson as List)
          .map((r) => LearningResource.fromJson(Map<String, dynamic>.from(r)))
          .toList();

      _updateDerivedLists(fetchedList);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load library resources.');
    }
  }

  Future<void> refresh() async {
    await loadLibraryData();
  }

  Future<void> toggleBookmark(String resourceId) async {
    try {
      final result = await apiClient.post('${ApiConstants.resources}/$resourceId/bookmark');
      final updated = LearningResource.fromJson(Map<String, dynamic>.from(result));
      bool found = false;
      final updatedList = state.resources.map((r) {
        if (r.id == resourceId) {
          found = true;
          return updated;
        }
        return r;
      }).toList();
      if (!found) {
        updatedList.add(updated);
      }
      _updateDerivedLists(updatedList);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  Future<void> updateCompletionStatus(String resourceId, String nextStatus) async {
    if (nextStatus != 'completed') return;
    try {
      final result = await apiClient.post('${ApiConstants.resources}/$resourceId/complete');
      final updated = LearningResource.fromJson(Map<String, dynamic>.from(result));
      final updatedList = state.resources.map((r) {
        return r.id == resourceId
            ? updated.copyWith(completionStatus: 'completed')
            : r;
      }).toList();
      _updateDerivedLists(updatedList);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> updateProgress(String bookId, int readPages) async {}
  Future<void> removeSavedBook(String bookId) async {}
  Future<void> toggleSaveBook(dynamic book) async {}
  void readAgain(String bookId) {}
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier(ref);
});

LearningResource? findResourceById(String id, List<LearningResource> resources) {
  try {
    return resources.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
}
