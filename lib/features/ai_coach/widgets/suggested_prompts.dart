import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class SuggestedPrompts extends StatelessWidget {
  const SuggestedPrompts({
    super.key,
    required this.onPromptSelected,
  });

  final ValueChanged<String> onPromptSelected;

  static const List<Map<String, String>> _prompts = [
    {
      'label': 'Quiz Me',
      'emoji': '🧠',
      'prompt': 'Quiz me on the key concepts from this chapter',
    },
    {
      'label': 'Explain Deeply',
      'emoji': '💡',
      'prompt': 'Explain this in simple language with real-world examples',
    },
    {
      'label': 'Challenge Me',
      'emoji': '⚡',
      'prompt': 'Give me a challenge task to apply what I learned',
    },
    {
      'label': 'Next Mission',
      'emoji': '🚀',
      'prompt': 'Recommend my next mission for my identity transformation',
    },
    {
      'label': 'Summarize',
      'emoji': '📝',
      'prompt': 'Summarize this mission and its core identity shifts',
    },
    {
      'label': 'Daily Focus',
      'emoji': '🎯',
      'prompt': 'What should I focus on today to accelerate my transformation?',
    },
    {
      'label': 'Skill Audit',
      'emoji': '📊',
      'prompt': 'Audit my current skills and suggest what to level up next',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'MENTOR ACTION CUES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiaryDark,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: _prompts.length,
            itemBuilder: (context, index) {
              final promptMap = _prompts[index];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 60)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: child,
                    ),
                  );
                },
                child: _PromptPill(
                  emoji: promptMap['emoji']!,
                  label: promptMap['label']!,
                  onTap: () => onPromptSelected(promptMap['prompt']!),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PromptPill extends StatefulWidget {
  const _PromptPill({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PromptPill> createState() => _PromptPillState();
}

class _PromptPillState extends State<_PromptPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) => _pressController.forward(),
      onTapCancel: () => _pressController.forward(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.darkBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
