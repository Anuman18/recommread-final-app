import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/router/app_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_provider.dart';
import '../profile/profile_provider.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Static list of filters
  final List<String> _filters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Completed',
    'Bookmarked',
    'Recommended',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(libraryProvider.notifier).setSearchQuery(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Categories helper based on career goal
  List<String> _getCategories(ReadingGoal goal) {
    return [
      'All',
      'Documentation',
      'YouTube',
      'Courses',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(libraryProvider.notifier);
    final categories = _getCategories(profile.readingGoal);

    // Apply filtering on resources
    final filteredResources = libraryState.resources.where((r) {
      // 1. Search Query
      if (libraryState.searchQuery.isNotEmpty) {
        final query = libraryState.searchQuery.toLowerCase();
        final matchesTitle = r.title.toLowerCase().contains(query);
        final matchesProvider = r.provider.toLowerCase().contains(query);
        final matchesSkills = r.skills.any((s) => s.toLowerCase().contains(query));
        if (!matchesTitle && !matchesProvider && !matchesSkills) return false;
      }

      // 2. Category
      if (libraryState.selectedCategory != 'All') {
        if (r.type.toLowerCase() != libraryState.selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // 3. Filters
      if (libraryState.selectedFilter != 'All') {
        switch (libraryState.selectedFilter) {
          case 'Beginner':
          case 'Intermediate':
          case 'Advanced':
            if (r.difficulty.toLowerCase() != libraryState.selectedFilter.toLowerCase()) {
              return false;
            }
            break;
          case 'Completed':
            if (r.completionStatus != 'completed') return false;
            break;
          case 'Bookmarked':
            if (!r.isBookmarked) return false;
            break;
          case 'Recommended':
            if (r.aiReason.isEmpty) return false;
            break;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Title & Subtitle ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resource Hub',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-curated learning tracks for Future ${profile.readingGoal.label}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 1. Search Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.textTertiaryDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimaryDark,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search title, provider, or skills...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.textTertiaryDark,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _searchCtrl.clear();
                          },
                          child: const Icon(Icons.clear_rounded,
                              color: AppColors.textSecondaryDark, size: 18),
                        ),
                    ],
                  ),
                ),
              ),

              // ── 2. Category Chips Slider ───────────────────────────────────
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSelected = libraryState.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setCategory(cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.goldGradient : null,
                          color: isSelected ? null : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.darkBorder,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: AppColors.gold.withValues(
                                          alpha: 0.25),
                                      blurRadius: 10)
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.darkBg
                                  : AppColors.textSecondaryDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── 3. Filters Segment Row ──────────────────────────────────────
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final filt = _filters[i];
                    final isSelected = libraryState.selectedFilter == filt;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setFilter(filt);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gold.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.gold.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filt,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textTertiaryDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // ── 4. Main Resource Cards List ─────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  backgroundColor: AppColors.darkCard,
                  onRefresh: () => notifier.refresh(),
                  child: libraryState.isLoading
                      ? const _ShimmerList()
                      : filteredResources.isEmpty
                          ? const _EmptyResourcesView()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                              itemCount: filteredResources.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final res = filteredResources[i];
                                return _ResourceCard(resource: res);
                              },
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

// ── Resource Card Widget ──────────────────────────────────────────────────────

class _ResourceCard extends ConsumerWidget {
  const _ResourceCard({required this.resource});
  final LearningResource resource;

  Color get _typeColor {
    switch (resource.type.toLowerCase()) {
      case 'youtube':
      case 'youtube tutorials':
        return const Color(0xFFFF0000);
      case 'documentation':
      case 'figma resources':
        return const Color(0xFF29B6F6);
      case 'courses':
      case 'design systems':
        return const Color(0xFF66BB6A);
      case 'coding practice':
      case 'ui challenges':
        return const Color(0xFFFFA726);
      case 'projects':
      case 'portfolio tasks':
        return const Color(0xFFAB47BC);
      case 'case studies':
        return const Color(0xFF26A69A);
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = resource.completionStatus == 'completed'
        ? const Color(0xFF4CAF50)
        : resource.completionStatus == 'in_progress'
            ? const Color(0xFF2196F3)
            : AppColors.textTertiaryDark;

    final statusText = resource.completionStatus == 'completed'
        ? 'Completed'
        : resource.completionStatus == 'in_progress'
            ? 'In Progress'
            : 'Not Started';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        SafeNav.push(context, '/book/${resource.id}', extra: resource);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _typeColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Thumbnail + Title + Bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing Thumbnail
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _typeColor.withValues(alpha: 0.22)),
                  ),
                  child: Center(
                    child: Text(resource.icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Provider
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resource.provider,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Bookmark icon
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(libraryProvider.notifier)
                        .toggleBookmark(resource.id);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: resource.isBookmarked
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : AppColors.darkElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      resource.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: resource.isBookmarked
                          ? AppColors.gold
                          : AppColors.textSecondaryDark,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Metadata Badges (Difficulty, Time, Completion)
            Row(
              children: [
                _Badge(label: resource.difficulty, color: _typeColor),
                const SizedBox(width: 6),
                _Badge(label: '${resource.timeMin}m', color: AppColors.textSecondaryDark, icon: Icons.access_time_rounded),
                const Spacer(),
                // Completion status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Skills chips
            if (resource.skills.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: resource.skills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorder, width: 0.5),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Row 4: Rewards & Action buttons
            Row(
              children: [
                // XP Reward
                Text(
                  '⚡ +${resource.xpReward} XP',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '🪙 +${resource.coinsReward}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFBC42),
                  ),
                ),
                const Spacer(),

                // Share button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Share.share('Check out this amazing learning resource: ${resource.title} from ${resource.provider} at ${resource.url}');
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: const Icon(Icons.share_rounded, size: 14, color: AppColors.textPrimaryDark),
                  ),
                ),
                const SizedBox(width: 8),

                // Open Resource button
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(libraryProvider.notifier)
                        .updateCompletionStatus(resource.id, 'in_progress');
                    final uri = Uri.parse(resource.url);
                    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                      // successfully opened
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _typeColor,
                          _typeColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _typeColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Open Resource',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Sub-widgets ────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResourcesView extends StatelessWidget {
  const _EmptyResourcesView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            'No matching resources found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing your search query or selecting a different category filter.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
