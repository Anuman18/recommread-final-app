import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';

/// Related books + similar authors horizontal carousels.
class RelatedSection extends StatelessWidget {
  const RelatedSection({
    super.key,
    required this.sectionTitle,
    required this.books,
  });

  final String sectionTitle;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            sectionTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.4,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: books.length,
            itemBuilder: (context, i) {
              return _RelatedCard(book: books[i]);
            },
          ),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatefulWidget {
  const _RelatedCard({required this.book});
  final Book book;

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard>
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
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: () => context.push(
        '/book/${widget.book.id}',
        extra: widget.book,
      ),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Hero(
                tag: 'book-cover-related-${widget.book.id}',
                child: Container(
                  width: 120,
                  height: 155,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.book.coverColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.book.coverColors.first
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.book.coverEmoji,
                            style: const TextStyle(fontSize: 20)),
                        const Spacer(),
                        Text(
                          widget.book.title,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.book.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.book.author,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 11, color: AppColors.gold),
                  const SizedBox(width: 3),
                  Text(
                    widget.book.rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDark,
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
