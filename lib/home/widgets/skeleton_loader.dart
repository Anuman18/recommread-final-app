import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ── Shimmer shimmer effect ─────────────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              AppColors.darkCard,
              AppColors.darkElevated,
              AppColors.darkCard,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton layouts ──────────────────────────────────────────────────────

class SkeletonBookCard extends StatelessWidget {
  const SkeletonBookCard({super.key, this.isLarge = false});
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLarge ? 160 : 140,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: isLarge ? 160 : 140,
            height: isLarge ? 220 : 190,
            borderRadius: 16,
          ),
          const SizedBox(height: 10),
          ShimmerBox(
            width: isLarge ? 130 : 110,
            height: 12,
            borderRadius: 6,
          ),
          const SizedBox(height: 6),
          ShimmerBox(
            width: isLarge ? 90 : 80,
            height: 10,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }
}

class SkeletonContinueCard extends StatelessWidget {
  const SkeletonContinueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 156,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: const Row(
          children: [
            ShimmerBox(width: 96, height: 120, borderRadius: 12),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 11, borderRadius: 6),
                  SizedBox(height: 16),
                  ShimmerBox(width: double.infinity, height: 6, borderRadius: 4),
                  SizedBox(height: 14),
                  ShimmerBox(width: 100, height: 34, borderRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonHorizontalSection extends StatelessWidget {
  const SkeletonHorizontalSection({super.key, this.isLarge = false});
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isLarge ? 300 : 230,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, i) => SkeletonBookCard(isLarge: isLarge),
      ),
    );
  }
}

// ── New section skeletons ───────────────────────────────────────────────────

class SkeletonMissionSection extends StatelessWidget {
  const SkeletonMissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            ShimmerBox(width: 140, height: 16, borderRadius: 8),
            Spacer(),
            ShimmerBox(width: 60, height: 12, borderRadius: 6),
          ]),
          SizedBox(height: 14),
          // Hero card
          ShimmerBox(width: double.infinity, height: 160, borderRadius: 22),
          SizedBox(height: 10),
          // Secondary cards
          ShimmerBox(width: double.infinity, height: 68, borderRadius: 18),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 68, borderRadius: 18),
        ],
      ),
    );
  }
}

class SkeletonAiRecSection extends StatelessWidget {
  const SkeletonAiRecSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 160, height: 16, borderRadius: 8),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 72, borderRadius: 18),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 72, borderRadius: 18),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 72, borderRadius: 18),
        ],
      ),
    );
  }
}

class SkeletonSkillGrid extends StatelessWidget {
  const SkeletonSkillGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            ShimmerBox(width: 120, height: 16, borderRadius: 8),
            Spacer(),
            ShimmerBox(width: 60, height: 12, borderRadius: 6),
          ]),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: const [
              ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 18),
              ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 18),
              ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 18),
              ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonWeeklyProgress extends StatelessWidget {
  const SkeletonWeeklyProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 140, height: 16, borderRadius: 8),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonMilestones extends StatelessWidget {
  const SkeletonMilestones({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ShimmerBox(width: 180, height: 16, borderRadius: 8),
        ),
        SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: HorizontalSeparatedSkeletonList(),
        ),
      ],
    );
  }
}

class HorizontalSeparatedSkeletonList extends StatelessWidget {
  const HorizontalSeparatedSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) =>
          const ShimmerBox(width: 190, height: 160, borderRadius: 20),
    );
  }
}

