import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';
import '../../models/book_model.dart';
import 'reading_provider.dart';
import '../profile/xp_provider.dart';
import 'widgets/chapter_list_sheet.dart';
import 'widgets/reading_settings_sheet.dart';
import 'widgets/mission_completed_dialog.dart';
import '../ai_learning_engine/widgets/ai_learning_sheets.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.book});
  final Book book;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  late final PageController _pageController;
  Timer? _readingTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Reading session timer tracking
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        ref.read(readingSessionProvider(widget.book).notifier).incrementTimer();
      }
    });
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onChapterChanged(int index) {
    HapticFeedback.selectionClick();
    ref.read(readingSessionProvider(widget.book).notifier).changeChapter(index);
  }

  Future<void> _completeMission() async {
    HapticFeedback.heavyImpact();
    await ref.read(xpProvider.notifier).completeMission(widget.book);
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MissionCompletedDialog(book: widget.book),
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ── Show AI Help Bottom Overlay ──────────────────────────────────────────

  void _showAiHelpSheet(ReadingSettingsState settings, int currentChIdx) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AiTutorSheet(book: widget.book, chapterIndex: currentChIdx);
      },
    );
  }

  // ── Show Inline Annotations sheet ────────────────────────────────────────

  void _showParagraphOptions(String text, ReadingSettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getBgColor(settings.themeMode),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: _getBorderColor(settings.themeMode), width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selected Text Actions',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _getTextColor(settings.themeMode),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Highlights color row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHighlightColorButton(context, text, Colors.yellow, 0xFFFFF59D),
                  _buildHighlightColorButton(context, text, Colors.greenAccent, 0xFFA5D6A7),
                  _buildHighlightColorButton(context, text, Colors.pinkAccent, 0xFFF48FB1),
                ],
              ),
              const SizedBox(height: 20),

              // Share / Notes ListTiles
              ListTile(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.darkSurface,
                      content: Text('Quote copied to clipboard', style: GoogleFonts.inter(fontSize: 12)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                leading: const Icon(Icons.share_rounded, color: AppColors.gold, size: 18),
                title: Text('Copy & Share Quote', style: GoogleFonts.inter(color: _getTextColor(settings.themeMode), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _showAddNoteSheet(text, settings);
                },
                leading: const Icon(Icons.notes_rounded, color: AppColors.gold, size: 18),
                title: Text('Add Reading Note', style: GoogleFonts.inter(color: _getTextColor(settings.themeMode), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightColorButton(BuildContext context, String text, Color color, int colorHex) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(readingSessionProvider(widget.book).notifier).addHighlight(text, colorHex);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkSurface,
            content: Text('Text highlighted successfully', style: GoogleFonts.inter(fontSize: 12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: const Icon(Icons.brush_rounded, size: 16, color: Colors.white),
      ),
    );
  }

  void _showAddNoteSheet(String text, ReadingSettingsState settings) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _getBgColor(settings.themeMode),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Note',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _getTextColor(settings.themeMode),
                  ),
                ),
                const SizedBox(height: 14),
                // Quote Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTextColor(settings.themeMode).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"$text"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: _getTextColor(settings.themeMode).withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: _getTextColor(settings.themeMode)),
                  decoration: InputDecoration(
                    hintText: 'Type your annotation here...',
                    hintStyle: GoogleFonts.inter(color: _getTextColor(settings.themeMode).withValues(alpha: 0.4)),
                    border: InputBorder.none,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  onPressed: () {
                    final noteText = noteController.text.trim();
                    if (noteText.isNotEmpty) {
                      ref.read(readingSessionProvider(widget.book).notifier).addNote(text, noteText);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.darkSurface,
                          content: Text('Note added to chapter', style: GoogleFonts.inter(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Save Note',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Render Helpers ───────────────────────────────────────────────────────

  Color _getBgColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.white;
      case 'Sepia':
        return const Color(0xFFFBF0D9);
      default:
        return AppColors.darkBg;
    }
  }

  Color _getTextColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.black;
      case 'Sepia':
        return const Color(0xFF5C4033);
      default:
        return AppColors.textPrimaryDark;
    }
  }

  Color _getBorderColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.grey.shade300;
      case 'Sepia':
        return const Color(0xFFE2D6B5);
      default:
        return AppColors.darkBorder;
    }
  }

  TextStyle _getFontFamilyStyle(String font) {
    switch (font) {
      case 'Serif':
        return GoogleFonts.merriweather();
      case 'Monospace':
        return GoogleFonts.firaCode();
      default:
        return GoogleFonts.inter();
    }
  }

  String _formatTimer(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    final String secStr = secs < 10 ? '0$secs' : '$secs';
    return '$mins:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(readingSessionProvider(widget.book));
    final settings = session.settings;
    final chapters = kMockBookContents[widget.book.id] ?? kFallbackChapters;

    ref.listen<ReadingSessionState>(
      readingSessionProvider(widget.book),
      (previous, next) {
        if ((previous == null || previous.isProgressLoading) && !next.isProgressLoading) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(next.currentChapterIndex);
          }
        }
      },
    );

    if (session.isProgressLoading) {
      return Scaffold(
        backgroundColor: _getBgColor(settings.themeMode),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBgColor(settings.themeMode),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _showAiHelpSheet(settings, session.currentChapterIndex),
        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.darkBg),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Custom AppBar ──────────────────────────────────────────────
            _buildAppBar(session, settings, chapters),

            // ── Swipeable Reader Body (PageView) ───────────────────────────
            Expanded(
              child: chapters.isEmpty
                  ? _buildEmptyState(settings)
                  : PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: _onChapterChanged,
                      itemCount: chapters.length,
                      itemBuilder: (context, chapterIndex) {
                        final ch = chapters[chapterIndex];
                        return _buildChapterContentView(ch, session, settings);
                      },
                    ),
            ),

            // ── Footer Reading Status Bar ──────────────────────────────────
            _buildFooterBar(session, settings, chapters),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ReadingSessionState session, ReadingSettingsState settings, List<Chapter> chapters) {
    final isBookmarked = session.bookmarkedChapters.contains(session.currentChapterIndex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _getBorderColor(settings.themeMode), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _getTextColor(settings.themeMode), size: 18),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          
          Row(
            children: [
              // Index Contents
              IconButton(
                icon: Icon(Icons.format_list_bulleted_rounded, color: _getTextColor(settings.themeMode), size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ChapterListSheet(
                      book: widget.book,
                      onChapterSelected: (idx) {
                        _pageController.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  );
                },
              ),

              // Bookmark
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.gold : _getTextColor(settings.themeMode),
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(readingSessionProvider(widget.book).notifier).toggleBookmark();
                },
              ),

              // Settings
              IconButton(
                icon: Icon(Icons.text_fields_rounded, color: _getTextColor(settings.themeMode), size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ReadingSettingsSheet(book: widget.book),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChapterContentView(Chapter ch, ReadingSessionState session, ReadingSettingsState settings) {
    final style = _getFontFamilyStyle(settings.fontFamily).copyWith(
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      color: _getTextColor(settings.themeMode),
    );

    // Split text into paragraphs
    final paragraphs = ch.content.split('\n\n');

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: settings.pageMargin,
        vertical: 24,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: paragraphs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Chapter Title
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              ch.title,
              style: GoogleFonts.inter(
                fontSize: settings.fontSize + 6,
                fontWeight: FontWeight.w800,
                color: _getTextColor(settings.themeMode),
                letterSpacing: -0.5,
              ),
            ),
          );
        }

        final p = paragraphs[index - 1];

        // Check if paragraph has highlight matching it
        final highlight = session.highlights.firstWhere(
          (h) => h.chapterIndex == session.currentChapterIndex && h.text == p,
          orElse: () => Highlight(chapterIndex: -1, text: '', colorHex: 0),
        );

        final isHighlighted = highlight.chapterIndex != -1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              _showParagraphOptions(p, settings);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: isHighlighted ? const EdgeInsets.all(8) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isHighlighted ? Color(highlight.colorHex).withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p,
                style: style,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterBar(ReadingSessionState session, ReadingSettingsState settings, List<Chapter> chapters) {
    final int total = chapters.length;
    final int current = session.currentChapterIndex + 1;
    final double pct = total > 0 ? (current / total) * 100 : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _getBorderColor(settings.themeMode), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: _getTextColor(settings.themeMode), size: 18),
            onPressed: session.currentChapterIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),

          // Reading statistics (Timer + Percentage)
          Column(
            children: [
              Text(
                'Chapter $current of $total (${pct.round()}%)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(settings.themeMode),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 10, color: _getTextColor(settings.themeMode).withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(session.activeReadingSeconds),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _getTextColor(settings.themeMode).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Next Button or Complete Mission
          session.currentChapterIndex == (total - 1)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBg,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _completeMission,
                  child: Text(
                    'Complete',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.arrow_forward_rounded, color: _getTextColor(settings.themeMode), size: 18),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ReadingSettingsState settings) {
    return Center(
      child: Text(
        'Book content unavailable',
        style: GoogleFonts.inter(color: _getTextColor(settings.themeMode)),
      ),
    );
  }
}
