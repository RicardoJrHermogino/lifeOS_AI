import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
}

class AppRadii {
  AppRadii._();
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double input = 16.0;
  static const double pill = 24.0;
  static const double card = 24.0;
  static const double cardLarge = 32.0;
  static const double circle = 999.0;

  static final BorderRadius smallRadius = BorderRadius.circular(small);
  static final BorderRadius mediumRadius = BorderRadius.circular(medium);
  static final BorderRadius inputRadius = BorderRadius.circular(input);
  static final BorderRadius pillRadius = BorderRadius.circular(pill);
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius cardLargeRadius = BorderRadius.circular(cardLarge);
}

class AppColors {
  AppColors._();

  // Light palette
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static Color elevatedSurface = Colors.white.withValues(alpha: 0.75);
  static const Color primaryText = Color(0xFF0A0A0A);
  static const Color secondaryTextLight = Color(0xFF5E5E63);
  static Color borderLight = Colors.black.withValues(alpha: 0.08);

  // Dark palette
  static const Color backgroundDark = Color(0xFF0A0A0B);
  static const Color surfaceDark = Color(0xFF111113);
  static Color elevatedSurfaceDark = const Color(
    0xFF191A1C,
  ).withValues(alpha: 0.86);
  static const Color primaryTextDark = Color(0xFFFFFFFF);
  static const Color secondaryTextDarkColor = Color(0xFFB0B0B5);
  static Color borderDark = Colors.white.withValues(alpha: 0.12);

  // Shared neutrals
  static const Color charcoal = Color(0xFF1A1A1D);
  static const Color graphite = Color(0xFF2C2C2E);
  static const Color silver = Color(0xFF8E8E93);
  static const Color smoke = Color(0xFFD9D9D9);
  static const Color accentLight = Color(0xFF2563EB);
  static const Color accentDark = Color(0xFF8AB4FF);

  // Brightness-aware getters
  static Color primary(Brightness b) =>
      b == Brightness.dark ? primaryTextDark : primaryText;
  static Color secondaryText(Brightness b) =>
      b == Brightness.dark ? secondaryTextDarkColor : secondaryTextLight;
  static Color bg(Brightness b) =>
      b == Brightness.dark ? backgroundDark : background;
  static Color surfaceColor(Brightness b) =>
      b == Brightness.dark ? surfaceDark : surface;
  static Color elevated(Brightness b) =>
      b == Brightness.dark ? elevatedSurfaceDark : elevatedSurface;
  static Color border(Brightness b) =>
      b == Brightness.dark ? borderDark : borderLight;
  static Color accent(Brightness b) =>
      b == Brightness.dark ? accentDark : accentLight;
  static Color onAccent(Brightness b) =>
      b == Brightness.dark ? backgroundDark : surface;
  static Color accentTint(Brightness b) =>
      accent(b).withValues(alpha: b == Brightness.dark ? 0.20 : 0.10);
}

class AppGradients {
  AppGradients._();

  static LinearGradient surfaceGradient(Brightness b) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: b == Brightness.dark
          ? [
              AppColors.charcoal,
              Color.alphaBlend(
                AppColors.accentDark.withValues(alpha: 0.06),
                AppColors.backgroundDark,
              ),
            ]
          : [
              AppColors.surface,
              Color.alphaBlend(
                AppColors.accentLight.withValues(alpha: 0.05),
                AppColors.smoke,
              ),
            ],
    );
  }

  static LinearGradient cardGradient(Brightness b) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: b == Brightness.dark
          ? [
              Color.alphaBlend(
                AppColors.accentDark.withValues(alpha: 0.045),
                const Color(0xFF1A1B20),
              ),
              Color.alphaBlend(
                AppColors.accentDark.withValues(alpha: 0.025),
                AppColors.surfaceDark,
              ),
            ]
          : [
              Colors.white.withValues(alpha: 0.88),
              Colors.white.withValues(alpha: 0.60),
            ],
    );
  }

  static RadialGradient ambientGlow = RadialGradient(
    center: const Alignment(-0.8, -0.9),
    radius: 0.9,
    colors: [AppColors.accentDark.withValues(alpha: 0.14), Colors.transparent],
    stops: const [0.0, 0.6],
  );

  static LinearGradient buttonGradient(Brightness b) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: b == Brightness.dark
          ? [
              Color.alphaBlend(
                AppColors.accentDark.withValues(alpha: 0.16),
                AppColors.charcoal,
              ),
              Color.alphaBlend(
                AppColors.accentDark.withValues(alpha: 0.08),
                const Color(0xFF050506),
              ),
            ]
          : [
              Color.alphaBlend(
                AppColors.accentLight.withValues(alpha: 0.12),
                Colors.white,
              ),
              Color.alphaBlend(
                AppColors.accentLight.withValues(alpha: 0.08),
                AppColors.smoke,
              ),
            ],
    );
  }
}

class AppShadows {
  AppShadows._();

  static BoxShadow subtle(ColorScheme colorScheme) {
    return BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 20,
      color: colorScheme.shadow.withValues(alpha: 0.06),
    );
  }

  static List<BoxShadow> floating(Brightness b) {
    final base = Colors.black;
    return [
      BoxShadow(
        color: base.withValues(alpha: b == Brightness.dark ? 0.45 : 0.18),
        blurRadius: 40,
        spreadRadius: -8,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: base.withValues(alpha: b == Brightness.dark ? 0.18 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> card(Brightness b) {
    return [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: b == Brightness.dark ? 0.35 : 0.12,
        ),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> button(Brightness b) {
    return [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: b == Brightness.dark ? 0.45 : 0.20,
        ),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> ambient(Brightness b) {
    return [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: b == Brightness.dark ? 0.22 : 0.08,
        ),
        blurRadius: 60,
        offset: const Offset(0, 12),
      ),
    ];
  }
}

class AppMotion {
  AppMotion._();
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationStandard = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve transitionCurve = Curves.easeInOutQuart;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve blurCurve = Curves.easeInOutCubic;
}
