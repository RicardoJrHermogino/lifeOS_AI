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

  // Brand
  static const Color midnightIndigo = Color(0xFF3B3580);
  static const Color softIndigo = Color(0xFFEEEDFE);
  static const Color deepTeal = Color(0xFF0F6E56);
  static const Color mistTeal = Color(0xFFE1F5EE);

  // Semantic
  static const Color softAmber = Color(0xFFEF9F27);
  static const Color blushRose = Color(0xFFF4C0D1);

  // Neutral
  static const Color warmStone = Color(0xFFF1EFE8);
  static const Color stoneMid = Color(0xFFD3D1C7);
  static const Color charcoal = Color(0xFF2C2C2A);

  // Light palette
  static const Color background = warmStone;
  static const Color surface = warmStone;
  static Color elevatedSurface = Colors.white.withValues(alpha: 0.46);
  static const Color primaryText = charcoal;
  static Color secondaryTextLight = charcoal.withValues(alpha: 0.64);
  static Color borderLight = stoneMid;

  // Dark palette
  static const Color backgroundDark = charcoal;
  static Color surfaceDark = Color.alphaBlend(
    warmStone.withValues(alpha: 0.035),
    charcoal,
  );
  static Color elevatedSurfaceDark = Color.alphaBlend(
    warmStone.withValues(alpha: 0.07),
    charcoal,
  );
  static const Color primaryTextDark = warmStone;
  static Color secondaryTextDarkColor = stoneMid.withValues(alpha: 0.72);
  static Color borderDark = stoneMid.withValues(alpha: 0.18);

  // Compatibility aliases for older UI code.
  static const Color graphite = charcoal;
  static const Color silver = stoneMid;
  static const Color smoke = stoneMid;
  static const Color accentLight = midnightIndigo;
  static const Color accentDark = midnightIndigo;

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
      b == Brightness.dark ? warmStone : warmStone;
  static Color accentTint(Brightness b) =>
      b == Brightness.dark ? softIndigo.withValues(alpha: 0.14) : softIndigo;
  static Color success(Brightness b) => deepTeal;
  static Color successTint(Brightness b) =>
      b == Brightness.dark ? mistTeal.withValues(alpha: 0.14) : mistTeal;
  static Color warning(Brightness b) => softAmber;
  static Color warningTint(Brightness b) =>
      softAmber.withValues(alpha: b == Brightness.dark ? 0.16 : 0.22);
  static Color emotion(Brightness b) => blushRose;
  static Color emotionTint(Brightness b) =>
      blushRose.withValues(alpha: b == Brightness.dark ? 0.16 : 0.42);
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
                AppColors.midnightIndigo.withValues(alpha: 0.12),
                AppColors.backgroundDark,
              ),
            ]
          : [
              AppColors.warmStone,
              Color.alphaBlend(
                AppColors.softIndigo.withValues(alpha: 0.62),
                AppColors.warmStone,
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
                AppColors.softIndigo.withValues(alpha: 0.06),
                AppColors.charcoal,
              ),
              Color.alphaBlend(
                AppColors.midnightIndigo.withValues(alpha: 0.10),
                AppColors.surfaceDark,
              ),
            ]
          : [
              AppColors.warmStone.withValues(alpha: 0.92),
              AppColors.softIndigo.withValues(alpha: 0.70),
            ],
    );
  }

  static RadialGradient ambientGlow = RadialGradient(
    center: const Alignment(-0.8, -0.9),
    radius: 0.9,
    colors: [
      AppColors.midnightIndigo.withValues(alpha: 0.18),
      Colors.transparent,
    ],
    stops: const [0.0, 0.6],
  );

  static LinearGradient buttonGradient(Brightness b) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: b == Brightness.dark
          ? [
              Color.alphaBlend(
                AppColors.softIndigo.withValues(alpha: 0.10),
                AppColors.charcoal,
              ),
              Color.alphaBlend(
                AppColors.midnightIndigo.withValues(alpha: 0.22),
                AppColors.charcoal,
              ),
            ]
          : [
              Color.alphaBlend(
                AppColors.softIndigo.withValues(alpha: 0.90),
                AppColors.warmStone,
              ),
              Color.alphaBlend(
                AppColors.mistTeal.withValues(alpha: 0.58),
                AppColors.warmStone,
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
