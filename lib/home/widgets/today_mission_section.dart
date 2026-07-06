import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';
import '../../features/library/library_provider.dart' as lib;

class TodayMissionSection extends ConsumerWidget {
  const TodayMissionSection({super.key, required this.missions});
  final List<DailyMission> missions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (missions.isEmpty) return const SizedBox.shrink();
    final primary = missions.firstWhere((m) => m.isPrimary, orElse: () => missions.first);
    final secondary = missions.where((m) => !m.isPrimary).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                "Today's Mission",
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${missions.length} tasks',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary hero mission
          _HeroMissionCard(mission: primary),
          const SizedBox(height: 10),

          // Secondary missions
          ...secondary.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SecondaryMissionCard(mission: m),
              )),
        ],
      ),
    );
  }
}

// ── Hero Mission Card ─────────────────────────────────────────────────────────

class _HeroMissionCard extends ConsumerStatefulWidget {
  const _HeroMissionCard({required this.mission});
  final DailyMission mission;

  @override
  ConsumerState<_HeroMissionCard> createState() => _HeroMissionCardState();
}

class _HeroMissionCardState extends ConsumerState<_HeroMissionCard>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.mission.progress,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));

    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _diffColor {
    switch (widget.mission.difficulty) {
      case 'Beginner':  return const Color(0xFF4CAF50);
      case 'Advanced':  return const Color(0xFFFF7043);
      default:          return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.15),
                const Color(0xFF1A1228),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Difficulty + Time
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.mission.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _DiffBadge(label: widget.mission.difficulty, color: _diffColor),
                            const SizedBox(width: 8),
                            Text(
                              '⏱ ${widget.mission.timeMin} min',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.mission.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Rewards row
              Row(
                children: [
                  _RewardChip(emoji: '⚡', value: '+${widget.mission.xpReward} XP', color: AppColors.gold),
                  const SizedBox(width: 8),
                  _RewardChip(emoji: '🪙', value: '+${widget.mission.coinsReward}', color: const Color(0xFFFFBC42)),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiaryDark,
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (_, __) => Text(
                                '${(_progressAnim.value * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedBuilder(
                            animation: _progressAnim,
                            builder: (_, __) => LinearProgressIndicator(
                              value: _progressAnim.value,
                              minHeight: 5,
                              backgroundColor: AppColors.darkSurface,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Start / Resume button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      final library = ref.read(lib.libraryProvider);
                      lib.LearningResource? resource;
                      for (final res in library.resources) {
                        if (res.id == widget.mission.id || res.title.toLowerCase() == widget.mission.title.toLowerCase()) {
                          resource = res;
                          break;
                        }
                      }
                      resource ??= lib.LearningResource(
                        id: widget.mission.id.isNotEmpty ? widget.mission.id : 'fallback',
                        title: widget.mission.title,
                        provider: 'AI OS',
                        type: 'Documentation',
                        difficulty: widget.mission.difficulty,
                        timeMin: widget.mission.timeMin,
                        xpReward: widget.mission.xpReward,
                        coinsReward: widget.mission.coinsReward,
                        skills: const [],
                        url: 'https://github.com',
                      );
                      GoRouter.of(context).push('/book/${resource.id}', extra: resource);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.mission.progress > 0 ? 'Resume' : 'Start',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBg,
                        ),
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

// ── Secondary Mission Card ────────────────────────────────────────────────────

class _SecondaryMissionCard extends ConsumerStatefulWidget {
  const _SecondaryMissionCard({required this.mission});
  final DailyMission mission;

  @override
  ConsumerState<_SecondaryMissionCard> createState() => _SecondaryMissionCardState();
}

class _SecondaryMissionCardState extends ConsumerState<_SecondaryMissionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.mission.progress,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  Color get _diffColor {
    switch (widget.mission.difficulty) {
      case 'Beginner':  return const Color(0xFF4CAF50);
      case 'Advanced':  return const Color(0xFFFF7043);
      default:          return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final library = ref.read(lib.libraryProvider);
        lib.LearningResource? resource;
        for (final res in library.resources) {
          if (res.id == widget.mission.id || res.title.toLowerCase() == widget.mission.title.toLowerCase()) {
            resource = res;
            break;
          }
        }
        resource ??= lib.LearningResource(
          id: widget.mission.id.isNotEmpty ? widget.mission.id : 'fallback',
          title: widget.mission.title,
          provider: 'AI OS',
          type: 'Documentation',
          difficulty: widget.mission.difficulty,
          timeMin: widget.mission.timeMin,
          xpReward: widget.mission.xpReward,
          coinsReward: widget.mission.coinsReward,
          skills: const [],
          url: 'https://github.com',
        );
        GoRouter.of(context).push('/book/${resource.id}', extra: resource);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(widget.mission.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mission.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _DiffBadge(label: widget.mission.difficulty, color: _diffColor, small: true),
                      const SizedBox(width: 8),
                      Text(
                        '⏱ ${widget.mission.timeMin}m  ⚡ +${widget.mission.xpReward} XP',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                  if (widget.mission.progress > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (_, __) => LinearProgressIndicator(
                          value: _progressAnim.value,
                          minHeight: 3,
                          backgroundColor: AppColors.darkSurface,
                          valueColor: AlwaysStoppedAnimation<Color>(_diffColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Arrow CTA
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _DiffBadge extends StatelessWidget {
  const _DiffBadge({required this.label, required this.color, this.small = false});
  final String label;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.emoji, required this.value, required this.color});
  final String emoji;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
