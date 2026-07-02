import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../home/widgets/book_card.dart';
import '../../../../models/book_model.dart';
import '../library_provider.dart';
import 'library_empty_state.dart';

class ContinueReadingTab extends ConsumerWidget {
  const ContinueReadingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final books = libraryState.continueReading;

    if (books.isEmpty) {
      return const LibraryEmptyState(
        emoji: '📖',
        title: 'Your Reading Shelf is Empty',
        description: 'Start your coaching journey by selecting a book to read.',
        buttonText: 'Browse Books',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        return TweenAnimationBuilder<double>(
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
          child: _ContinueReadingCard(book: book),
        );
      },
    );
  }
}

class _ContinueReadingCard extends ConsumerStatefulWidget {
  const _ContinueReadingCard({required this.book});
  final Book book;

  @override
  ConsumerState<_ContinueReadingCard> createState() => _ContinueReadingCardState();
}

class _ContinueReadingCardState extends ConsumerState<_ContinueReadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: widget.book.progress).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
    );
    _progressCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant _ContinueReadingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.readPages != widget.book.readPages) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.book.progress,
      ).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic),
      );
      _progressCtrl.reset();
      _progressCtrl.forward();
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  void _showUpdateProgressDialog() {
    int localPages = widget.book.readPages;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double pct = (localPages / widget.book.totalPages) * 100;
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Update Reading Progress',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.book.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$localPages pages read',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        '${pct.round()}% completed',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.gold,
                      inactiveTrackColor: AppColors.darkBorder,
                      thumbColor: AppColors.goldLight,
                      overlayColor: AppColors.gold.withValues(alpha: 0.15),
                      trackHeight: 6,
                      valueIndicatorColor: AppColors.goldDark,
                      valueIndicatorTextStyle: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Slider(
                      value: localPages.toDouble(),
                      min: 0,
                      max: widget.book.totalPages.toDouble(),
                      divisions: widget.book.totalPages,
                      label: '$localPages',
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setModalState(() {
                          localPages = val.round();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedButton(
                    onPressed: () {
                      ref.read(libraryProvider.notifier).updateProgress(
                            widget.book.id,
                            localPages,
                          );
                      Navigator.pop(context);
                      // Premium success celebration overlay if completed
                      if (localPages >= widget.book.totalPages) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.success.withValues(alpha: 0.15),
                            content: Row(
                              children: [
                                const Text('🎉', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Congratulations! "${widget.book.title}" added to Completed Books.',
                                    style: GoogleFonts.inter(
                                      color: AppColors.success,
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
                    },
                    child: Text(
                      'Save Progress',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Hero(
            tag: 'book-cover-library-continue-${widget.book.id}',
            child: GestureDetector(
              onTap: () => context.push(
                '/book/${widget.book.id}?heroTag=book-cover-library-continue-${widget.book.id}',
                extra: widget.book,
              ),
              child: BookCoverWidget(
                book: widget.book,
                width: 90,
                height: 125,
                borderRadius: 14,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Details & progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/book/${widget.book.id}', extra: widget.book),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.book.author,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Progress Indicator
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, child) {
                    final pct = (_progressAnim.value * 100).round();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _showUpdateProgressDialog,
                              child: Row(
                                children: [
                                  Text(
                                    widget.book.progressLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textTertiaryDark,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_rounded,
                                    size: 11,
                                    color: AppColors.textTertiaryDark,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressAnim.value,
                            backgroundColor: AppColors.darkBorder,
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        height: 38,
                        borderRadius: 12,
                        onPressed: () {
                          context.push('/book/${widget.book.id}', extra: widget.book);
                        },
                        child: Text(
                          'Resume Reading',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.darkElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_task_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        onPressed: _showUpdateProgressDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
