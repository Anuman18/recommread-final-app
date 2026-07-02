import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class CareerGoalPage extends ConsumerStatefulWidget {
  const CareerGoalPage({super.key});

  @override
  ConsumerState<CareerGoalPage> createState() => _CareerGoalPageState();
}

class _CareerGoalPageState extends ConsumerState<CareerGoalPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardAnims = List.generate(ReadingGoal.values.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.04,
            (i * 0.04 + 0.45).clamp(0.0, 1.0),
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
    final selected = ref.watch(onboardingProvider).goal;
    final notifier = ref.read(onboardingProvider.notifier);
    const careers = ReadingGoal.values;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: careers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final goal = careers[i];
        final isSelected = selected == goal;

        return AnimatedBuilder(
          animation: _cardAnims[i],
          builder: (_, child) {
            return Opacity(
              opacity: _cardAnims[i].value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - _cardAnims[i].value)),
                child: child,
              ),
            );
          },
          child: _CareerCard(
            goal: goal,
            isSelected: isSelected,
            onTap: () => notifier.setGoal(goal),
          ),
        );
      },
    );
  }
}

class _CareerCard extends StatefulWidget {
  const _CareerCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final ReadingGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends State<_CareerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _categoryColor {
    switch (widget.goal.category) {
      case 'Tech':     return const Color(0xFF6C8EFF);
      case 'Business': return const Color(0xFFFFB347);
      default:         return const Color(0xFF7ED321);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 68,
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      _categoryColor.withValues(alpha: 0.18),
                      AppColors.darkCard,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: widget.isSelected ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? _categoryColor.withValues(alpha: 0.7)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _categoryColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Category accent bar
              Container(
                width: 3,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? _categoryColor
                      : AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              // Emoji container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? _categoryColor.withValues(alpha: 0.15)
                      : AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.goal.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Label
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? AppColors.textPrimaryDark
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.goal.category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected
                            ? _categoryColor
                            : AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.isSelected ? 26 : 0,
                height: 26,
                curve: Curves.easeOutBack,
                decoration: BoxDecoration(
                  color: _categoryColor,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.darkBg,
                  ),
                ),
              ),
              if (widget.isSelected) const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
