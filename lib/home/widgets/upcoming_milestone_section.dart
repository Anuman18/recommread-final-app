import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';

class UpcomingMilestoneSection extends StatefulWidget {
  const UpcomingMilestoneSection({super.key, required this.milestones});
  final List<Milestone> milestones;

  @override
  State<UpcomingMilestoneSection> createState() => _UpcomingMilestoneSectionState();
}

class _UpcomingMilestoneSectionState extends State<UpcomingMilestoneSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    final count = widget.milestones.length;
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnims = List.generate(count, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(i * 0.15, (i * 0.15 + 0.6).clamp(0, 1), curve: Curves.easeOutCubic),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    if (widget.milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Upcoming Milestones',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal scroll of milestone cards
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: widget.milestones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final ms = widget.milestones[i];
              return AnimatedBuilder(
                animation: _cardAnims[i],
                builder: (_, child) => Opacity(
                  opacity: _cardAnims[i].value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - _cardAnims[i].value), 0),
                    child: child,
                  ),
                ),
                child: _MilestoneCard(milestone: ms),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MilestoneCard extends StatefulWidget {
  const _MilestoneCard({required this.milestone});
  final Milestone milestone;

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _barAnim = Tween<double>(begin: 0, end: widget.milestone.progress).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.milestone.status) {
      case 'completed': return const Color(0xFF4CAF50);
      case 'locked':    return AppColors.textTertiaryDark;
      default:          return AppColors.gold;
    }
  }

  String get _statusLabel {
    switch (widget.milestone.status) {
      case 'completed': return 'Completed';
      case 'locked':    return 'Locked';
      default:          return 'In Progress';
    }
  }

  IconData get _statusIcon {
    switch (widget.milestone.status) {
      case 'completed': return Icons.check_circle_rounded;
      case 'locked':    return Icons.lock_rounded;
      default:          return Icons.radio_button_checked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.milestone.status == 'locked';

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: !isLocked
              ? LinearGradient(
                  colors: [
                    _statusColor.withValues(alpha: 0.1),
                    AppColors.darkCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isLocked ? AppColors.darkCard : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _statusColor.withValues(alpha: isLocked ? 0.1 : 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + Status chip
            Row(
              children: [
                Text(
                  isLocked ? '🔒' : widget.milestone.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 10, color: _statusColor),
                      const SizedBox(width: 3),
                      Text(
                        _statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              widget.milestone.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Progress counter
            Text(
              '${widget.milestone.current} / ${widget.milestone.target}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
            const SizedBox(height: 6),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _barAnim,
                builder: (_, __) => LinearProgressIndicator(
                  value: isLocked ? 0 : _barAnim.value,
                  minHeight: 5,
                  backgroundColor: AppColors.darkSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
