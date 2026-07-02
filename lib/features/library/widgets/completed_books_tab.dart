import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../home/widgets/book_card.dart';
import '../library_provider.dart';
import 'library_empty_state.dart';

class CompletedBooksTab extends ConsumerWidget {
  const CompletedBooksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final completed = libraryState.completed;

    if (completed.isEmpty) {
      return const LibraryEmptyState(
        emoji: '🏆',
        title: 'No Completed Books Yet',
        description: 'Complete books in your Continue Reading shelf to earn achievements.',
        buttonText: 'Start Reading',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final completedBook = completed[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey(completedBook.book.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 150)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _CompletedBookCard(completedBook: completedBook),
        );
      },
    );
  }
}

class _CompletedBookCard extends ConsumerStatefulWidget {
  const _CompletedBookCard({required this.completedBook});
  final CompletedBook completedBook;

  @override
  ConsumerState<_CompletedBookCard> createState() => _CompletedBookCardState();
}

class _CompletedBookCardState extends ConsumerState<_CompletedBookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onReadAgain() {
    HapticFeedback.mediumImpact();
    ref.read(libraryProvider.notifier).readAgain(widget.completedBook.book.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Moved "${widget.completedBook.book.title}" back to Continue Reading.',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.completedBook.book;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: () {
        context.push(
          '/book/${book.id}?heroTag=book-cover-library-completed-${book.id}',
          extra: book,
        );
      },
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.darkBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Hero(
                tag: 'book-cover-library-completed-${book.id}',
                child: BookCoverWidget(
                  book: book,
                  width: 75,
                  height: 108,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryDark,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                book.author,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Golden celebration badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_rounded, size: 10, color: AppColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                'Read',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Completion date
                    Text(
                      'Completed: ${widget.completedBook.completedDate}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating & Read Again button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Star Rating
                        Row(
                          children: List.generate(5, (i) {
                            final double starValue = i + 1.0;
                            final isFilled = widget.completedBook.userRating >= starValue;
                            return Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: isFilled ? AppColors.gold : AppColors.darkBorder,
                            );
                          }),
                        ),

                        // Read again button
                        AnimatedButton(
                          height: 28,
                          borderRadius: 8,
                          onPressed: _onReadAgain,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 11, color: AppColors.darkBg),
                                const SizedBox(width: 4),
                                Text(
                                  'Read Again',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
