import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../life_dashboard_provider.dart';

class DailyRewardsCard extends ConsumerWidget {
  const DailyRewardsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeDashboardProvider);
    final rewards = state.dailyRewards;
    final claimed = rewards.where((r) => r.claimed).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1228), Color(0xFF120D1E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Daily Rewards', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              Text('$claimed/${rewards.length} claimed', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: rewards.map((r) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _RewardTile(reward: r, onClaim: () {
                  HapticFeedback.mediumImpact();
                  ref.read(lifeDashboardProvider.notifier).claimReward(r.id);
                }),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatefulWidget {
  const _RewardTile({required this.reward, required this.onClaim});
  final DailyReward reward;
  final VoidCallback onClaim;

  @override
  State<_RewardTile> createState() => _RewardTileState();
}

class _RewardTileState extends State<_RewardTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.reward.claimed) return;
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onClaim();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reward;
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            gradient: r.claimed ? LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.2), AppColors.gold.withValues(alpha: 0.05)]) : null,
            color: r.claimed ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: r.claimed ? AppColors.gold.withValues(alpha: 0.4) : AppColors.darkBorder,
              width: r.claimed ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(r.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text('+${r.xp} XP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: r.claimed ? AppColors.gold : AppColors.textTertiaryDark)),
              const SizedBox(height: 4),
              r.claimed
                  ? const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.gold)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Claim', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black87)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
