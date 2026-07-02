import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/book_model.dart';
import '../library/library_provider.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/related_section.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  const BookDetailsScreen({super.key, required this.book, this.heroTag});
  final Book book;
  final String? heroTag;

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _contentCtrl;
  late final List<Animation<double>> _sectionAnims;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sectionAnims = List.generate(6, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _contentCtrl,
        curve: Interval(
          0.1 + i * 0.1,
          (0.1 + i * 0.1 + 0.45).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });
    Future.delayed(
      const Duration(milliseconds: 200),
      () { if (mounted) _contentCtrl.forward(); },
    );
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Widget _fadeIn(int i, Widget child) => AnimatedBuilder(
        animation: _sectionAnims[i],
        builder: (_, c) => Opacity(
          opacity: _sectionAnims[i].value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _sectionAnims[i].value)),
            child: c,
          ),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final related = getRelatedBooks(book);
    final similar = getSimilarAuthorBooks(book);
    final aiReason = getAiRecommendationReason(book);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Main scroll content ──────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Large hero header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: AppColors.darkBg,
                leading: _BackButton(),
                actions: [
                  _ActionIconButton(
                    icon: ref.watch(libraryProvider).saved.any((b) => b.id == book.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: ref.watch(libraryProvider).saved.any((b) => b.id == book.id) ? AppColors.gold : AppColors.textPrimaryDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(libraryProvider.notifier).toggleSaveBook(book);
                    },
                  ),
                  _ActionIconButton(
                    icon: Icons.share_rounded,
                    color: AppColors.textPrimaryDark,
                    onTap: () => HapticFeedback.lightImpact(),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _HeroHeader(book: book, heroTag: widget.heroTag),
                ),
              ),

              // ── Book content ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Author + Rating
                    _fadeIn(
                      0,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryDark,
                                letterSpacing: -0.8,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'by ${book.author}',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _RatingRow(rating: book.rating),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Meta chips
                    _fadeIn(
                      1,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _MetaChips(book: book),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Description
                    _fadeIn(
                      2,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _DescriptionSection(book: book),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // AI recommendation
                    _fadeIn(
                      3,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AiRecommendationCard(reason: aiReason),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Related Books
                    _fadeIn(
                      4,
                      RelatedSection(
                        sectionTitle: '📚 Related Books',
                        books: related,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Similar Authors
                    _fadeIn(
                      5,
                      RelatedSection(
                        sectionTitle: '✍️ Similar Authors',
                        books: similar,
                      ),
                    ),

                    // Spacer for the sticky bottom bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Action Bar ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickyActionBar(
              book: book,
              isSaved: ref.watch(libraryProvider).saved.any((b) => b.id == book.id),
              onSave: () {
                HapticFeedback.mediumImpact();
                ref.read(libraryProvider.notifier).toggleSaveBook(book);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.book, this.heroTag});
  final Book book;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                book.coverColors[0].withValues(alpha: 0.6),
                book.coverColors[1].withValues(alpha: 0.3),
                AppColors.darkBg,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Decorative circles
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: book.coverColors.first.withValues(alpha: 0.15),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: book.coverColors.last.withValues(alpha: 0.1),
            ),
          ),
        ),
        // Hero Book cover centered
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Hero(
              tag: heroTag ?? 'book-cover-${book.id}',
              child: _LargeBookCover(book: book),
            ),
          ),
        ),
      ],
    );
  }
}

class _LargeBookCover extends StatelessWidget {
  const _LargeBookCover({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 270,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: book.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: book.coverColors.first.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.coverEmoji,
                  style: const TextStyle(fontSize: 46),
                ),
                const Spacer(),
                Text(
                  book.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  book.author,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating row ─────────────────────────────────────────────────────────────

class _RatingRow extends StatefulWidget {
  const _RatingRow({required this.rating});
  final double rating;

  @override
  State<_RatingRow> createState() => _RatingRowState();
}

class _RatingRowState extends State<_RatingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween<double>(begin: 0.0, end: widget.rating).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    Future.delayed(
      const Duration(milliseconds: 300),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        children: [
          ...List.generate(5, (i) {
            final filled = _anim.value >= i + 1;
            final partial = !filled && _anim.value > i;
            final fraction = partial ? _anim.value - i : 0.0;
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: partial
                  ? ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        stops: [fraction, fraction],
                        colors: const [AppColors.gold, AppColors.darkBorder],
                      ).createShader(bounds),
                      child: const Icon(Icons.star_rounded,
                          size: 20, color: Colors.white),
                    )
                  : Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: filled
                          ? AppColors.gold
                          : AppColors.darkBorder,
                    ),
            );
          }),
          const SizedBox(width: 10),
          Text(
            widget.rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(2.4k reviews)',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta chips ─────────────────────────────────────────────────────────────

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _chip(Icons.bolt, '${book.xpReward} XP')),
            const SizedBox(width: 8),
            Expanded(child: _chip(Icons.star_half_rounded, book.difficulty)),
            const SizedBox(width: 8),
            Expanded(child: _chip(Icons.schedule_rounded, book.estimatedTimeHours)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_rounded, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Skills Unlocked: ${book.skillsUnlocked.join(" & ")}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Description section ────────────────────────────────────────────────────

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection({required this.book});
  final Book book;

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fullText = '${widget.book.description}\n\nThis mission curriculum has influenced millions of professionals worldwide and continues to be a standard benchmark for personal strategy. You will gain actionable wisdom and practical exercises that can be directly applied to accelerate your identity shift.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why It Matters',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.book.whyItMatters,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.6,
            color: AppColors.gold,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mission Briefing',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstChild: Text(
            fullText,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textSecondaryDark,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            fullText,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textSecondaryDark,
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Read more...',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sticky action bar ─────────────────────────────────────────────────────

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({
    required this.book,
    required this.isSaved,
    required this.onSave,
  });

  final Book book;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: const Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Start Mission (primary)
          Expanded(
            child: _PrimaryButton(
              label: 'Start Mission',
              icon: Icons.menu_book_rounded,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/read/${book.id}', extra: book);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Save
          _IconActionButton(
            icon: isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            isActive: isSaved,
            onTap: onSave,
          ),
          const SizedBox(width: 10),
          // Share
          _IconActionButton(
            icon: Icons.share_rounded,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
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
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: AppColors.darkBg),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatefulWidget {
  const _IconActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.9,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.gold.withValues(alpha: 0.4)
                  : AppColors.darkBorder,
            ),
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive
                ? AppColors.gold
                : AppColors.textSecondaryDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── App bar buttons ────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkBg.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimaryDark,
          size: 18,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkBg.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
