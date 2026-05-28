import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/home/presentation/providers/home_tab_controller.dart';
import 'package:mobile/features/lifeos/presentation/screens/ask_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/capture_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/insights_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/life_settings_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/timeline_tab.dart';

// ─── Void Intelligence accent ────────────────────────────────────────────────
const _kAccent = Color(0xFF3D5AF1); // Electric Blue — same in both modes

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _tabs = <_TabSpec>[
    _TabSpec(icon: Icons.mic_none_rounded, label: 'Capture'),
    _TabSpec(icon: Icons.timeline_rounded, label: 'Timeline'),
    _TabSpec(icon: Icons.search_rounded, label: 'Ask'), // orb slot
    _TabSpec(icon: Icons.auto_awesome_rounded, label: 'Insights'),
    _TabSpec(icon: Icons.shield_outlined, label: 'Privacy'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final selectedIndex = ref.watch(homeTabControllerProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceGradient(brightness),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                CaptureTab(),
                TimelineTab(),
                AskTab(),
                InsightsTab(),
                LifeSettingsTab(),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: _LiquidGlassTabBar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) =>
                  ref.read(homeTabControllerProvider.notifier).setIndex(i),
              tabs: _tabs,
              brightness: brightness,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab spec ────────────────────────────────────────────────────────────────

class _TabSpec {
  const _TabSpec({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ─── Main tab bar ─────────────────────────────────────────────────────────────

class _LiquidGlassTabBar extends StatelessWidget {
  const _LiquidGlassTabBar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.tabs,
    required this.brightness,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<_TabSpec> tabs;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    // Items excluding the centre orb (index 2)
    final pillItems = [
      for (var i = 0; i < tabs.length; i++)
        if (i != 2) _IndexedTab(index: i, spec: tabs[i]),
    ];

    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Pill ──────────────────────────────────────────────────────────
          Expanded(
            child: _GlassPill(
              brightness: brightness,
              child: Row(
                children: [
                  for (final entry in pillItems)
                    Expanded(
                      child: _PillNavItem(
                        icon: entry.spec.icon,
                        label: entry.spec.label,
                        selected: selectedIndex == entry.index,
                        brightness: brightness,
                        onTap: () => onItemSelected(entry.index),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Orb ───────────────────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 1,
            child: _GlassOrb(
              icon: tabs[2].icon,
              label: tabs[2].label,
              selected: selectedIndex == 2,
              brightness: brightness,
              onTap: () => onItemSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexedTab {
  const _IndexedTab({required this.index, required this.spec});
  final int index;
  final _TabSpec spec;
}

// ─── Shared glass painter ─────────────────────────────────────────────────────
//
// Shared transparent blur treatment for the pill and orb.

class _GlassParams {
  const _GlassParams({
    required this.fillOpacity,
    required this.borderOpacity,
    required this.shadowOpacity,
  });

  final double fillOpacity;
  final double borderOpacity;
  final double shadowOpacity;

  static _GlassParams of(Brightness b) => b == Brightness.dark
      ? const _GlassParams(
          fillOpacity: 0.04,
          borderOpacity: 0.08,
          shadowOpacity: 0.08,
        )
      : const _GlassParams(
          fillOpacity: 0.12,
          borderOpacity: 0.10,
          shadowOpacity: 0.02,
        );
}

// ─── Glass pill ───────────────────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.brightness, required this.child});

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = _GlassParams.of(brightness);

    return _GlassShell(
      borderRadius: BorderRadius.circular(999),
      brightness: brightness,
      params: p,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: child,
      ),
    );
  }
}

// ─── Glass orb ────────────────────────────────────────────────────────────────

class _GlassOrb extends StatelessWidget {
  const _GlassOrb({
    required this.icon,
    required this.label,
    required this.selected,
    required this.brightness,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = _GlassParams.of(brightness);
    final color = selected
        ? _kAccent
        : (brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.84)
              : Colors.black.withValues(alpha: 0.80));

    return _GlassShell(
      borderRadius: BorderRadius.circular(999),
      brightness: brightness,
      params: p,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Center(
            child: AnimatedScale(
              duration: AppMotion.durationFast,
              curve: AppMotion.springCurve,
              scale: selected ? 1.10 : 1.0,
              child: Icon(icon, color: color, size: 26, semanticLabel: label),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass shell (shared transparent blur + fill) ─────────────────────────────

class _GlassShell extends StatelessWidget {
  const _GlassShell({
    required this.borderRadius,
    required this.brightness,
    required this.params,
    required this.child,
  });

  final BorderRadius borderRadius;
  final Brightness brightness;
  final _GlassParams params;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final p = params;

    // Slight blue tint in dark mode to stay in the Void Intelligence palette
    final fillColor = isDark
        ? Color.alphaBlend(
            const Color(0xFF3D5AF1).withValues(alpha: 0.06),
            Colors.white.withValues(alpha: p.fillOpacity),
          )
        : Colors.white.withValues(alpha: p.fillOpacity);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          // Diffuse ambient shadow — same soft look as Apple Music pill
          BoxShadow(
            color: Colors.black.withValues(alpha: p.shadowOpacity * 0.55),
            blurRadius: 36,
            spreadRadius: -8,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: p.shadowOpacity * 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          // σ ≈ 28 gives the thick "liquid" blur Apple uses
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Layer 1 — base fill
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: fillColor,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: p.borderOpacity),
                      width: 0.5,
                    ),
                  ),
                ),
              ),

              // Content
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pill nav item ────────────────────────────────────────────────────────────

class _PillNavItem extends StatelessWidget {
  const _PillNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.brightness,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = _kAccent;
    final inactiveColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.84)
        : Colors.black.withValues(alpha: 0.80);
    final color = selected ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: AnimatedOpacity(
          duration: AppMotion.durationFast,
          opacity: selected ? 1.0 : 0.72,
          child: AnimatedScale(
            duration: AppMotion.durationFast,
            curve: AppMotion.springCurve,
            scale: selected ? 1.06 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22, semanticLabel: label),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
