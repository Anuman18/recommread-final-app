import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/book_model.dart';
import '../reading_provider.dart';

class ReadingSettingsSheet extends ConsumerWidget {
  const ReadingSettingsSheet({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(readingSessionProvider(book));
    final settings = session.settings;
    final notifier = ref.read(readingSessionProvider(book).notifier);

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
            'Reading Display Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _getTextColor(settings.themeMode),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Theme Modes
          _buildThemeSelector(settings, notifier),
          const SizedBox(height: 28),

          // Font Family
          _buildFontFamilySelector(settings, notifier),
          const SizedBox(height: 28),

          // Font Size Slider
          _buildFontSizeSlider(settings, notifier),
          const SizedBox(height: 20),

          // Line Height & Page Margin (Side-by-side)
          Row(
            children: [
              Expanded(child: _buildLineHeightSelector(settings, notifier)),
              const SizedBox(width: 16),
              Expanded(child: _buildPageMarginSelector(settings, notifier)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ReadingSettingsState settings, ReadingSessionNotifier notifier) {
    final List<Map<String, dynamic>> themes = [
      {'mode': 'Light', 'bg': Colors.white, 'border': Colors.grey.shade300, 'label': 'Light'},
      {'mode': 'Sepia', 'bg': const Color(0xFFF4ECD8), 'border': const Color(0xFFE2D6B5), 'label': 'Sepia'},
      {'mode': 'Dark', 'bg': const Color(0xFF1E1E2C), 'border': const Color(0xFF2C2C3E), 'label': 'Dark'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Theme Mode', settings.themeMode),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: themes.map((t) {
            final isSelected = settings.themeMode == t['mode'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.updateSettings(themeMode: t['mode']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 95,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: t['bg'] as Color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : t['border'] as Color,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  t['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: t['mode'] == 'Light'
                        ? Colors.black
                        : t['mode'] == 'Sepia'
                            ? const Color(0xFF5C4033)
                            : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(ReadingSettingsState settings, ReadingSessionNotifier notifier) {
    final List<String> fonts = ['Serif', 'Sans-Serif', 'Monospace'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Font Style', settings.themeMode),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: fonts.map((f) {
            final isSelected = settings.fontFamily == f;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.updateSettings(
                  fontFamily: f,
                  themeMode: settings.themeMode,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 95,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : _getBorderColor(settings.themeMode),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  f,
                  style: _getFontFamilyStyle(f).copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.gold : _getTextColor(settings.themeMode),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(ReadingSettingsState settings, ReadingSessionNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Font Size', settings.themeMode),
            Text(
              '${settings.fontSize.round()}px',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: _getBorderColor(settings.themeMode),
            thumbColor: AppColors.goldLight,
            overlayColor: AppColors.gold.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: settings.fontSize,
            min: 12,
            max: 28,
            divisions: 8,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              notifier.updateSettings(
                fontSize: val,
                themeMode: settings.themeMode,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLineHeightSelector(ReadingSettingsState settings, ReadingSessionNotifier notifier) {
    final List<double> heights = [1.2, 1.5, 1.8];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Line Height', settings.themeMode),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: heights.map((h) {
            final isSelected = settings.lineHeight == h;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.updateSettings(
                  lineHeight: h,
                  themeMode: settings.themeMode,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : _getBorderColor(settings.themeMode),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${h}x',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.gold : _getTextColor(settings.themeMode),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPageMarginSelector(ReadingSettingsState settings, ReadingSessionNotifier notifier) {
    final List<double> margins = [12.0, 16.0, 24.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Margins', settings.themeMode),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: margins.map((m) {
            final isSelected = settings.pageMargin == m;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.updateSettings(
                  pageMargin: m,
                  themeMode: settings.themeMode,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : _getBorderColor(settings.themeMode),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${m.round()}px',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.gold : _getTextColor(settings.themeMode),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String themeMode) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: _getTextColor(themeMode).withValues(alpha: 0.6),
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

  TextStyle _getFontFamilyStyle(String font) {
    switch (font) {
      case 'Serif':
        return GoogleFonts.merriweather();
      case 'Monospace':
        return GoogleFonts.firaCode();
      default:
        return GoogleFonts.inter();
    }
  }
}
