import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CA Desk Design System — Theme Extension (Light / Dark)
// ─────────────────────────────────────────────────────────────────────────────

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.tertiary,
    required this.glass,
    required this.glassBorder,
    required this.glassBorderDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorDark,
    required this.errorBg,
  });

  // Background layers
  final Color bg0; // deepest bg
  final Color bg1; // primary bg
  final Color bg2; // card bg
  final Color bg3; // elevated card / input bg

  // Brand
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color tertiary;

  // Surface / glass
  final Color glass;
  final Color glassBorder;
  final Color glassBorderDim;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  // Status
  final Color success;
  final Color warning;
  final Color error;
  final Color errorDark;
  final Color errorBg;

  @override
  AppThemeExtension copyWith({
    Color? bg0,
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? tertiary,
    Color? glass,
    Color? glassBorder,
    Color? glassBorderDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? success,
    Color? warning,
    Color? error,
    Color? errorDark,
    Color? errorBg,
  }) {
    return AppThemeExtension(
      bg0: bg0 ?? this.bg0,
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBorderDim: glassBorderDim ?? this.glassBorderDim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      errorDark: errorDark ?? this.errorDark,
      errorBg: errorBg ?? this.errorBg,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      bg0: Color.lerp(bg0, other.bg0, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBorderDim: Color.lerp(glassBorderDim, other.glassBorderDim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorDark: Color.lerp(errorDark, other.errorDark, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Tokens
// ─────────────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const full = 999.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Theme Definitions
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF6366F1);
  static const _secondary = Color(0xFF14B8A6);
  static const _tertiary = Color(0xFFA855F7);
  static const _error = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static final darkColors = AppThemeExtension(
    bg0: const Color(0xFF07090F),
    bg1: const Color(0xFF0D1117),
    bg2: const Color(0xFF131924),
    bg3: const Color(0xFF1A2233),
    primary: _primary,
    primaryLight: const Color(0xFF818CF8),
    primaryDark: const Color(0xFF4F46E5),
    secondary: _secondary,
    tertiary: _tertiary,
    glass: const Color(0x1AFFFFFF),
    glassBorder: const Color(0x26FFFFFF),
    glassBorderDim: const Color(0x0DFFFFFF),
    textPrimary: const Color(0xFFF1F5F9),
    textSecondary: const Color(0xFF94A3B8),
    textMuted: const Color(0xFF475569),
    textDisabled: const Color(0xFF334155),
    success: const Color(0xFF10B981),
    warning: const Color(0xFFF59E0B),
    error: _error,
    errorDark: const Color(0xFF7F1D1D),
    errorBg: const Color(0x1AEF4444),
  );

  static ThemeData get dark {
    final colors = darkColors;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.bg1,
      fontFamily: 'Inter',
      extensions: [colors],
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: Colors.white,
        tertiary: colors.tertiary,
        surface: colors.bg2,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.bg3,
        error: colors.error,
        onError: Colors.white,
        outline: colors.glassBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg1,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      textTheme: _buildTextTheme(colors),
      inputDecorationTheme: _buildInputDecorationTheme(colors),
      filledButtonTheme: _buildFilledButtonTheme(colors),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colors),
      textButtonTheme: _buildTextButtonTheme(colors),
      snackBarTheme: _buildSnackBarTheme(colors),
      dialogTheme: _buildDialogTheme(colors),
      cardTheme: _buildCardTheme(colors),
      dividerTheme: DividerThemeData(
        color: colors.glassBorderDim,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.bg3,
      ),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 20,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static final _lightColors = AppThemeExtension(
    bg0: const Color(0xFFF1F5F9), // Slate 100
    bg1: const Color(0xFFF8FAFC), // Slate 50
    bg2: const Color(0xFFFFFFFF), // White
    bg3: const Color(0xFFF1F5F9), // elevated card / input bg (Slate 100)
    primary: _primary,
    primaryLight: const Color(0xFF818CF8),
    primaryDark: const Color(0xFF4F46E5),
    secondary: _secondary,
    tertiary: _tertiary,
    glass: const Color(0x0D000000), // 5% black
    glassBorder: const Color(0x1A000000), // 10% black border
    glassBorderDim: const Color(0x08000000), // 3% black border (dim)
    textPrimary: const Color(0xFF0F172A), // Slate 900
    textSecondary: const Color(0xFF475569), // Slate 600
    textMuted: const Color(0xFF94A3B8), // Slate 400
    textDisabled: const Color(0xFFCBD5E1), // Slate 300
    success: const Color(0xFF10B981),
    warning: const Color(0xFFF59E0B),
    error: _error,
    errorDark: const Color(0xFF991B1B), // Red 800
    errorBg: const Color(0x1AEF4444),
  );

  static ThemeData get light {
    final colors = _lightColors;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.bg1,
      fontFamily: 'Inter',
      extensions: [colors],
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: Colors.white,
        tertiary: colors.tertiary,
        surface: colors.bg2,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.bg3,
        error: colors.error,
        onError: Colors.white,
        outline: colors.glassBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg1,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      textTheme: _buildTextTheme(colors),
      inputDecorationTheme: _buildInputDecorationTheme(colors),
      filledButtonTheme: _buildFilledButtonTheme(colors),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colors),
      textButtonTheme: _buildTextButtonTheme(colors),
      snackBarTheme: _buildSnackBarTheme(colors),
      dialogTheme: _buildDialogTheme(colors),
      cardTheme: _buildCardTheme(colors),
      dividerTheme: DividerThemeData(
        color: colors.glassBorderDim,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.bg3,
      ),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 20,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Builder Helpers
  // ---------------------------------------------------------------------------
  
  static TextTheme _buildTextTheme(AppThemeExtension colors) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: colors.textPrimary, letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: colors.textPrimary, letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: colors.textPrimary, letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: colors.textPrimary, letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: colors.textSecondary, height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: colors.textSecondary, height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: colors.textMuted, height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: colors.textPrimary, letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: colors.textSecondary, letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: colors.textMuted, letterSpacing: 0.5,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(AppThemeExtension colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.glassBorderDim),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.glassBorderDim),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.glassBorderDim),
      ),
      labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
      prefixIconColor: colors.textMuted,
      suffixIconColor: colors.textMuted,
      errorStyle: TextStyle(color: colors.error, fontSize: 12),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(AppThemeExtension colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 0,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(AppThemeExtension colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.glassBorder),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(AppThemeExtension colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primaryLight,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(AppThemeExtension colors) {
    return SnackBarThemeData(
      backgroundColor: colors.bg3,
      contentTextStyle: TextStyle(
        fontFamily: 'Inter',
        color: colors.textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.glassBorder),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  static DialogThemeData _buildDialogTheme(AppThemeExtension colors) {
    return DialogThemeData(
      backgroundColor: colors.bg2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.glassBorder),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: colors.textSecondary,
      ),
    );
  }

  static CardThemeData _buildCardTheme(AppThemeExtension colors) {
    return CardThemeData(
      color: colors.bg2,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.glassBorderDim),
      ),
    );
  }
}

extension AppThemeContextExtension on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppTheme.darkColors;
}
