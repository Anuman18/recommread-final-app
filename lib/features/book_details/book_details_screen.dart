import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../features/library/library_provider.dart';
import '../../features/profile/xp_provider.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  const BookDetailsScreen({super.key, required this.resource});
  final LearningResource resource;

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _fadeAnims;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnims = List.generate(6, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _enterCtrl,
        curve: Interval(
          0.1 + i * 0.1,
          (0.1 + i * 0.1 + 0.45).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.resource.type.toLowerCase()) {
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

  Widget _fadeIn(int i, Widget child) => AnimatedBuilder(
        animation: _fadeAnims[i],
        builder: (_, c) => Opacity(
          opacity: _fadeAnims[i].value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - _fadeAnims[i].value)),
            child: c,
          ),
        ),
        child: child,
      );

  // Trigger completion animation & award rewards
  void _triggerCompletion() async {
    HapticFeedback.heavyImpact();
    
    // 1. Award XP via Riverpod Provider
    await ref.read(xpProvider.notifier).addXp(widget.resource.xpReward);

    // 2. Increment related skills by 0.3
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('user_coins') ?? 100;
    await prefs.setInt('user_coins', currentCoins + widget.resource.coinsReward);

    // 3. Mark completed in our resources provider
    ref.read(libraryProvider.notifier).updateCompletionStatus(widget.resource.id, 'completed');

    setState(() {
      _showConfetti = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);
    // Find live instance of this resource in state to update dynamically
    final currentRes = findResourceById(widget.resource.id, state.resources) ?? widget.resource;
    final themeColor = _typeColor;

    // Filter related resources
    final relatedList = state.resources
        .where((r) => r.id != currentRes.id && currentRes.relatedResourceIds.contains(r.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // ── Main scroll content ──────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header Area ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.textPrimaryDark),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(libraryProvider.notifier).toggleBookmark(currentRes.id);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentRes.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: currentRes.isBookmarked ? AppColors.gold : AppColors.textPrimaryDark,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Share.share('Learn with me: ${currentRes.title} via RecommRead AI Career OS!');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBg.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_rounded,
                          color: AppColors.textPrimaryDark, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Gradient glow matching resource type
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeColor.withValues(alpha: 0.25),
                              AppColors.darkBg,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Glowing Big Icon
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(currentRes.icon, style: const TextStyle(fontSize: 54)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Details Content ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Badge
                      _fadeIn(
                        0,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            currentRes.type.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title & Provider
                      _fadeIn(
                        0,
                        Text(
                          currentRes.title,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fadeIn(
                        0,
                        Text(
                          'by ${currentRes.provider}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Metadata Chips Row
                      _fadeIn(
                        1,
                        Row(
                          children: [
                            _DetailChip(icon: Icons.speed_rounded, label: currentRes.difficulty, color: themeColor),
                            const SizedBox(width: 8),
                            _DetailChip(icon: Icons.timer_outlined, label: '${currentRes.timeMin} min', color: AppColors.textSecondaryDark),
                            const SizedBox(width: 8),
                            _DetailChip(icon: Icons.flash_on_rounded, label: '+${currentRes.xpReward} XP', color: AppColors.gold),
                            const SizedBox(width: 8),
                            _DetailChip(icon: Icons.monetization_on_rounded, label: '+${currentRes.coinsReward}', color: const Color(0xFFFFBC42)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _fadeIn(
                        2,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentRes.description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Why AI Recommended It
                      if (currentRes.aiReason.isNotEmpty)
                        _fadeIn(
                          3,
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🤖', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Why AI Recommended It',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentRes.aiReason,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryDark,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (currentRes.aiReason.isNotEmpty) const SizedBox(height: 24),

                      // Skills You'll Learn
                      _fadeIn(
                        4,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Skills You'll Improve",
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: currentRes.skills.map((s) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCard,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.darkBorder),
                                  ),
                                  child: Text(
                                    s,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Related Mission Link
                      if (currentRes.missionLink != null)
                        _fadeIn(
                          4,
                          GestureDetector(
                            onTap: () => HapticFeedback.selectionClick(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                children: [
                                  const Text('🎯', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Related Mission:',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      currentRes.missionLink!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: themeColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: themeColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (currentRes.missionLink != null) const SizedBox(height: 24),

                      // Related Resources Section
                      if (relatedList.isNotEmpty)
                        _fadeIn(
                          5,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Related Resources',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...relatedList.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        context.pushReplacement('/book/${r.id}', extra: r);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkCard,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppColors.darkBorder),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(r.icon, style: const TextStyle(fontSize: 20)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                r.title,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimaryDark,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_ios_rounded,
                                                size: 11, color: AppColors.textTertiaryDark),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Fixed Action Panel ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                children: [
                  // Start Learning / Launch button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        ref
                            .read(libraryProvider.notifier)
                            .updateCompletionStatus(currentRes.id, 'in_progress');
                        final uri = Uri.parse(currentRes.url);
                        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          // successfully launched
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [themeColor, themeColor.withValues(alpha: 0.75)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.launch_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Start Learning',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Completed toggle button
                  GestureDetector(
                    onTap: currentRes.completionStatus == 'completed'
                        ? null
                        : _triggerCompletion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 120,
                      height: 52,
                      decoration: BoxDecoration(
                        color: currentRes.completionStatus == 'completed'
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: currentRes.completionStatus == 'completed'
                              ? const Color(0xFF4CAF50)
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentRes.completionStatus == 'completed'
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: currentRes.completionStatus == 'completed'
                                  ? const Color(0xFF4CAF50)
                                  : AppColors.textSecondaryDark,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentRes.completionStatus == 'completed' ? 'Done' : 'Complete',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: currentRes.completionStatus == 'completed'
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Beautiful Confetti Overlay Modal ──────────────────────────────
          if (_showConfetti)
            Positioned.fill(
              child: _CompletionCelebrationOverlay(
                resource: currentRes,
                onDismiss: () => setState(() => _showConfetti = false),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Detail Chip Sub-widget ───────────────────────────────────────────────────

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti Particle Celebration Overlay ─────────────────────────────────────

class _CompletionCelebrationOverlay extends StatefulWidget {
  const _CompletionCelebrationOverlay({required this.resource, required this.onDismiss});
  final LearningResource resource;
  final VoidCallback onDismiss;

  @override
  State<_CompletionCelebrationOverlay> createState() =>
      _CompletionCelebrationOverlayState();
}

class _CompletionCelebrationOverlayState
    extends State<_CompletionCelebrationOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _particles = List.generate(40, (i) {
      final rand = Random();
      return _ConfettiParticle(
        color: [
          AppColors.gold,
          const Color(0xFF6C8EFF),
          const Color(0xFF4CAF50),
          const Color(0xFFFFBC42)
        ][rand.nextInt(4)],
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
                // Confetti particles explosion
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
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // Congratulatory Panel
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'TRACK PROGRESS COMPLETE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Excellent Work!',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You completed "${widget.resource.title}" and unlocked related career nodes.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Rewards strip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+${widget.resource.xpReward} XP',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFBC42).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+${widget.resource.coinsReward} Coins',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFBC42),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tap anywhere to continue',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
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
