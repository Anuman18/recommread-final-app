import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/rr_text_field.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _enterController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Stagger 5 elements: header, email, password, button, footer
    _fadeAnims = List.generate(5, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _enterController,
          curve: Interval(i * 0.1, i * 0.1 + 0.5, curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(5, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _enterController,
          curve: Interval(i * 0.1, i * 0.1 + 0.5, curve: Curves.easeOutCubic),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _enterController.forward();
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/home');
      } else {
        final error = ref.read(authProvider).errorMessage ?? 'Login failed';
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
                  const SizedBox(height: 64),

                  // ── Header ─────────────────────────────────────────
                  _stagger(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LogoBadge(),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome back',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDark,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your reading journey',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Email ──────────────────────────────────────────
                  _stagger(
                    1,
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
                    2,
                    Column(
                      children: [
                        RRTextField(
                          controller: _passwordCtrl,
                          hint: '••••••••',
                          label: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onLogin(),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Login Button ───────────────────────────────────
                  _stagger(
                    3,
                    AnimatedButton(
                      onPressed: _isLoading ? null : _onLogin,
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
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBg,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Divider ────────────────────────────────────────
                  _stagger(
                    3,
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.darkBorder),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textTertiaryDark,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.darkBorder),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Google Button ──────────────────────────────────
                  _stagger(
                    3,
                    _GoogleButton(),
                  ),

                  const SizedBox(height: 40),

                  // ── Footer ─────────────────────────────────────────
                  _stagger(
                    4,
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondaryDark,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign up',
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small logo badge ────────────────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'RR',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBg,
          ),
        ),
      ),
    );
  }
}

// ── Google sign-in button ───────────────────────────────────────────────────
class _GoogleButton extends StatefulWidget {
  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleLogo(),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simplified Google "G" logo using colored arcs
    final red = Paint()..color = const Color(0xFFEA4335);
    final blue = Paint()..color = const Color(0xFF4285F4);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    const strokeWidth = 3.5;
    red.style = PaintingStyle.stroke;
    red.strokeWidth = strokeWidth;
    blue.style = PaintingStyle.stroke;
    blue.strokeWidth = strokeWidth;
    yellow.style = PaintingStyle.stroke;
    yellow.strokeWidth = strokeWidth;
    green.style = PaintingStyle.stroke;
    green.strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    canvas.drawArc(rect, -0.3, 1.9, false, red);
    canvas.drawArc(rect, 1.6, 1.6, false, yellow);
    canvas.drawArc(rect, 3.2, 1.6, false, green);
    canvas.drawArc(rect, 4.8, 1.0, false, blue);

    // Horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - 1, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
