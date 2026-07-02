import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/rr_text_field.dart';
import '../onboarding/onboarding_provider.dart';
import 'profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late ReadingGoal _selectedGoal;
  late Set<String> _selectedGenres;
  late String _selectedAvatar;
  bool _isSaving = false;

  final List<String> _avatarPresets = ['AR', 'JD', 'WL', 'KR', 'EM', '🦉', '🎓', '🦁', '🦊'];

  final List<String> _genrePresets = [
    'Self Growth',
    'Finance',
    'Psychology',
    'Technology',
    'Business',
    'History',
    'Fiction',
    'Philosophy',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _selectedGoal = profile.readingGoal;
    _selectedGenres = Set<String>.from(profile.favoriteGenres);
    _selectedAvatar = profile.avatarLetter;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      HapticFeedback.mediumImpact();
      await ref.read(profileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            readingGoal: _selectedGoal,
            favoriteGenres: _selectedGenres,
            avatarLetter: _selectedAvatar,
          );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkSurface,
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.inter(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Custom AppBar ──────────────────────────────────────────────
              _buildAppBar(),

              // ── Scrollable Edit Form ───────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Avatar Selection Grid
                      _buildSectionTitle('Choose Avatar / Preset'),
                      const SizedBox(height: 12),
                      _buildAvatarGrid(),
                      const SizedBox(height: 28),

                      // Name Field
                      RRTextField(
                        controller: _nameController,
                        hint: 'Enter your name',
                        label: 'Full Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Reading Goal Dropdown/Selector
                      _buildSectionTitle('Reading Goal'),
                      const SizedBox(height: 10),
                      _buildGoalDropdown(),
                      const SizedBox(height: 28),

                      // Favorite Genres Selection Chips
                      _buildSectionTitle('Favorite Genres'),
                      const SizedBox(height: 12),
                      _buildGenresChipWrap(),
                      const SizedBox(height: 40),

                      // Save Changes Button
                      AnimatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.darkBg,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBg,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
            'Edit Profile',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: _avatarPresets.length,
        itemBuilder: (context, index) {
          final preset = _avatarPresets[index];
          final isSelected = preset == _selectedAvatar;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedAvatar = preset;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.goldGradient : null,
                color: isSelected ? null : AppColors.darkSurface,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.darkBorder, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  preset,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.darkBg : AppColors.gold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReadingGoal>(
          value: _selectedGoal,
          dropdownColor: AppColors.darkSurface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
          onChanged: (ReadingGoal? newGoal) {
            if (newGoal != null) {
              setState(() {
                _selectedGoal = newGoal;
              });
            }
          },
          items: ReadingGoal.values.map((ReadingGoal goal) {
            return DropdownMenuItem<ReadingGoal>(
              value: goal,
              child: Row(
                children: [
                  Text(goal.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(
                    goal.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGenresChipWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _genrePresets.map((genre) {
        final isSelected = _selectedGenres.contains(genre);
        return FilterChip(
          label: Text(genre),
          selected: isSelected,
          onSelected: (bool selected) {
            HapticFeedback.selectionClick();
            setState(() {
              if (selected) {
                _selectedGenres.add(genre);
              } else {
                _selectedGenres.remove(genre);
              }
            });
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.darkBg : AppColors.textSecondaryDark,
          ),
          selectedColor: AppColors.gold,
          checkmarkColor: AppColors.darkBg,
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.gold : AppColors.darkBorder,
              width: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}
