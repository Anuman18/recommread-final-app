import 'package:flutter/material.dart';

/// All color tokens for RecommRead.
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFE2B96F);
  static const Color goldLight = Color(0xFFF5D8A0);
  static const Color goldDark = Color(0xFFBF8E3D);

  // ── Dark surfaces ──────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D0D14);
  static const Color darkSurface = Color(0xFF16161F);
  static const Color darkCard = Color(0xFF1E1E2C);
  static const Color darkElevated = Color(0xFF252535);
  static const Color darkBorder = Color(0xFF2C2C3E);

  // ── Light surfaces ─────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF7F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F5);
  static const Color lightBorder = Color(0xFFE5E5EF);

  // ── Text ───────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFF8888AA);
  static const Color textTertiaryDark = Color(0xFF55557A);

  static const Color textPrimaryLight = Color(0xFF0D0D14);
  static const Color textSecondaryLight = Color(0xFF55556A);
  static const Color textTertiaryLight = Color(0xFF9999B0);

  // ── Semantic ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFBE0B);

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE2B96F), Color(0xFFF5D8A0), Color(0xFFBF8E3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0D0D14), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF252535), Color(0xFF1E1E2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
