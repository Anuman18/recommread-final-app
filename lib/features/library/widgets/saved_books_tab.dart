import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../home/widgets/book_card.dart';
import '../../../../models/book_model.dart';
import '../library_provider.dart';
import 'library_empty_state.dart';

class SavedBooksTab extends ConsumerWidget {
  const SavedBooksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final books = libraryState.saved;

    if (books.isEmpty) {
      return const LibraryEmptyState(
        emoji: '🔖',
        title: 'No Saved Books',
        description: 'Save recommendations from your coach to build your list.',
        buttonText: 'Discover Books',
      );
    }

    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey(book.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (value * 0.1),
                child: child,
              ),
            );
          },
          child: _SavedBookCard(book: book),
        );
      },
    );
  }
}

class _SavedBookCard extends ConsumerStatefulWidget {
  const _SavedBookCard({required this.book});
  final Book book;

  @override
  ConsumerState<_SavedBookCard> createState() => _SavedBookCardState();
}

class _SavedBookCardState extends ConsumerState<_SavedBookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.95,
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

  void _onTap() {
    context.push(
      '/book/${widget.book.id}?heroTag=book-cover-library-saved-${widget.book.id}',
      extra: widget.book,
    );
  }

  void _removeBook() {
    HapticFeedback.mediumImpact();
    
    // Smooth exit indicator or simple removal
    ref.read(libraryProvider.notifier).removeSavedBook(widget.book.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: [
            const Icon(Icons.bookmark_remove_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Removed "${widget.book.title}" from saved list.',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(libraryProvider.notifier).toggleSaveBook(widget.book);
              },
              child: Text(
                'UNDO',
                style: GoogleFonts.inter(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
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
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: _onTap,
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Hero(
                      tag: 'book-cover-library-saved-${widget.book.id}',
                      child: BookCoverWidget(
                        book: widget.book,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 14,
                      ),
                    ),
                    // Floating bookmark tag removal
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkBg.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: _removeBook,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.bookmark_added_rounded,
                                size: 16,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.book.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Author
              Text(
                widget.book.author,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Bottom details (Rating & Remove button icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        widget.book.rating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _removeBook,
                    child: const Icon(
                      Icons.bookmark_remove_rounded,
                      size: 15,
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
