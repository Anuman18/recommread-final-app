import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding_provider.dart';

class PreferredLanguagePage extends ConsumerStatefulWidget {
  const PreferredLanguagePage({super.key});

  @override
  ConsumerState<PreferredLanguagePage> createState() =>
      _PreferredLanguagePageState();
}

class _PreferredLanguagePageState extends ConsumerState<PreferredLanguagePage>
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
    _cardAnims = List.generate(PreferredLanguage.values.length, (i) {
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
    final selected = ref.watch(onboardingProvider).language;
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
            ),
            child: Text(
              '🎙️ This affects how your AI tutor teaches — examples, explanations and mentoring style.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Language cards
          Expanded(
            child: ListView.separated(
              itemCount: PreferredLanguage.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final lang = PreferredLanguage.values[i];
                final isSelected = selected == lang;
                return AnimatedBuilder(
                  animation: _cardAnims[i],
                  builder: (_, child) => Opacity(
                    opacity: _cardAnims[i].value,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - _cardAnims[i].value)),
                      child: child,
                    ),
                  ),
                  child: _LanguageCard(
                    lang: lang,
                    isSelected: isSelected,
                    onTap: () => notifier.setLanguage(lang),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatefulWidget {
  const _LanguageCard({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  final PreferredLanguage lang;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard>
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
            gradient: widget.isSelected ? AppColors.cardGradient : null,
            color: widget.isSelected ? null : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.gold.withValues(alpha: 0.6)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Flag emoji
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.gold.withValues(alpha: 0.12)
                      : AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.lang.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Label + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lang.label,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: widget.isSelected
                            ? AppColors.textPrimaryDark
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lang.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: widget.isSelected
                            ? AppColors.gold.withValues(alpha: 0.8)
                            : AppColors.textTertiaryDark,
                      ),
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
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.darkBg,
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
