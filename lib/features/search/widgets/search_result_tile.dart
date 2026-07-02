import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';

/// A single search result tile with Hero book cover + animated press.
class SearchResultTile extends StatefulWidget {
  const SearchResultTile({
    super.key,
    required this.book,
    required this.index,
    this.queryHighlight = '',
  });

  final Book book;
  final int index;
  final String queryHighlight;

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim =
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _navigate() {
    context.push('/book/${widget.book.id}', extra: widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: _navigate,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              // ── Hero Book Cover ───────────────────────────────────
              Hero(
                tag: 'book-cover-${widget.book.id}',
                child: _MiniBookCover(book: widget.book),
              ),
              const SizedBox(width: 14),

              // ── Book Info ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: widget.book.title,
                      highlight: widget.queryHighlight,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _HighlightedText(
                      text: widget.book.author,
                      highlight: widget.queryHighlight,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Genre badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.book.coverColors.first
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.book.genre,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.book.coverColors.first
                                  .withValues(alpha: 1.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Rating
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.book.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryDark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact cover for search results ──────────────────────────────────────

class _MiniBookCover extends StatelessWidget {
  const _MiniBookCover({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: book.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: book.coverColors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.coverEmoji,
                    style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Text(
                  book.title,
                  style: GoogleFonts.inter(
                    fontSize: 7,
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
        ],
      ),
    );
  }
}

// ── Text with highlighted query match ─────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.highlight,
    required this.style,
  });

  final String text;
  final String highlight;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style, maxLines: 1,
          overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final lowerHL = highlight.toLowerCase();
    final idx = lower.indexOf(lowerHL);

    if (idx < 0) {
      return Text(text, style: style, maxLines: 1,
          overflow: TextOverflow.ellipsis);
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + highlight.length),
            style: style.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(idx + highlight.length)),
        ],
      ),
    );
  }
}
