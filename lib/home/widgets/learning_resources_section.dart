import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';
import '../../features/library/library_provider.dart' as lib;

class LearningResourcesSection extends StatefulWidget {
  const LearningResourcesSection({super.key, required this.resources});
  final List<LearningResource> resources;

  @override
  State<LearningResourcesSection> createState() => _LearningResourcesSectionState();
}

class _LearningResourcesSectionState extends State<LearningResourcesSection> {
  String _selectedFilter = 'All';

  final _filters = ['All', 'Docs', 'Video', 'Course', 'Practice', 'Project', 'Blog'];

  List<LearningResource> get _filtered {
    if (_selectedFilter == 'All') return widget.resources;
    return widget.resources
        .where((r) => r.type.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resources.isEmpty) return const SizedBox.shrink();
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Learning Resources',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.resources.length} resources',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Filter chips horizontal scroll
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = _filters[i];
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.goldGradient : null,
                    color: isSelected ? null : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.darkBorder,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 10)]
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.darkBg : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Resource cards horizontal scroll
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Center(
                child: Text(
                  'No $_selectedFilter resources yet',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _ResourceCard(resource: filtered[i]),
            ),
          ),
      ],
    );
  }
}

// ── Resource Card ─────────────────────────────────────────────────────────────

class _ResourceCard extends ConsumerStatefulWidget {
  const _ResourceCard({required this.resource});
  final LearningResource resource;

  @override
  ConsumerState<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends ConsumerState<_ResourceCard>
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

  Color get _typeColor {
    switch (widget.resource.type) {
      case 'video':    return const Color(0xFFFF4444);
      case 'docs':     return const Color(0xFF6C8EFF);
      case 'course':   return const Color(0xFF4CAF50);
      case 'practice': return const Color(0xFFFF7043);
      case 'project':  return const Color(0xFFAB47BC);
      case 'blog':     return const Color(0xFF26C6DA);
      default:         return AppColors.gold;
    }
  }

  String get _typeLabel {
    switch (widget.resource.type) {
      case 'video':    return 'VIDEO';
      case 'docs':     return 'DOCS';
      case 'course':   return 'COURSE';
      case 'practice': return 'PRACTICE';
      case 'project':  return 'PROJECT';
      case 'blog':     return 'BLOG';
      default:         return widget.resource.type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: () {
        HapticFeedback.lightImpact();
        final libRes = lib.LearningResource(
          id: widget.resource.id,
          title: widget.resource.title,
          provider: widget.resource.source,
          type: widget.resource.type,
          difficulty: widget.resource.difficulty,
          timeMin: widget.resource.timeMin,
          xpReward: widget.resource.xp,
          coinsReward: 10,
          skills: const [],
          url: widget.resource.url,
          isBookmarked: widget.resource.isBookmarked,
        );
        GoRouter.of(context).push('/book/${widget.resource.id}', extra: libRes);
      },
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _typeColor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail area
              Stack(
                children: [
                  Container(
                    height: 78,
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.resource.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _typeColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _typeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(lib.libraryProvider.notifier).toggleBookmark(widget.resource.id);
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: widget.resource.isBookmarked
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : AppColors.darkBg.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.resource.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 14,
                          color: widget.resource.isBookmarked ? AppColors.gold : AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                widget.resource.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Source
              Text(
                widget.resource.source,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _typeColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Bottom row: time + XP + open
              Row(
                children: [
                  Text(
                    '⏱ ${widget.resource.timeMin}m',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '⚡${widget.resource.xp}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Open',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _typeColor,
                      ),
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
