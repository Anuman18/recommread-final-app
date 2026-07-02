import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class GenresPage extends ConsumerStatefulWidget {
  const GenresPage({super.key});

  @override
  ConsumerState<GenresPage> createState() => _GenresPageState();
}

class _GenresPageState extends ConsumerState<GenresPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _chipAnims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chipAnims = List.generate(kAllGenres.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.05,
            (i * 0.05 + 0.5).clamp(0.0, 1.0),
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
    final selected = ref.watch(onboardingProvider).genres;
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(selected.length),
              selected.isEmpty
                  ? 'Tap to select'
                  : '${selected.length} selected',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected.isEmpty
                    ? AppColors.textTertiaryDark
                    : AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(kAllGenres.length, (i) {
                final genre = kAllGenres[i];
                final isSelected = selected.contains(genre);
                return AnimatedBuilder(
                  animation: _chipAnims[i],
                  builder: (_, child) {
                    return Opacity(
                      opacity: _chipAnims[i].value,
                      child: Transform.scale(
                        scale: 0.85 + 0.15 * _chipAnims[i].value,
                        child: child,
                      ),
                    );
                  },
                  child: _GenreChip(
                    label: genre,
                    isSelected: isSelected,
                    onTap: () => notifier.toggleGenre(genre),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatefulWidget {
  const _GenreChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_GenreChip> createState() => _GenreChipState();
}

class _GenreChipState extends State<_GenreChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.cardGradient : null,
            color: widget.isSelected ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.gold.withValues(alpha: 0.7)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight:
                  widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color: widget.isSelected
                  ? AppColors.textPrimaryDark
                  : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
