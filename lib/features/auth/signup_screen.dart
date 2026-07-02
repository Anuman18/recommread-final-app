import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/rr_text_field.dart';
import 'auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnims = List.generate(6, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve:
              Interval(i * 0.08, (i * 0.08 + 0.45).clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(6, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(
            i * 0.08,
            (i * 0.08 + 0.45).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).signup(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/onboarding');
      } else {
        final error = ref.read(authProvider).errorMessage ?? 'Signup failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(error, style: GoogleFonts.inter(fontSize: 12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _stagger(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(position: _slideAnims[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkBgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Back button ────────────────────────────────────
                  _stagger(
                    0,
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Header ─────────────────────────────────────────
                  _stagger(
                    1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create account',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join thousands of readers growing daily',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Name ───────────────────────────────────────────
                  _stagger(
                    2,
                    RRTextField(
                      controller: _nameCtrl,
                      hint: 'John Doe',
                      label: 'Full Name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Email ──────────────────────────────────────────
                  _stagger(
                    3,
                    RRTextField(
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Password ───────────────────────────────────────
                  _stagger(
                    4,
                    RRTextField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      label: 'Password',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Confirm Password ───────────────────────────────
                  _stagger(
                    4,
                    RRTextField(
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      label: 'Confirm Password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSignup(),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Password strength indicator ────────────────────
                  _stagger(
                    4,
                    _PasswordStrengthBar(controller: _passwordCtrl),
                  ),

                  const SizedBox(height: 32),

                  // ── Create Account Button ──────────────────────────
                  _stagger(
                    5,
                    AnimatedButton(
                      onPressed: _isLoading ? null : _onSignup,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.darkBg,
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBg,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Footer ─────────────────────────────────────────
                  _stagger(
                    5,
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondaryDark,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password strength bar ─────────────────────────────────────────────────
class _PasswordStrengthBar extends StatefulWidget {
  const _PasswordStrengthBar({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  double _strength = 0;
  String _label = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_evaluate);
  }

  void _evaluate() {
    final p = widget.controller.text;
    double s = 0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9!@#\$%^&*]'))) s += 0.25;

    String label = '';
    if (s <= 0.25) {
      label = 'Weak';
    } else if (s <= 0.5) {
      label = 'Fair';
    } else if (s <= 0.75) {
      label = 'Good';
    } else {
      label = 'Strong';
    }

    if (p.isEmpty) label = '';

    setState(() {
      _strength = p.isEmpty ? 0 : s;
      _label = label;
    });
  }

  Color get _barColor {
    if (_strength <= 0.25) return AppColors.error;
    if (_strength <= 0.5) return AppColors.warning;
    if (_strength <= 0.75) return AppColors.gold;
    return AppColors.success;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_evaluate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_strength == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password strength: ',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textTertiaryDark,
              ),
            ),
            Text(
              _label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _strength),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.darkCard,
                color: _barColor,
                minHeight: 4,
              );
            },
          ),
        ),
      ],
    );
  }
}
