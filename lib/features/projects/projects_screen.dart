import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'projects_provider.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final List<String> _filters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Completed',
    'In Progress',
    'Recommended',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);
    final notifier = ref.read(projectsProvider.notifier);

    // Apply filtering
    final filtered = state.projects.where((p) {
      if (state.selectedFilter != 'All') {
        switch (state.selectedFilter) {
          case 'Beginner':
          case 'Intermediate':
          case 'Advanced':
            if (p.difficulty.toLowerCase() != state.selectedFilter.toLowerCase()) {
              return false;
            }
            break;
          case 'Completed':
            if (p.status != 'completed') return false;
            break;
          case 'In Progress':
            if (p.status != 'in_progress') return false;
            break;
          case 'Recommended':
            if (p.portfolioValue != 'Crucial') return false;
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 14, color: AppColors.textPrimaryDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Tracks',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimaryDark,
                              letterSpacing: -0.6,
                            ),
                          ),
                          Text(
                            'Build a career-defining portfolio',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.terminal_rounded,
                          color: AppColors.gold, size: 18),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filt = _filters[i];
                    final isSelected = state.selectedFilter == filt;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.setFilter(filt);
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
                            filt,
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
              const SizedBox(height: 16),

              // List View
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : filtered.isEmpty
                        ? const _EmptyProjectsView()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, i) {
                              final proj = filtered[i];
                              return _ProjectCard(project: proj);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Project Card Sub-widget ──────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final Project project;

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('0x', '').replaceAll('#', '');
    return Color(int.parse(clean, radix: 16) | 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final startColor = _hexToColor(project.imageGradientStart);
    final endColor = _hexToColor(project.imageGradientEnd);

    final statusColor = project.status == 'completed'
        ? const Color(0xFF4CAF50)
        : project.status == 'in_progress'
            ? const Color(0xFF2196F3)
            : AppColors.textTertiaryDark;

    final statusText = project.status == 'completed'
        ? 'Completed'
        : project.status == 'in_progress'
            ? 'In Progress'
            : 'Not Started';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/projects/${project.id}', extra: project);
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Image visual (premium dynamic gradient box with icon)
            Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              ),
              child: Stack(
                children: [
                  // Portfolio Value Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: project.portfolioValue == 'Crucial'
                              ? AppColors.gold.withValues(alpha: 0.5)
                              : Colors.white24,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.gold, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            '${project.portfolioValue} Value',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: project.portfolioValue == 'Crucial'
                                  ? AppColors.gold
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Difficulty Badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        project.difficulty,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),

                  // Big Center Icon
                  Center(
                    child: Text(
                      project.icon,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Required Skills
                  if (project.requiredSkills.isNotEmpty) ...[
                    Text(
                      project.requiredSkills.join('  •  '),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Progress Bar section (if in progress or completed)
                  if (project.status != 'not_started') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Project Milestones',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          '${project.completedMilestoneCount} / ${project.milestones.length}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(height: 5, color: AppColors.darkElevated),
                          FractionallySizedBox(
                            widthFactor: project.progressPercentage,
                            child: Container(
                              height: 5,
                              decoration: const BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Duration + Rewards footer
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 4),
                      Text(
                        project.duration,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '⚡ +${project.xpReward} XP',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '🪙 +${project.coinsReward}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFBC42),
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
    );
  }
}

// ── Empty Projects Placeholder ───────────────────────────────────────────────

class _EmptyProjectsView extends StatelessWidget {
  const _EmptyProjectsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💻', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          Text(
            'No matching projects found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try switching categories or start a new career path in your settings.',
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
