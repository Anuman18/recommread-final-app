import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class DailyTimePage extends ConsumerStatefulWidget {
  const DailyTimePage({super.key});

  @override
  ConsumerState<DailyTimePage> createState() => _DailyTimePageState();
}

class _DailyTimePageState extends ConsumerState<DailyTimePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _cardAnims = List.generate(DailyTime.values.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.10,
            (i * 0.10 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider).dailyTime;
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: List.generate(DailyTime.values.length, (i) {
                final time = DailyTime.values[i];
                final isSelected = selected == time;
                return AnimatedBuilder(
                  animation: _cardAnims[i],
                  builder: (_, child) => Opacity(
                    opacity: _cardAnims[i].value,
                    child: Transform.scale(
                      scale: 0.88 + 0.12 * _cardAnims[i].value,
                      child: child,
                    ),
                  ),
                  child: _TimeCard(
                    time: time,
                    isSelected: isSelected,
                    onTap: () => notifier.setDailyTime(time),
                  ),
                );
              }),
            ),
          ),
          // Encouragement message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: selected != null
                ? Padding(
                    key: ValueKey(selected),
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Text('🚀',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${selected.subtitle} — your AI roadmap will adapt to this commitment!',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), height: 8),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatefulWidget {
  const _TimeCard({
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  final DailyTime time;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<_TimeCard>
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
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.cardGradient : null,
            color: widget.isSelected ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.gold.withValues(alpha: 0.65)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.gold.withValues(alpha: 0.18)
                      : AppColors.darkElevated,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.time.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Time label
              ShaderMask(
                shaderCallback: (bounds) => widget.isSelected
                    ? AppColors.goldGradient.createShader(bounds)
                    : const LinearGradient(
                        colors: [
                          AppColors.textSecondaryDark,
                          AppColors.textSecondaryDark
                        ],
                      ).createShader(bounds),
                child: Text(
                  widget.time.label,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                widget.time.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
