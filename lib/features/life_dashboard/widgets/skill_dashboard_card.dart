import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../profile/xp_provider.dart';

const _skillMeta = {
  'AI': {'icon': '🤖', 'color': Color(0xFF6EC6E2)},
  'Programming': {'icon': '💻', 'color': Color(0xFF82E2A0)},
  'Business': {'icon': '💼', 'color': Color(0xFFE2B96F)},
  'Finance': {'icon': '📈', 'color': Color(0xFF82E2C0)},
  'Leadership': {'icon': '🎯', 'color': Color(0xFFE26EBD)},
  'Communication': {'icon': '🗣️', 'color': Color(0xFFE2956E)},
  'Psychology': {'icon': '🧠', 'color': Color(0xFF9B8AF5)},
  'Productivity': {'icon': '⚡', 'color': Color(0xFFFFBE0B)},
  'Critical Thinking': {'icon': '🔍', 'color': Color(0xFF6E9DE2)},
};

class SkillDashboardCard extends ConsumerWidget {
  const SkillDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final skills = xp.skills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Text('🕸️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Skill Dashboard', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark)),
              const Spacer(),
              Text('${skills.length} skills', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiaryDark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 3-column grid
        ...List.generate((skills.length / 3).ceil(), (rowIndex) {
          final rowSkills = skills.entries.skip(rowIndex * 3).take(3).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                ...rowSkills.map((e) => Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SkillCard(name: e.key, level: e.value),
                ))),
                if (rowSkills.length < 3) ...List.generate(3 - rowSkills.length, (_) => const Expanded(child: SizedBox())),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SkillCard extends StatefulWidget {
  const _SkillCard({required this.name, required this.level});
  final String name;
  final double level;

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _skillMeta[widget.name] ?? {'icon': '📚', 'color': AppColors.gold};
    final icon = meta['icon'] as String;
    final color = meta['color'] as Color;
    final progress = (widget.level / 5.0).clamp(0.0, 1.0);
    final weeklyGrowth = (widget.level * 12 + 5).round();

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                widget.name.length > 11 ? '${widget.name.substring(0, 9)}..' : widget.name,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              // Circular-style mini bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(height: 4, color: AppColors.darkElevated),
                    FractionallySizedBox(
                      widthFactor: progress * _anim.value,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lv ${widget.level.toStringAsFixed(1)}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  Text('+$weeklyGrowth%', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF82E2A0))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
