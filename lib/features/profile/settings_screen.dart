import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_button.dart';
import 'profile_provider.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Custom AppBar ──────────────────────────────────────────────
              _buildAppBar(context),

              // ── Settings Content ───────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Theme Segment
                    _buildSectionHeader('Appearance'),
                    _buildThemeTile(ref, state),
                    const SizedBox(height: 16),

                    // Preferences Segment
                    _buildSectionHeader('Preferences'),
                    _buildLanguageTile(context, ref, state),
                    const SizedBox(height: 16),

                    // Security & Privacy Segment
                    _buildSectionHeader('System & Legal'),
                    _buildMenuTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your reading metrics',
                      onTap: () => _showDialog(context, 'Privacy Policy', 'Your reading statistics, goals, and preferred genres are stored locally on your device. We do not sell or share your data with third parties.'),
                    ),
                    _buildMenuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Submit feedback or contact support',
                      onTap: () => _showDialog(context, 'Help & Support', 'If you experience any issues with RecommRead, please contact our support team at support@recommread.ai.'),
                    ),
                    _buildMenuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About RecommRead',
                      subtitle: 'Version 1.0.0 (Build 42)',
                      onTap: () => _showDialog(context, 'About RecommRead', 'RecommRead is a premium, AI-powered reading coach designed to help you build habits, digest chapters efficiently, and structure learning roadmaps.'),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    AnimatedButton(
                      backgroundColor: Colors.transparent,
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 18),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiaryDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile(WidgetRef ref, ProfileState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                state.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  Text(
                    state.isDarkMode ? 'Theme set to dark appearance' : 'Theme set to light appearance',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: state.isDarkMode,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondaryDark,
            inactiveTrackColor: AppColors.darkBg,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref.read(profileProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, ProfileState state) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showLanguagePicker(context, ref, state);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Language',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      'Choose your interface language',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  state.language,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiaryDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textTertiaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w800),
          ),
          content: Text(
            content,
            style: GoogleFonts.inter(color: AppColors.textSecondaryDark, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, ProfileState state) {
    final List<String> languages = ['English', 'Spanish', 'French', 'German', 'Mandarin'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: AppColors.darkBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Language',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = lang == state.language;
                return ListTile(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(profileProvider.notifier).updateLanguage(lang);
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.language_rounded,
                    color: isSelected ? AppColors.gold : AppColors.textSecondaryDark,
                    size: 18,
                  ),
                  title: Text(
                    lang,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppColors.gold : AppColors.textPrimaryDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18)
                      : null,
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
