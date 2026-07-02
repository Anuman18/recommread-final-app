import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  // ── Shared ──────────────────────────────────────────────────────────
  static const _radius = Radius.circular(16);
  static const _cardRadius = BorderRadius.all(_radius);

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: secondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: secondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.darkBg,
      secondary: AppColors.goldLight,
      onSecondary: AppColors.darkBg,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      outline: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _buildTextTheme(
        AppColors.textPrimaryDark,
        AppColors.textSecondaryDark,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBg,
          shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: const OutlineInputBorder(
          borderRadius: _cardRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: _cardRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: _cardRadius,
          borderSide: BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: _cardRadius,
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiaryDark,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.goldDark,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.darkBg,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _buildTextTheme(
        AppColors.textPrimaryLight,
        AppColors.textSecondaryLight,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDark,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.goldDark, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }
}
