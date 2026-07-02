import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../features/profile/profile_provider.dart';
import '../../features/profile/xp_provider.dart';
import '../../features/onboarding/onboarding_provider.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _streakPulse;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _streakScale;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _streakPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _streakScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _streakPulse, curve: Curves.easeInOut),
    );

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _streakPulse.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final xpState = ref.watch(xpProvider);

    final String initial = profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : 'U';

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text greeting & name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting,',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.name} 👋',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Streak Badge
                  ScaleTransition(
                    scale: _streakScale,
                    child: _StreakBadge(streak: profile.streak),
                  ),
                  const SizedBox(width: 12),

                  // Avatar
                  _AnimatedAvatar(initial: initial),
                ],
              ),
              const SizedBox(height: 18),

              // Target Identity Transition
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trip_origin_rounded,
                      size: 16,
                      color: AppColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                          children: [
                            const TextSpan(text: 'Shift: '),
                            TextSpan(
                              text: 'You',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: ' ➔ '),
                            TextSpan(
                              text: 'Future ${profile.readingGoal.label}',
                              style: GoogleFonts.inter(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Level Progress & XP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${xpState.level}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    '${xpState.xpInCurrentLevel} / 3000 XP',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: xpState.levelProgress,
                    backgroundColor: AppColors.darkSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
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

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFBC42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak days',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAvatar extends StatefulWidget {
  const _AnimatedAvatar({required this.initial});
  final String initial;

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.initial,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBg,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.darkBg, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
