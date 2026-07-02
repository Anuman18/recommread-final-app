import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class ReadingLevelPage extends ConsumerStatefulWidget {
  const ReadingLevelPage({super.key});

  @override
  ConsumerState<ReadingLevelPage> createState() => _ReadingLevelPageState();
}

class _ReadingLevelPageState extends ConsumerState<ReadingLevelPage>
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

    _cardAnims = List.generate(ReadingLevel.values.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.15,
            (i * 0.15 + 0.55).clamp(0.0, 1.0),
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
    final selected = ref.watch(onboardingProvider).level;
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: ReadingLevel.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final level = ReadingLevel.values[i];
        final isSelected = selected == level;
        return AnimatedBuilder(
          animation: _cardAnims[i],
          builder: (_, child) => Opacity(
            opacity: _cardAnims[i].value,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - _cardAnims[i].value)),
              child: child,
            ),
          ),
          child: _LevelCard(
            level: level,
            isSelected: isSelected,
            onTap: () => notifier.setLevel(level),
          ),
        );
      },
    );
  }
}

class _LevelCard extends StatefulWidget {
  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final ReadingLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

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
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  String get _levelIcon {
    switch (widget.level) {
      case ReadingLevel.beginner:     return '🌱';
      case ReadingLevel.intermediate: return '⚡';
      case ReadingLevel.advanced:     return '🔥';
    }
  }

  int get _barCount {
    switch (widget.level) {
      case ReadingLevel.beginner:     return 1;
      case ReadingLevel.intermediate: return 2;
      case ReadingLevel.advanced:     return 3;
    }
  }

  List<Color> get _gradient {
    switch (widget.level) {
      case ReadingLevel.beginner:     return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case ReadingLevel.intermediate: return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      case ReadingLevel.advanced:     return [AppColors.gold, const Color(0xFFFFD54F)];
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
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      _gradient[0].withValues(alpha: 0.12),
                      AppColors.darkCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? _gradient[0].withValues(alpha: 0.7)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _gradient[0].withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          colors: [
                            _gradient[0].withValues(alpha: 0.2),
                            _gradient[1].withValues(alpha: 0.08),
                          ],
                        )
                      : null,
                  color: widget.isSelected ? null : AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(_levelIcon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.level.label,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: widget.isSelected
                            ? AppColors.textPrimaryDark
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.level.techDescription,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textTertiaryDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Level progress bars
                    Row(
                      children: List.generate(3, (i) {
                        final active = i < _barCount;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: active && widget.isSelected
                                  ? LinearGradient(colors: _gradient)
                                  : null,
                              color: active
                                  ? (widget.isSelected
                                      ? null
                                      : _gradient[0].withValues(alpha: 0.5))
                                  : AppColors.darkBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Check
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.isSelected ? 28 : 0,
                height: 28,
                curve: Curves.easeOutBack,
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(colors: _gradient)
                      : null,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
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
