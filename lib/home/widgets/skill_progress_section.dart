import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home_provider.dart';

class SkillProgressSection extends StatefulWidget {
  const SkillProgressSection({super.key, required this.skills});
  final List<SkillData> skills;

  @override
  State<SkillProgressSection> createState() => _SkillProgressSectionState();
}

class _SkillProgressSectionState extends State<SkillProgressSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    final count = widget.skills.length;
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardAnims = List.generate(count, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.08,
            (i * 0.08 + 0.55).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Skill Progress',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.skills.length} skills',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiaryDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-column skill grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.skills.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, i) {
              return AnimatedBuilder(
                animation: _cardAnims[i],
                builder: (_, child) => Opacity(
                  opacity: _cardAnims[i].value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - _cardAnims[i].value)),
                    child: child,
                  ),
                ),
                child: _SkillCard(skill: widget.skills[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatefulWidget {
  const _SkillCard({required this.skill});
  final SkillData skill;

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;

  // Cycle through accent colors for visual variety
  static const _colors = [
    Color(0xFF6C8EFF), // blue
    Color(0xFF4CAF50), // green
    Color(0xFFFF7043), // orange
    Color(0xFFAB47BC), // purple
    Color(0xFF26C6DA), // cyan
    Color(0xFFFFBC42), // yellow
    Color(0xFFFF4444), // red
    Color(0xFF00E5A0), // teal
  ];

  Color get _accentColor {
    final idx = (widget.skill.name.hashCode.abs()) % _colors.length;
    return _colors[idx];
  }

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = Tween<double>(begin: 0, end: widget.skill.progress).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Weekly growth
          Row(
            children: [
              Text(widget.skill.icon, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${widget.skill.weeklyGrowth.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Skill name
          Text(
            widget.skill.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Level + XP
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ).createShader(b),
                child: Text(
                  'LVL ${widget.skill.level}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.skill.xp} XP',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => LinearProgressIndicator(
                value: _barAnim.value,
                minHeight: 4,
                backgroundColor: AppColors.darkSurface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
