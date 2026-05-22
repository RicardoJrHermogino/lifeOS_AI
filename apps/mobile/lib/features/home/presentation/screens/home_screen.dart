import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/presentation/screens/ask_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/capture_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/insights_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/life_settings_tab.dart';
import 'package:mobile/features/lifeos/presentation/screens/timeline_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tabController = PersistentTabController(initialIndex: 0);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final accentColor = AppColors.accent(brightness);

    final tabs = <_TabSpec>[
      const _TabSpec(icon: Icons.mic_none_rounded, label: 'Capture'),
      const _TabSpec(icon: Icons.timeline_rounded, label: 'Timeline'),
      const _TabSpec(icon: Icons.search_rounded, label: 'Ask'),
      const _TabSpec(icon: Icons.auto_awesome_rounded, label: 'Insights'),
      const _TabSpec(icon: Icons.shield_outlined, label: 'Privacy'),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceGradient(brightness),
      ),
      child: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: const CaptureTab(),
            item: ItemConfig(
              icon: Icon(tabs[0].icon),
              title: tabs[0].label,
              activeForegroundColor: accentColor,
              inactiveForegroundColor: AppColors.secondaryText(brightness),
            ),
          ),
          PersistentTabConfig(
            screen: const TimelineTab(),
            item: ItemConfig(
              icon: Icon(tabs[1].icon),
              title: tabs[1].label,
              activeForegroundColor: accentColor,
              inactiveForegroundColor: AppColors.secondaryText(brightness),
            ),
          ),
          PersistentTabConfig(
            screen: const AskTab(),
            item: ItemConfig(
              icon: Icon(tabs[2].icon),
              title: tabs[2].label,
              activeForegroundColor: accentColor,
              inactiveForegroundColor: AppColors.secondaryText(brightness),
            ),
          ),
          PersistentTabConfig(
            screen: const InsightsTab(),
            item: ItemConfig(
              icon: Icon(tabs[3].icon),
              title: tabs[3].label,
              activeForegroundColor: accentColor,
              inactiveForegroundColor: AppColors.secondaryText(brightness),
            ),
          ),
          PersistentTabConfig(
            screen: const LifeSettingsTab(),
            item: ItemConfig(
              icon: Icon(tabs[4].icon),
              title: tabs[4].label,
              activeForegroundColor: accentColor,
              inactiveForegroundColor: AppColors.secondaryText(brightness),
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => SizedBox(
          height: 84,
          child: _GlassTabBar(
            navBarConfig: navBarConfig,
            tabs: tabs,
            brightness: brightness,
          ),
        ),
        controller: _tabController,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        handleAndroidBackButtonPress: true,
        stateManagement: true,
        screenTransitionAnimation: const ScreenTransitionAnimation(
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.navBarConfig,
    required this.tabs,
    required this.brightness,
  });

  final NavBarConfig navBarConfig;
  final List<_TabSpec> tabs;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = AppColors.accent(brightness);
    final inactiveColor = AppColors.secondaryText(brightness);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.floating(brightness),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.cardGradient(brightness),
              border: Border.all(
                color: AppColors.border(brightness),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final selected = navBarConfig.selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => navBarConfig.onItemSelected(index),
                    child: AnimatedContainer(
                      duration: AppMotion.durationFast,
                      curve: AppMotion.enterCurve,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: selected
                            ? AppColors.accentTint(brightness)
                            : Colors.transparent,
                        border: selected
                            ? Border.all(
                                color: activeColor.withValues(alpha: 0.18),
                                width: 0.6,
                              )
                            : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tabs[index].icon,
                                color: selected ? activeColor : inactiveColor,
                                size: 21,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tabs[index].label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: selected ? activeColor : inactiveColor,
                                  fontSize: 10.5,
                                  height: 1,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
