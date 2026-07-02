import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import 'section_header.dart';

class ReadingPathsSection extends StatelessWidget {
  const ReadingPathsSection({super.key, required this.paths});
  final List<ReadingPath> paths;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '🗺️ Growth Roadmaps',
          subtitle: 'Follow curated identity pathways',
        ),
        SizedBox(
          height: 320,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: paths.length,
            itemBuilder: (context, i) => _ReadingPathCard(path: paths[i]),
          ),
        ),
      ],
    );
  }
}

class _ReadingPathCard extends StatefulWidget {
  const _ReadingPathCard({required this.path});
  final ReadingPath path;

  @override
  State<_ReadingPathCard> createState() => _ReadingPathCardState();
}

class _ReadingPathCardState extends State<_ReadingPathCard>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _stepsCtrl;
  late final List<Animation<double>> _stepAnims;

  bool _expanded = false;

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
    _stepsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _stepAnims = List.generate(widget.path.steps.length, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _stepsCtrl,
          curve: Interval(
            i * 0.15,
            (i * 0.15 + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    Future.delayed(
      const Duration(milliseconds: 400),
      () { if (mounted) _stepsCtrl.forward(); },
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  int get _completedCount =>
      widget.path.steps.where((s) => s.isCompleted).length;

  double get _pathProgress =>
      _completedCount / widget.path.steps.length;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      onTap: () => setState(() => _expanded = !_expanded),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: 240,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.path.gradientColors[0].withValues(alpha: 0.25),
                widget.path.gradientColors[1].withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.path.gradientColors.first.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.path.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.path.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.path.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        Text(
                          widget.path.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Progress ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_completedCount/${widget.path.steps.length} steps',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  Text(
                    '${(_pathProgress * 100).round()}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: widget.path.gradientColors.first,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _pathProgress,
                  backgroundColor: AppColors.darkBorder,
                  valueColor: AlwaysStoppedAnimation(
                      widget.path.gradientColors.first),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 14),

              // ── Steps roadmap ─────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.path.steps.length,
                  itemBuilder: (context, i) {
                    final step = widget.path.steps[i];
                    final isLast = i == widget.path.steps.length - 1;
                    return AnimatedBuilder(
                      animation: _stepAnims[i],
                      builder: (_, child) => Opacity(
                        opacity: _stepAnims[i].value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - _stepAnims[i].value)),
                          child: child,
                        ),
                      ),
                      child: _RoadmapStep(
                        step: step,
                        isLast: isLast,
                        accentColor: widget.path.gradientColors.first,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  const _RoadmapStep({
    required this.step,
    required this.isLast,
    required this.accentColor,
  });

  final PathStep step;
  final bool isLast;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column: dot + line ───────────────────────────────
          SizedBox(
            width: 20,
            child: Column(
              children: [
                // Node circle
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? accentColor
                        : step.isCurrent
                            ? accentColor.withValues(alpha: 0.4)
                            : AppColors.darkBorder,
                    border: step.isCurrent
                        ? Border.all(color: accentColor, width: 2)
                        : null,
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 10, color: Colors.white)
                      : step.isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor,
                              ),
                            )
                          : null,
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: step.isCompleted
                            ? accentColor.withValues(alpha: 0.5)
                            : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Right column: text ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: step.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: step.isCompleted
                          ? AppColors.textTertiaryDark
                          : step.isCurrent
                              ? AppColors.textPrimaryDark
                              : AppColors.textSecondaryDark,
                      decoration: step.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textTertiaryDark,
                    ),
                  ),
                  Text(
                    step.bookTitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textTertiaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
