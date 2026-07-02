import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/book_model.dart';
import '../reading_provider.dart';

class ChapterListSheet extends ConsumerWidget {
  const ChapterListSheet({super.key, required this.book, required this.onChapterSelected});
  final Book book;
  final ValueChanged<int> onChapterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(readingSessionProvider(book));
    final settings = session.settings;
    final chapters = kMockBookContents[book.id] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: _getBgColor(settings.themeMode),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: _getBorderColor(settings.themeMode), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: _getTextColor(settings.themeMode).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Table of Contents',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _getTextColor(settings.themeMode),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Chapters list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final ch = chapters[index];
                final isCurrent = session.currentChapterIndex == index;
                final isCompleted = index < session.currentChapterIndex;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChapterSelected(index);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.gold.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Status Icon Indicator
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.gold
                                : isCompleted
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : _getBorderColor(settings.themeMode),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCurrent
                                ? const Icon(Icons.play_arrow_rounded, color: AppColors.darkBg, size: 16)
                                : isCompleted
                                    ? const Icon(Icons.check_rounded, color: AppColors.success, size: 14)
                                    : Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _getTextColor(settings.themeMode).withValues(alpha: 0.6),
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ch.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrent ? AppColors.gold : _getTextColor(settings.themeMode),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Currently reading',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        if (isCompleted)
                          Text(
                            'Completed',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _getBgColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.white;
      case 'Sepia':
        return const Color(0xFFFBF0D9);
      default:
        return const Color(0xFF16161F);
    }
  }

  Color _getTextColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.black;
      case 'Sepia':
        return const Color(0xFF5C4033);
      default:
        return AppColors.textPrimaryDark;
    }
  }

  Color _getBorderColor(String mode) {
    switch (mode) {
      case 'Light':
        return Colors.grey.shade300;
      case 'Sepia':
        return const Color(0xFFE2D6B5);
      default:
        return AppColors.darkBorder;
    }
  }
}
