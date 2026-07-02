import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import 'projects_provider.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key, required this.project});
  final Project project;

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _fadeAnims;
  int _selectedTab = 0; // 0: Details, 1: Milestones, 2: Resources
  bool _showCelebration = false;
  String _celebrationTitle = '';
  String _celebrationSubtitle = '';
  int _celebrationXp = 0;
  int _celebrationCoins = 0;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnims = List.generate(6, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _enterCtrl,
        curve: Interval(0.1 + i * 0.1, (0.1 + i * 0.1 + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('0x', '').replaceAll('#', '');
    return Color(int.parse(clean, radix: 16) | 0xFF000000);
  }

  Widget _fadeIn(int index, Widget child) {
    return AnimatedBuilder(
      animation: _fadeAnims[index],
      builder: (_, c) => Opacity(
        opacity: _fadeAnims[index].value,
        child: Transform.translate(
          offset: Offset(0, 15 * (1 - _fadeAnims[index].value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  void _showMilestoneReward(ProjectMilestone m) {
    setState(() {
      _celebrationTitle = 'Milestone Completed!';
      _celebrationSubtitle = 'You successfully finished "${m.name}".';
      _celebrationXp = m.xpGained;
      _celebrationCoins = m.coinsGained;
      _showCelebration = true;
    });
  }

  void _showProjectCompletionReward(Project p) {
    setState(() {
      _celebrationTitle = 'Project Track Complete!';
      _celebrationSubtitle = 'Congratulations! You mastered "${p.name}".';
      _celebrationXp = p.xpReward;
      _celebrationCoins = p.coinsReward;
      _showCelebration = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final currentProj = findProjectById(widget.project.id, projectsState.projects) ?? widget.project;
    final primaryColor = _hexToColor(currentProj.imageGradientStart);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Main Scroll View
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Dynamic Header block
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.darkBg,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimaryDark),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor.withValues(alpha: 0.3), AppColors.darkBg],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(currentProj.icon, style: const TextStyle(fontSize: 64)),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Tabs inside scroll view
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fadeIn(0, _buildHeaderDetails(currentProj, primaryColor)),
                      const SizedBox(height: 24),
                      _fadeIn(1, _buildTabBar(primaryColor)),
                      const SizedBox(height: 20),
                      _fadeIn(2, _buildTabContent(currentProj, primaryColor)),
                      const SizedBox(height: 120), // spacer for bottom panel
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.95), Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                children: [
                  if (currentProj.status == 'not_started')
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.heavyImpact();
                          await ref.read(projectsProvider.notifier).startProject(currentProj.id);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Start Project',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (currentProj.status != 'not_started') ...[
                    // Launch Mentor chat trigger
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.push('/projects/${currentProj.id}/mentor', extra: currentProj);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🤖', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Project Mentor',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Submission button (only active when all milestones except submission are done)
                    GestureDetector(
                      onTap: currentProj.status == 'completed'
                          ? null
                          : () {
                              final readyForSub = currentProj.milestones.take(currentProj.milestones.length - 1).every((m) => m.isCompleted);
                              if (readyForSub) {
                                HapticFeedback.heavyImpact();
                                _showSubmitForm(currentProj);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please complete all previous milestones first.', style: GoogleFonts.inter(color: Colors.white)),
                                    backgroundColor: AppColors.darkCard,
                                  ),
                                );
                              }
                            },
                      child: Container(
                        width: 130,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: currentProj.status == 'completed'
                              ? null
                              : AppColors.goldGradient,
                          color: currentProj.status == 'completed'
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: currentProj.status == 'completed'
                              ? Border.all(color: const Color(0xFF4CAF50))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            currentProj.status == 'completed' ? 'Completed' : 'Submit Code',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: currentProj.status == 'completed' ? const Color(0xFF4CAF50) : AppColors.darkBg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Confetti Reward splash modal
          if (_showCelebration)
            Positioned.fill(
              child: _RewardSplashOverlay(
                title: _celebrationTitle,
                subtitle: _celebrationSubtitle,
                xpReward: _celebrationXp,
                coinsReward: _celebrationCoins,
                onDismiss: () => setState(() => _showCelebration = false),
              ),
            ),
        ],
      ),
    );
  }

  // ── Headers & Meta Info ────────────────────────────────────────────────────

  Widget _buildHeaderDetails(Project p, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.name,
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark, height: 1.25, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(p.difficulty, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: themeColor)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(6)),
              child: Text(p.duration, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondaryDark)),
            ),
            const Spacer(),
            Text('⚡ +${p.xpReward} XP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gold)),
            const SizedBox(width: 8),
            Text('🪙 +${p.coinsReward}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFFFBC42))),
          ],
        ),
      ],
    );
  }

  // ── Horizontal Tabs ────────────────────────────────────────────────────────

  Widget _buildTabBar(Color themeColor) {
    final tabs = ['Overview', 'Milestones', 'Learning Resources'];
    return Container(
      height: 44,
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder, width: 0.5)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.goldGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.darkBg : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Dynamic Content switch ─────────────────────────────────────────────────

  Widget _buildTabContent(Project p, Color themeColor) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(p, themeColor);
      case 1:
        return _buildMilestonesTab(p, themeColor);
      case 2:
        return _buildResourcesTab(p, themeColor);
      default:
        return _buildOverviewTab(p, themeColor);
    }
  }

  // ── Tab 1: Overview ────────────────────────────────────────────────────────

  Widget _buildOverviewTab(Project p, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Overview
        _sectionTitle('Project Overview'),
        Text(p.overview, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.5)),
        const SizedBox(height: 24),

        // Problem Statement
        _sectionTitle('Problem Statement'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder)),
          child: Text(p.problemStatement, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.5)),
        ),
        const SizedBox(height: 24),

        // What you will build
        _sectionTitle('What You Will Build'),
        Text(p.whatYouWillBuild, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.5)),
        const SizedBox(height: 24),

        // Tech Stack & Required skills
        _sectionTitle('Tech Stack & Prerequisites'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: p.techStack.map((t) => _pill(t, themeColor)).toList(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: p.prerequisites.map((req) => _pill(req, AppColors.textTertiaryDark)).toList(),
        ),
        const SizedBox(height: 24),

        // Expected Output
        _sectionTitle('Expected Output'),
        Text(p.expectedOutput, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.5)),
        const SizedBox(height: 24),

        // Dataset (if required)
        if (p.datasetUrl != null) ...[
          _sectionTitle('Project Dataset'),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(p.datasetUrl!);
              if (await launchUrl(uri)) {}
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: themeColor.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  Icon(Icons.download_for_offline_rounded, color: themeColor),
                  const SizedBox(width: 12),
                  Text('Download Dataset Resource', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: themeColor)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Tab 2: Milestones ──────────────────────────────────────────────────────

  Widget _buildMilestonesTab(Project p, Color themeColor) {
    if (p.status == 'not_started') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text('Start the project to unlock progress tracking!', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(p.milestones.length, (i) {
        final m = p.milestones[i];
        final isLast = i == p.milestones.length - 1;
        final readyToComplete = m.isUnlocked && !m.isCompleted;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left track spine
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m.isCompleted
                            ? const Color(0xFF4CAF50)
                            : m.isUnlocked
                                ? themeColor.withValues(alpha: 0.2)
                                : AppColors.darkCard,
                        border: Border.all(
                          color: m.isCompleted
                              ? const Color(0xFF4CAF50)
                              : m.isUnlocked
                                  ? themeColor
                                  : AppColors.darkBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          m.isCompleted ? Icons.check_rounded : Icons.lock_open_rounded,
                          size: 11,
                          color: m.isCompleted
                              ? Colors.white
                              : m.isUnlocked
                                  ? themeColor
                                  : AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: m.isCompleted ? const Color(0xFF4CAF50) : AppColors.darkBorder,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Milestone Card details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: m.isUnlocked ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
                            ),
                          ),
                          if (m.isCompleted)
                            Text('CLAIMED', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF4CAF50)))
                          else if (m.isUnlocked)
                            Text('+${m.xpGained} XP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.description,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: m.isUnlocked ? AppColors.textSecondaryDark : AppColors.textTertiaryDark,
                          height: 1.45,
                        ),
                      ),
                      if (readyToComplete) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await ref.read(projectsProvider.notifier).completeMilestone(p.id, m.id);
                            _showMilestoneReward(m);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Complete Milestone',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.darkBg),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Tab 3: Learning Resources ──────────────────────────────────────────────

  Widget _buildResourcesTab(Project p, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: p.resources.map((res) {
        final icon = res.type == 'video'
            ? Icons.play_circle_fill_rounded
            : res.type == 'course'
                ? Icons.school_rounded
                : Icons.article_rounded;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(res.url);
              if (await launchUrl(uri)) {}
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkBorder)),
              child: Row(
                children: [
                  Icon(icon, color: themeColor, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(res.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(res.type.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiaryDark),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Shareable Form Dialog ──────────────────────────────────────────────────

  void _showSubmitForm(Project p) {
    final subCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.darkBorder)),
        title: Text('Submit Project Portfolio', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste your GitHub repository link or Behance/Medium case study url to complete:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: subCtrl,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'https://github.com/...',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 12)),
          ),
          GestureDetector(
            onTap: () async {
              if (subCtrl.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                
                // Complete final milestone
                final finalMilestone = p.milestones.last;
                await ref.read(projectsProvider.notifier).completeMilestone(p.id, finalMilestone.id);

                _showProjectCompletionReward(p);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(8)),
              child: Text('Submit', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Micro UI helpers ────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.22))),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── CONFETTI REWARD MODAL OVERLAY ────────────────────────────────────────────

class _RewardSplashOverlay extends StatefulWidget {
  const _RewardSplashOverlay({
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.coinsReward,
    required this.onDismiss,
  });

  final String title;
  final String subtitle;
  final int xpReward;
  final int coinsReward;
  final VoidCallback onDismiss;

  @override
  State<_RewardSplashOverlay> createState() => _RewardSplashOverlayState();
}

class _RewardSplashOverlayState extends State<_RewardSplashOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _particles = List.generate(40, (i) {
      final rand = Random();
      return _ConfettiParticle(
        color: [AppColors.gold, const Color(0xFF6C8EFF), const Color(0xFF4CAF50), const Color(0xFFFFBC42)][rand.nextInt(4)],
        angle: rand.nextDouble() * 2 * pi,
        speed: rand.nextDouble() * 8 + 3,
        size: rand.nextDouble() * 8 + 4,
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Confetti particles
                ..._particles.map((p) {
                  final t = _ctrl.value;
                  final x = w / 2 + cos(p.angle) * p.speed * 40 * t;
                  final y = h / 2 + sin(p.angle) * p.speed * 40 * t + 80 * t * t;
                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                      ),
                    ),
                  );
                }),

                // Content Panel
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 30)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(widget.title.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.gold, letterSpacing: 2.0)),
                        const SizedBox(height: 6),
                        Text(widget.subtitle, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryDark, height: 1.4), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('+${widget.xpReward} XP', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.gold)),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFFFBC42).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('+${widget.coinsReward} Coins', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFFFFBC42))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Tap anywhere to continue', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  const _ConfettiParticle({required this.color, required this.angle, required this.speed, required this.size});
}
