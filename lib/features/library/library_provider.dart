import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../core/services/api_client.dart';

// ── Completed Book Model ───────────────────────────────────────────────────

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

// ── Library State ──────────────────────────────────────────────────────────

class LibraryState {
  final List<Book> continueReading;
  final List<Book> saved;
  final List<CompletedBook> completed;
  final bool isLoading;

  LibraryState({
    required this.continueReading,
    required this.saved,
    required this.completed,
    required this.isLoading,
  });

  LibraryState copyWith({
    List<Book>? continueReading,
    List<Book>? saved,
    List<CompletedBook>? completed,
    bool? isLoading,
  }) {
    return LibraryState(
      continueReading: continueReading ?? this.continueReading,
      saved: saved ?? this.saved,
      completed: completed ?? this.completed,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Library State Notifier ─────────────────────────────────────────────────

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier()
      : super(LibraryState(
          continueReading: [],
          saved: [],
          completed: [],
          isLoading: true,
        )) {
    loadLibraryData();
  }

  Future<void> loadLibraryData() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Fetch saved books
      final savedJson = await apiClient.get('/library');
      final List<Book> savedList = (savedJson as List).map((item) {
        final bookMap = item['book'];
        return Book.fromJson(Map<String, dynamic>.from(bookMap));
      }).toList();

      // 2. Fetch reading progress logs
      final progressJson = await apiClient.get('/reading/progress');
      final List<Book> continueList = [];
      final List<CompletedBook> completedList = [];

      for (final item in progressJson as List) {
        final bookMap = item['book'];
        final book = Book.fromJson(Map<String, dynamic>.from(bookMap)).copyWith(
          readPages: item['read_pages'] ?? 0,
        );

        if (item['is_completed'] == true) {
          completedList.add(CompletedBook(
            book: book,
            completedDate: item['completed_date'] ?? 'June 18, 2026',
            userRating: 5.0, // Default rating
          ));
        } else {
          continueList.add(book);
        }
      }

      state = LibraryState(
        continueReading: continueList,
        saved: savedList,
        completed: completedList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadLibraryData();
  }

  // Update pages progress
  Future<void> updateProgress(String bookId, int readPages) async {
    try {
      // Optimistic local state update to prevent UI stutter/lags
      state = state.copyWith(
        continueReading: state.continueReading.map((book) {
          if (book.id == bookId) {
            return book.copyWith(readPages: readPages);
          }
          return book;
        }).toList(),
      );

      // Sync progress to backend
      await apiClient.post('/reading/progress', body: {
        'book_id': bookId,
        'read_pages': readPages,
      });

      // Fetch fresh state to update list placements (e.g. move to completed list)
      await loadLibraryData();
    } catch (_) {}
  }

  // Remove saved book
  Future<void> removeSavedBook(String bookId) async {
    try {
      state = state.copyWith(
        saved: state.saved.where((book) => book.id != bookId).toList(),
      );
      await apiClient.delete('/library/remove/$bookId');
    } catch (_) {}
  }

  // Toggle save book
  Future<void> toggleSaveBook(Book book) async {
    final isAlreadySaved = state.saved.any((b) => b.id == book.id);
    try {
      if (isAlreadySaved) {
        await removeSavedBook(book.id);
      } else {
        state = state.copyWith(
          saved: [...state.saved, book],
        );
        await apiClient.post('/library/save?book_id=${book.id}');
      }
    } catch (_) {}
  }

  // Move book to completed
  Future<void> completeBook(String bookId, double rating) async {
    try {
      final bookIndex = state.continueReading.indexWhere((b) => b.id == bookId);
      if (bookIndex != -1) {
        final book = state.continueReading[bookIndex];
        await updateProgress(bookId, book.totalPages);
      }
    } catch (_) {}
  }

  // Read again
  Future<void> readAgain(String bookId) async {
    try {
      await updateProgress(bookId, 0);
    } catch (_) {}
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
