import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class FeedbackCenterScreen extends StatefulWidget {
  const FeedbackCenterScreen({super.key});

  @override
  State<FeedbackCenterScreen> createState() => _FeedbackCenterScreenState();
}

class _FeedbackCenterScreenState extends State<FeedbackCenterScreen> {
  final _descriptionCtrl = TextEditingController();
  String _selectedCategory = 'bug'; // bug, feature_request, resource_rating, ai_rating, general
  int _rating = 5;
  bool _mockScreenshotEnabled = false;
  bool _isLoading = false;

  final Map<String, String> _categories = {
    'bug': 'Report a Bug 🐛',
    'feature_request': 'Suggest a Feature 💡',
    'resource_rating': 'Rate Learning Resources ⭐',
    'ai_rating': 'Rate AI Responses 🤖',
    'general': 'Incorrect Content / Support 💬',
  };

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final description = _descriptionCtrl.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please describe your feedback.', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await apiClient.post(
        ApiConstants.betaFeedback,
        body: {
          'feedback_type': _selectedCategory,
          'content': description,
          'rating': _rating,
          if (_mockScreenshotEnabled) 'target_id': 'screenshot_attachment',
        },
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed. Check network or retry.', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Tick Icon with simple pulse
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 40, color: AppColors.darkBg),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Feedback Received!',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for helping us improve RecommRead Beta during active development.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Dismiss Dialog
                  Navigator.of(context).pop(); // Back to Settings
                },
                child: Text(
                  'Dismiss',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              // AppBar
              _buildAppBar(),
              
              // Scrollable Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Category Selector Label
                    Text(
                      'SELECT CATEGORY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Category Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: AppColors.darkCard,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondaryDark),
                          items: _categories.entries.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Star Rating (Only visible for ratings type)
                    if (_selectedCategory == 'resource_rating' || _selectedCategory == 'ai_rating') ...[
                      Text(
                        'RATE EXPERIENCE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (idx) {
                          final score = idx + 1;
                          return IconButton(
                            icon: Icon(
                              _rating >= score ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.gold,
                              size: 36,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() => _rating = score);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Description text input
                    Text(
                      'DESCRIPTION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionCtrl,
                      maxLines: 6,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Describe details, bug steps, or suggestions here...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiaryDark),
                        filled: true,
                        fillColor: AppColors.darkCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.darkBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.darkBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Screenshot mock toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondaryDark, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attach Screenshot',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mock capture screen dump payload',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _mockScreenshotEnabled,
                            activeThumbColor: AppColors.gold,
                            activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
                            inactiveThumbColor: AppColors.textTertiaryDark,
                            inactiveTrackColor: AppColors.darkCard,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() => _mockScreenshotEnabled = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                        : AnimatedButton(
                            onPressed: _submitFeedback,
                            child: Text(
                              'Submit Feedback',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBg,
                              ),
                            ),
                          ),
                  ],
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
        border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryDark, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Feedback Center',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
