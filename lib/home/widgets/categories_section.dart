import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import 'section_header.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key, required this.categories});
  final List<Category> categories;

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '📚 Popular Categories'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.categories
                .map((cat) => _CategoryChip(
                      category: cat,
                      isSelected: _selectedId == cat.id,
                      onTap: () => setState(
                          () => _selectedId =
                              _selectedId == cat.id ? null : cat.id),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnim = CurvedAnimation(
      parent: _pressCtrl,
      reverseCurve: Curves.easeIn,
      curve: Curves.elasticOut,
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
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.category.color.withValues(alpha: 0.25)
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.isSelected
                  ? widget.category.color.withValues(alpha: 0.7)
                  : AppColors.darkBorder,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.category.color.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category.emoji,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 8),
              Text(
                widget.category.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? widget.category.color
                      : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
