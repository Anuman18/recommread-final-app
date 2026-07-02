import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_data.dart';
import '../../../models/book_model.dart';

// ── Search empty state: recent + trending + genres ─────────────────────────

class SearchEmptyState extends StatefulWidget {
  const SearchEmptyState({
    super.key,
    required this.onSearchTap,
    required this.onGenreTap,
  });

  final ValueChanged<String> onSearchTap;
  final ValueChanged<String> onGenreTap;

  @override
  State<SearchEmptyState> createState() => _SearchEmptyStateState();
}

class _SearchEmptyStateState extends State<SearchEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _sectionAnims;

  final _recentSearches = List<String>.from(kRecentSearches);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sectionAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(i * 0.15, (i * 0.15 + 0.55).clamp(0, 1),
            curve: Curves.easeOutCubic),
      ));
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _fadeSection(int i, Widget child) => AnimatedBuilder(
        animation: _sectionAnims[i],
        builder: (_, c) => Opacity(
          opacity: _sectionAnims[i].value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - _sectionAnims[i].value)),
            child: c,
          ),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 8),

        // ── Recent Searches ──────────────────────────────────────────
        if (_recentSearches.isNotEmpty)
          _fadeSection(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Searches',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _recentSearches.clear()),
                      child: Text(
                        'Clear all',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._recentSearches.map((q) => _RecentSearchTile(
                      query: q,
                      onTap: () => widget.onSearchTap(q),
                      onDelete: () =>
                          setState(() => _recentSearches.remove(q)),
                    )),
                const SizedBox(height: 28),
              ],
            ),
          ),

        // ── Trending Searches ────────────────────────────────────────
        _fadeSection(
          1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trending Searches 🔥',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 12),
              ...kTrendingSearches.asMap().entries.map(
                    (e) => _TrendingTile(
                      index: e.key + 1,
                      query: e.value,
                      onTap: () => widget.onSearchTap(e.value),
                    ),
                  ),
              const SizedBox(height: 28),
            ],
          ),
        ),

        // ── Popular Genres ───────────────────────────────────────────
        _fadeSection(
          2,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Genres',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kCategories
                    .map((cat) => _GenreChip(
                          category: cat,
                          onTap: () => widget.onGenreTap(cat.label),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Recent search tile ─────────────────────────────────────────────────────

class _RecentSearchTile extends StatelessWidget {
  const _RecentSearchTile({
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.textTertiaryDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                query,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trending tile ─────────────────────────────────────────────────────────

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({
    required this.index,
    required this.query,
    required this.onTap,
  });

  final int index;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: index <= 3
                      ? AppColors.gold
                      : AppColors.textTertiaryDark,
                ),
              ),
            ),
            Expanded(
              child: Text(
                query,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            const Icon(
              Icons.north_west_rounded,
              size: 14,
              color: AppColors.textTertiaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Genre chip ─────────────────────────────────────────────────────────────

class _GenreChip extends StatefulWidget {
  const _GenreChip({required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  State<_GenreChip> createState() => _GenreChipState();
}

class _GenreChipState extends State<_GenreChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.category.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: widget.category.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.category.emoji,
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Text(
                widget.category.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.category.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
