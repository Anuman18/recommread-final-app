import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'library_provider.dart';
import 'widgets/completed_books_tab.dart';
import 'widgets/continue_reading_tab.dart';
import 'widgets/library_skeleton.dart';
import 'widgets/saved_books_tab.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;

  final List<String> _tabs = [
    'Reading',
    'Saved',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Title ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Library',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryDark,
                        letterSpacing: -0.8,
                      ),
                    ),
                    // Gold library icon with subtle pulse
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_library_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Custom Sliding Segment Selector ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSlidingPillSelector(),
              ),
              const SizedBox(height: 12),

              // ── Tab Body with Skeleton Loading and Pull-to-Refresh ────────
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  backgroundColor: AppColors.darkCard,
                  onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: libraryState.isLoading
                        ? LibrarySkeleton(
                            key: const ValueKey('skeleton'),
                            tabIndex: _activeTab,
                          )
                        : _buildActiveTabContent(libraryState),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlidingPillSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _tabs.length;
          return Stack(
            children: [
              // Sliding active pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _activeTab * tabWidth,
                width: tabWidth,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _activeTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _activeTab = index;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.darkBg : AppColors.textSecondaryDark,
                          ),
                          child: Text(_tabs[index]),
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
    );
  }

  Widget _buildActiveTabContent(LibraryState state) {
    switch (_activeTab) {
      case 0:
        return const ContinueReadingTab(key: ValueKey('reading'));
      case 1:
        return const SavedBooksTab(key: ValueKey('saved'));
      case 2:
        return const CompletedBooksTab(key: ValueKey('completed'));
      default:
        return const SizedBox.shrink();
    }
  }
}
