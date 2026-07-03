import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../home/widgets/book_card.dart';
import '../../../data/mock_data.dart';
import '../onboarding/onboarding_provider.dart';
import 'profile_provider.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'xp_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterController;
  late final List<Animation<double>> _staggerAnims;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _staggerAnims = List.generate(7, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterController,
          curve: Interval(
            i * 0.1,
            (i * 0.1 + 0.5).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Widget _stagger(int i, Widget child) {
    return AnimatedBuilder(
      animation: _staggerAnims[i],
      builder: (context, child) {
        return Opacity(
          opacity: _staggerAnims[i].value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _staggerAnims[i].value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final xpState = ref.watch(xpProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.darkCard,
            onRefresh: () => ref.read(profileProvider.notifier).refresh(),
            child: state.isLoading
                ? _buildSkeletonLoader()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // ── Header Toolbar ─────────────────────────────────────
                      SliverToBoxAdapter(child: _buildTopToolbar(context)),

                      // ── Profile Identity Section ───────────────────────────
                      SliverToBoxAdapter(child: _buildProfileHero(state, xpState)),

                      // ── Main Body Elements ─────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Statistics Dashboard
                            _stagger(0, _buildStatsDashboard(state)),
                            const SizedBox(height: 28),

                            // Achievements Section
                            _stagger(1, _buildAchievementsSection()),
                            const SizedBox(height: 28),

                            // Goal Card
                            _stagger(2, _buildGoalCard(state)),
                            const SizedBox(height: 28),

                            // Continue Reading Card
                            _stagger(3, _buildContinueReadingSection()),
                            const SizedBox(height: 28),

                            // Genres & Authors Presets
                            _stagger(4, _buildPreferencesSection(state)),
                            const SizedBox(height: 28),

                            // Growth Timeline
                            _stagger(5, _buildGrowthTimelineSection()),
                            const SizedBox(height: 28),

                            // Life Dashboard Card
                            _stagger(6, _buildLifeDashboardCard()),
                            const SizedBox(height: 100),
                          ]),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.gold, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(ProfileState state, XpState xpState) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Picture Hero scale animation
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                state.avatarLetter,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBg,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          state.name,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Level ${xpState.level} – ${state.readingLevel.label}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Horizontal mini metrics row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMetricItem('🔥', '${state.streak} Days', 'Streak'),
            _buildVerticalDivider(),
            _buildMetricItem('🏆', '${state.booksCompleted}', 'Missions'),
            _buildVerticalDivider(),
            _buildMetricItem('🧠', '${xpState.currentXp}', 'Knowledge XP'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String emoji, String val, String label) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.darkBorder,
    );
  }

  Widget _buildStatsDashboard(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Reading Statistics'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(height: 14),
                    Text(
                      '${state.pagesReadThisMonth}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pages read this month',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(height: 14),
                    Text(
                      '${state.totalReadingTimeHours}h',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total coaching hours',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final List<Map<String, String>> achievements = [
      {'emoji': '🎯', 'title': 'First Step', 'desc': 'Complete first book'},
      {'emoji': '🔥', 'title': 'Reader Streak', 'desc': 'Reach 14-day streak'},
      {'emoji': '🎓', 'title': 'Polymath', 'desc': 'Read in 3 categories'},
      {'emoji': '🛡️', 'title': 'Dedicated', 'desc': 'Read 60+ min in 1 session'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Achievements'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final ach = achievements[index];
              return GlassCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                child: SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ach['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                        ach['title']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ach['desc']!,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: AppColors.textSecondaryDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Identity Target'),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.readingGoal.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Future ${state.readingGoal.label}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your growth roadmap, tactical missions, and AI coaching directives are calibrated to accelerate this identity transformation.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthTimelineSection() {
    final timeline = [
      {'date': 'Day 1', 'event': 'Cognitive mapping completed. Alignment established.'},
      {'date': 'Day 3', 'event': 'First Tactical Mission initialized: Atomic Habits.'},
      {'date': 'Day 5', 'event': 'Upgraded Productivity attribute to Level 1.2 (+150 XP)'},
      {'date': 'Day 8', 'event': 'Completed Chapter 3 Briefing. Unlocked Active Recall Badge.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Growth Timeline'),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: timeline.map((item) {
              final isLast = timeline.last == item;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: AppColors.darkBorder,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['date']!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['event']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }



  Widget _buildLifeDashboardCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/life-dashboard');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF12222E),
              Color(0xFF0D1821),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF82E2C0).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF82E2C0).withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF82E2C0), Color(0xFF6EC6E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: const Color(0xFF82E2C0).withValues(alpha: 0.4), blurRadius: 14)],
              ),
              child: const Center(child: Text('📊', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Life Dashboard', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 4),
                  Text('Operating System · Daily Agenda · Reports', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    final book = kAllBooks[0]; // Atomic Habits
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Active Book'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            context.push('/book/${book.id}', extra: book);
          },
          child: GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'book-cover-${book.id}',
                  child: BookCoverWidget(
                    book: book,
                    width: 54,
                    height: 75,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '58% Completed',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.gold),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Favorite Genres'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.favoriteGenres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Text(
                genre,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionLabel('Favorite Authors'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.favoriteAuthors.map((author) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 0.5),
              ),
              child: Text(
                author,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondaryDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 24),
          // Avatar Skeleton
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 20),
          // Name Skeleton
          Container(
            height: 20,
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          // Level Skeleton
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 36),
          // Row presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) => Container(
                  height: 36,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
          ),
          const SizedBox(height: 36),
          // Content box Skeletons
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    ),
  );
}
}
