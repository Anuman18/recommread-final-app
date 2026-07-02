import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../../models/book_model.dart';
import '../library/library_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────────

class Highlight {
  final int chapterIndex;
  final String text;
  final int colorHex;

  Highlight({
    required this.chapterIndex,
    required this.text,
    required this.colorHex,
  });
}

class ReadingNote {
  final int chapterIndex;
  final String noteText;
  final String selectedText;
  final DateTime createdAt;

  ReadingNote({
    required this.chapterIndex,
    required this.noteText,
    required this.selectedText,
    required this.createdAt,
  });
}

class ReadingSettingsState {
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double pageMargin;
  final String themeMode; // 'Light', 'Dark', 'Sepia'

  ReadingSettingsState({
    required this.fontSize,
    required this.fontFamily,
    required this.lineHeight,
    required this.pageMargin,
    required this.themeMode,
  });

  ReadingSettingsState copyWith({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? pageMargin,
    required String themeMode,
  }) {
    return ReadingSettingsState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      pageMargin: pageMargin ?? this.pageMargin,
      themeMode: themeMode,
    );
  }
}

class ReadingSessionState {
  final Book book;
  final int currentChapterIndex;
  final Set<int> bookmarkedChapters;
  final List<Highlight> highlights;
  final List<ReadingNote> notes;
  final ReadingSettingsState settings;
  final int activeReadingSeconds;
  final bool isProgressLoading;

  ReadingSessionState({
    required this.book,
    required this.currentChapterIndex,
    required this.bookmarkedChapters,
    required this.highlights,
    required this.notes,
    required this.settings,
    this.activeReadingSeconds = 0,
    this.isProgressLoading = true,
  });

  ReadingSessionState copyWith({
    Book? book,
    int? currentChapterIndex,
    Set<int>? bookmarkedChapters,
    List<Highlight>? highlights,
    List<ReadingNote>? notes,
    ReadingSettingsState? settings,
    int? activeReadingSeconds,
    bool? isProgressLoading,
  }) {
    return ReadingSessionState(
      book: book ?? this.book,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      bookmarkedChapters: bookmarkedChapters ?? this.bookmarkedChapters,
      highlights: highlights ?? this.highlights,
      notes: notes ?? this.notes,
      settings: settings ?? this.settings,
      activeReadingSeconds: activeReadingSeconds ?? this.activeReadingSeconds,
      isProgressLoading: isProgressLoading ?? this.isProgressLoading,
    );
  }
}

// ── Mock Chapters Content ──────────────────────────────────────────────────

class Chapter {
  final String title;
  final String content;

  const Chapter({required this.title, required this.content});
}

final Map<String, List<Chapter>> kMockBookContents = {
  'b1': [
    const Chapter(
      title: '1. The Surprising Power of Atomic Habits',
      content: 'In 2003, British Cycling hired Dave Brailsford as its new performance director. At the time, professional cyclists in Great Britain had endured nearly one hundred years of mediocrity.\n\nBrailsford had been hired to put British Cycling on a new trajectory. What made him different from previous coaches was his relentless commitment to a strategy that he referred to as **the aggregation of marginal gains**, which was the philosophy of searching for a tiny margin of improvement in everything you do.\n\nBrailsford said, "The whole principle came from the idea that if you broke down everything you could think of that goes into riding a bike, and then improve it by 1 percent, you will get a significant increase when you put them all together."\n\nThey redesigned the bike seats to make them more comfortable and rubbed alcohol on the tires for a better grip. They asked riders to wear electrically heated overshorts to maintain muscle temperature and used biofeedback sensors to monitor how each rider responded to a workout.\n\nThey tested different fabrics in a wind tunnel and had their outdoor riders switch to indoor racing suits, which proved to be lighter and more aerodynamic.\n\nBut they didn\'t stop there. Brailsford and his team continued to find 1 percent improvements in overlooked and unexpected areas. They tested different types of massage gels to see which one led to the fastest muscle recovery. They hired a surgeon to teach each rider the best way to wash their hands to reduce the chances of catching a cold.\n\nThey determined the one type of pillow and mattress that led to the best night\'s sleep for each rider. They even painted the inside of the team truck white, which helped them spot little bits of dust that would otherwise go unnoticed and could degrade the performance of the finely tuned bikes.\n\nAs these and hundreds of other small improvements accumulated, the results came faster than anyone could have imagined. Just five years after Brailsford took over, the British Cycling team dominated the road and track cycling events at the 2008 Olympic Games in Beijing, where they won an astounding 60 percent of the gold medals available.',
    ),
    const Chapter(
      title: '2. How Your Habits Shape Your Identity',
      content: 'Why is it so easy to repeat bad habits and so hard to build good ones? Few things can have a more powerful impact on your life than improving your daily habits. And yet, it is highly likely that this time next year you will be doing the same thing rather than something better.\n\nIt often feels like change is impossible. We try to build a habit of reading more or exercising, but after a few days, the initial motivation fades and we return to our old paths.\n\nTo understand why this happens, we must realize that there are **three layers of behavior change**:\n\n*   **Outcomes**: This layer is about changing your results. Losing weight, writing a book, winning a championship. Most of the goals you set are associated with this level.\n*   **Processes**: This layer is about changing your habits and systems. Implementing a new routine at the gym, decluttering your desk for better focus, developing a reading stack.\n*   **Identity**: This layer is about changing your beliefs. Your worldview, your self-image, your judgments about yourself and others. Most of the beliefs you hold are associated with this level.\n\nMany people begin the process of changing their habits by focusing on *what* they want to achieve. This leads us to **outcome-based habits**. The alternative is to build **identity-based habits**. With this approach, we start by focusing on *who* we wish to become.\n\nImagine two people resisting a cigarette. When offered a smoke, the first person says, "No thanks, I’m trying to quit." It sounds like a reasonable response, but this person still believes they are a smoker who is trying to be something else. They are hoping their behavior will change while carrying the same beliefs.\n\nThe second person declines by saying, "No thanks, I’m not a smoker." It’s a tiny difference, but this statement signals a shift in identity. Smoking was part of their past life, not their current identity. They no longer identify as a smoker.',
    ),
    const Chapter(
      title: '3. How to Build Better Habits in 4 Steps',
      content: 'A habit is a behavior that has been repeated enough times to become automatic. The process of habit formation begins with trial and error. Whenever you encounter a new situation in life, your brain has to make a decision: How do I respond to this?\n\nThe first time you encounter a problem, you\'re not sure how to solve it. You try different responses to see what works. As you repeat these actions, your brain automates the process. This is the origin of habits.\n\nBehavioral science shows that this loop can be broken down into **four simple steps**: **Cue, Craving, Response, and Reward**.\n\n1.  **Cue**: The cue triggers your brain to initiate a behavior. It is a bit of information that predicts a reward. Our prehistoric ancestors paid attention to cues that signaled the location of primary rewards like food or water. Today, we spend most of our time learning cues that predict secondary rewards like money, fame, power, or approval.\n2.  **Craving**: Cravings are the motivational force behind every habit. Without some level of motivation or desire—without craving a change—we have no reason to act. What you crave is not the habit itself, but the change in state it delivers. You do not crave smoking a cigarette; you crave the feeling of relaxation it provides.\n3.  **Response**: The response is the actual habit you perform, which can take the form of a thought or an action. Whether a response occurs depends on how motivated you are and how much friction is associated with the behavior. If an action requires more physical or mental effort than you are willing to expend, then you won\'t do it.\n4.  **Reward**: Cravings are about wanting the change. Responses are about obtaining the change. Rewards are the end goal of every habit. We chase rewards because they serve two purposes: they satisfy our cravings and they teach us which actions are worth remembering in the future.',
    ),
  ],
};

// Default fallback chapters for books not in kMockBookContents
final List<Chapter> kFallbackChapters = [
  const Chapter(title: 'Chapter 1: Foundations', content: 'This is the start of your learning path. Deep concepts are introduced here...'),
  const Chapter(title: 'Chapter 2: Core Application', content: 'Detailed implementation details and step-by-step principles...'),
  const Chapter(title: 'Chapter 3: Professional Mastery', content: 'Master class takeaways and continuous optimization patterns...'),
];

// ── Reading Provider Notifier ──────────────────────────────────────────────

class ReadingSessionNotifier extends StateNotifier<ReadingSessionState> {
  final Ref ref;

  ReadingSessionNotifier(this.ref, Book book)
      : super(ReadingSessionState(
          book: book,
          currentChapterIndex: 0,
          bookmarkedChapters: {},
          highlights: [],
          notes: [],
          settings: ReadingSettingsState(
            fontSize: 16.0,
            fontFamily: 'Serif',
            lineHeight: 1.5,
            pageMargin: 16.0,
            themeMode: 'Sepia',
          ),
          isProgressLoading: true,
        )) {
    loadProgress();
  }

  // Restore reading progress from API
  Future<void> loadProgress() async {
    try {
      final res = await apiClient.get('/api/v1/books/${state.book.id}');
      final map = Map<String, dynamic>.from(res as Map);
      
      final chapterIdx = (map['current_chapter_index'] as num?)?.toInt() ?? 0;
      final activeSecs = (map['active_reading_seconds'] as num?)?.toInt() ?? 0;
      
      final List<dynamic> bookmarksRaw = map['bookmarks'] ?? [];
      final bms = bookmarksRaw.map((b) => (b as num).toInt()).toList();

      final List<dynamic> highlightsRaw = map['highlights'] ?? [];
      final highlights = highlightsRaw.map((h) {
        final m = Map<String, dynamic>.from(h as Map);
        return Highlight(
          chapterIndex: (m['chapterIndex'] as num).toInt(),
          text: m['text']?.toString() ?? '',
          colorHex: (m['colorHex'] as num).toInt(),
        );
      }).toList();

      final List<dynamic> notesRaw = map['notes'] ?? [];
      final notes = notesRaw.map((n) {
        final m = Map<String, dynamic>.from(n as Map);
        return ReadingNote(
          chapterIndex: (m['chapterIndex'] as num).toInt(),
          selectedText: m['selectedText']?.toString() ?? '',
          noteText: m['noteText']?.toString() ?? '',
          createdAt: DateTime.parse(m['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      state = state.copyWith(
        currentChapterIndex: chapterIdx,
        activeReadingSeconds: activeSecs,
        bookmarkedChapters: bms.toSet(),
        highlights: highlights,
        notes: notes,
        isProgressLoading: false,
      );
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final chapterIndex = prefs.getInt('reading_chapter_${state.book.id}') ?? 0;
      final seconds = prefs.getInt('reading_seconds_${state.book.id}') ?? 0;
      state = state.copyWith(
        currentChapterIndex: chapterIndex,
        activeReadingSeconds: seconds,
        isProgressLoading: false,
      );
    }
  }

  Future<void> _syncToBackend() async {
    try {
      final body = {
        'current_chapter_index': state.currentChapterIndex,
        'active_reading_seconds': state.activeReadingSeconds,
        'bookmarks': state.bookmarkedChapters.toList(),
        'highlights': state.highlights.map((h) => {
          'chapterIndex': h.chapterIndex,
          'text': h.text,
          'colorHex': h.colorHex,
        }).toList(),
        'notes': state.notes.map((n) => {
          'chapterIndex': n.chapterIndex,
          'selectedText': n.selectedText,
          'noteText': n.noteText,
          'createdAt': n.createdAt.toIso8601String(),
        }).toList(),
      };
      await apiClient.post('/api/v1/books/${state.book.id}/sync', body: body);
    } catch (_) {}
  }

  void incrementTimer() {
    state = state.copyWith(activeReadingSeconds: state.activeReadingSeconds + 1);
    // Sync active reading duration periodically (e.g. every 30 seconds)
    if (state.activeReadingSeconds % 30 == 0) {
      _syncToBackend();
    }
  }

  // Save current chapter and update total pages progress
  Future<void> changeChapter(int index) async {
    final bookId = state.book.id;
    final totalChapters = (kMockBookContents[bookId] ?? kFallbackChapters).length;
    if (index >= 0 && index < totalChapters) {
      state = state.copyWith(currentChapterIndex: index);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reading_chapter_$bookId', index);

      final fraction = (index + 1) / totalChapters;
      final pagesCompleted =
          (state.book.totalPages * fraction).round().clamp(0, state.book.totalPages);
      await ref.read(libraryProvider.notifier).updateProgress(bookId, pagesCompleted);
      
      _syncToBackend();
    }
  }

  void toggleBookmark() {
    final updatedBookmarks = Set<int>.from(state.bookmarkedChapters);
    if (updatedBookmarks.contains(state.currentChapterIndex)) {
      updatedBookmarks.remove(state.currentChapterIndex);
    } else {
      updatedBookmarks.add(state.currentChapterIndex);
    }
    state = state.copyWith(bookmarkedChapters: updatedBookmarks);
    _syncToBackend();
  }

  void addHighlight(String text, int colorHex) {
    final highlight = Highlight(
      chapterIndex: state.currentChapterIndex,
      text: text,
      colorHex: colorHex,
    );
    state = state.copyWith(highlights: [...state.highlights, highlight]);
    _syncToBackend();
  }

  void addNote(String selectedText, String noteText) {
    final note = ReadingNote(
      chapterIndex: state.currentChapterIndex,
      selectedText: selectedText,
      noteText: noteText,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(notes: [...state.notes, note]);
    _syncToBackend();
  }

  void updateSettings({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? pageMargin,
    required String themeMode,
  }) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        fontSize: fontSize,
        fontFamily: fontFamily,
        lineHeight: lineHeight,
        pageMargin: pageMargin,
        themeMode: themeMode,
      ),
    );
  }
}

// ── Family Provider to track reading session per book ──────────────────────

final readingSessionProvider = StateNotifierProvider.family<ReadingSessionNotifier, ReadingSessionState, Book>((ref, book) {
  return ReadingSessionNotifier(ref, book);
});
