import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

// ── Nav item definition ────────────────────────────────────────────────────

class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<NavItem> kNavItems = [
  NavItem(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  NavItem(
    label: 'Search',
    icon: Icons.search_rounded,
    activeIcon: Icons.search_rounded,
  ),
  NavItem(
    label: 'Library',
    icon: Icons.local_library_outlined,
    activeIcon: Icons.local_library_rounded,
  ),
  NavItem(
    label: 'AI Coach',
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome_rounded,
  ),
  NavItem(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

// ── Animated bottom navigation bar ────────────────────────────────────────

class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with TickerProviderStateMixin {
  late AnimationController _indicatorCtrl;
  late Animation<double> _indicatorAnim;

  // Per-item press controllers
  late List<AnimationController> _itemCtrls;
  late List<Animation<double>> _itemScaleAnims;

  @override
  void initState() {
    super.initState();

    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _indicatorAnim = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _indicatorCtrl, curve: Curves.easeOutCubic),
    );

    _itemCtrls = List.generate(
      kNavItems.length,
      (_) => AnimationController(
        vsync: this,
        lowerBound: 0.88,
        upperBound: 1.0,
        value: 1.0,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 180),
      ),
    );
    _itemScaleAnims = _itemCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
  }

  @override
  void didUpdateWidget(AnimatedNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _animateIndicatorTo(widget.currentIndex);
    }
  }

  void _animateIndicatorTo(int index) {
    _indicatorAnim = Tween<double>(
      begin: _indicatorAnim.value,
      end: index.toDouble(),
    ).animate(
      CurvedAnimation(parent: _indicatorCtrl, curve: Curves.easeOutCubic),
    );
    _indicatorCtrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    for (final c in _itemCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTap(int index) {
    HapticFeedback.selectionClick();
    _itemCtrls[index].reverse().then((_) => _itemCtrls[index].forward());
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: const Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: AnimatedBuilder(
            animation: _indicatorAnim,
            builder: (context, _) {
              return Stack(
                children: [
                  // ── Sliding pill indicator ──────────────────────────
                  _buildPillIndicator(context),
                  // ── Nav items ───────────────────────────────────────
                  Row(
                    children: List.generate(kNavItems.length, (i) {
                      final isActive = widget.currentIndex == i;
                      return Expanded(
                        child: ScaleTransition(
                          scale: _itemScaleAnims[i],
                          child: GestureDetector(
                            onTap: () => _onItemTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: _NavItemWidget(
                              item: kNavItems[i],
                              isActive: isActive,
                              index: i,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPillIndicator(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / kNavItems.length;
    const pillWidth = 48.0;

    return Positioned(
      top: 6,
      left: _indicatorAnim.value * itemWidth +
          (itemWidth - pillWidth) / 2,
      child: Container(
        width: pillWidth,
        height: 3,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single nav item ────────────────────────────────────────────────────────

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.index,
  });

  final NavItem item;
  final bool isActive;
  final int index;

  // Special: AI Coach tab gets a gradient glow
  bool get _isAiCoach => index == 3;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          // Icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _isAiCoach && isActive
                ? _AiCoachGlowIcon(isActive: isActive)
                : Icon(
                    key: ValueKey('${item.label}_$isActive'),
                    isActive ? item.activeIcon : item.icon,
                    size: 22,
                    color: isActive
                        ? AppColors.gold
                        : AppColors.textTertiaryDark,
                  ),
          ),
          const SizedBox(height: 4),
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? AppColors.gold
                  : AppColors.textTertiaryDark,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

// ── AI Coach special glowing icon ─────────────────────────────────────────

class _AiCoachGlowIcon extends StatefulWidget {
  const _AiCoachGlowIcon({required this.isActive});
  final bool isActive;

  @override
  State<_AiCoachGlowIcon> createState() => _AiCoachGlowIconState();
}

class _AiCoachGlowIconState extends State<_AiCoachGlowIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4 * _pulseAnim.value),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.goldGradient.createShader(bounds),
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}
