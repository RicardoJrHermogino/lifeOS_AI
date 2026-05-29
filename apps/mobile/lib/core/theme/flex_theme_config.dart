import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_styles.dart';

/// Kept for backward compatibility with the persisted preference store.
/// The app now only supports a single premium monochrome scheme.
enum AppColorScheme { monochrome }

/// Builds the bespoke monochrome [ThemeData] for the app. The base is provided
/// by `flex_color_scheme` for token plumbing, but every relevant token is
/// overridden to produce a premium glassmorphism / iOS-style look.
class FlexThemeConfig {
  FlexThemeConfig._();

  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const AppColorScheme defaultColorScheme = AppColorScheme.monochrome;

  static const String _fontFamily = '.SF Pro Display';

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.05,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.08,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.12,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.15,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: secondary,
      ),
    );
  }

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final base = isDark
        ? FlexThemeData.dark(scheme: FlexScheme.greys, useMaterial3: true)
        : FlexThemeData.light(scheme: FlexScheme.greys, useMaterial3: true);

    final primaryText = isDark
        ? AppColors.primaryTextDark
        : AppColors.primaryText;
    final onPrimary = AppColors.warmStone;
    final secondaryText = isDark
        ? AppColors.secondaryTextDarkColor
        : AppColors.secondaryTextLight;
    final accent = AppColors.accent(brightness);
    final onAccent = AppColors.onAccent(brightness);
    final surfaceColor = AppColors.surfaceColor(brightness);
    final backgroundColor = AppColors.bg(brightness);
    final outline = AppColors.border(brightness);
    final elevated = AppColors.elevated(brightness);

    final colorScheme = base.colorScheme.copyWith(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      secondary: accent,
      onSecondary: onAccent,
      tertiary: AppColors.deepTeal,
      onTertiary: AppColors.warmStone,
      surface: surfaceColor,
      onSurface: primaryText,
      onSurfaceVariant: secondaryText,
      outline: outline,
      outlineVariant: outline,
      primaryContainer: AppColors.accentTint(brightness),
      onPrimaryContainer: AppColors.midnightIndigo,
      secondaryContainer: AppColors.successTint(brightness),
      onSecondaryContainer: AppColors.deepTeal,
      tertiaryContainer: AppColors.warningTint(brightness),
      onTertiaryContainer: AppColors.charcoal,
      error: AppColors.blushRose,
      onError: AppColors.charcoal,
      errorContainer: AppColors.emotionTint(brightness),
      onErrorContainer: isDark ? AppColors.warmStone : AppColors.charcoal,
      surfaceContainerLowest: backgroundColor,
      surfaceContainerLow: elevated,
      surfaceContainer: surfaceColor,
      surfaceContainerHigh: elevated,
      surfaceContainerHighest: elevated,
      shadow: Colors.black,
    );

    final textTheme = _buildTextTheme(primaryText, secondaryText);

    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: primaryText, size: 22),
      primaryIconTheme: IconThemeData(color: primaryText, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: primaryText, size: 22),
        actionsIconTheme: IconThemeData(color: primaryText, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: secondaryText),
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: primaryText),
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: outline, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: outline, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: accent, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryText,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primaryText.withValues(alpha: 0.4),
          disabledForegroundColor: onPrimary.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
          elevation: 0,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryText,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
          elevation: 0,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: BorderSide(color: outline, width: 1),
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryText,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accent,
        unselectedItemColor: secondaryText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 0.5,
        space: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        side: BorderSide(color: outline, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryText,
        textColor: primaryText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: 6,
        ),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: secondaryText),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? onAccent
              : (isDark ? AppColors.silver : Colors.white),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : elevated,
        ),
        trackOutlineColor: WidgetStateProperty.all(outline),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: primaryText,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: onPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryText,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
    );
  }

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);
}
