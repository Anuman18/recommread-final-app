import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';

// ── Reusable book cover ────────────────────────────────────────────────────

class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({
    super.key,
    required this.book,
    required this.width,
    required this.height,
    this.borderRadius = 14,
    this.showRating = false,
  });

  final Book book;
  final double width;
  final double height;
  final double borderRadius;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: book.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: book.coverColors.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.coverEmoji,
                  style: TextStyle(fontSize: height * 0.18),
                ),
                const Spacer(),
                Text(
                  book.title,
                  style: GoogleFonts.inter(
                    fontSize: (height * 0.075).clamp(9, 13),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showRating) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vertical book card (AI picks, Trending) ────────────────────────────────

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.book,
    this.width = 148,
    this.showRank,
    this.onTap,
  });

  final Book book;
  final double width;
  final int? showRank;
  final VoidCallback? onTap;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnim =
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.width * 1.35;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover with optional rank badge
              Stack(
                children: [
                  BookCoverWidget(
                    book: widget.book,
                    width: widget.width,
                    height: cardHeight,
                    showRating: true,
                  ),
                  if (widget.showRank != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.darkBg.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${widget.showRank}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                widget.book.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Author
              Text(
                widget.book.author,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              // Genre chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.book.coverColors.first
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.book.genre,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: widget.book.coverColors.first
                        .withValues(alpha: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small horizontal book card (Recently Viewed) ──────────────────────────

class SmallBookCard extends StatefulWidget {
  const SmallBookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  final Book book;
  final VoidCallback? onTap;

  @override
  State<SmallBookCard> createState() => _SmallBookCardState();
}

class _SmallBookCardState extends State<SmallBookCard>
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
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCoverWidget(
                book: widget.book,
                width: 120,
                height: 155,
                borderRadius: 12,
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
            ],
          ),
        ),
      ),
    );
  }
}
