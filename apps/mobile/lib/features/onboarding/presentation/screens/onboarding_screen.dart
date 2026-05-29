import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile/shared/widgets/lifeos_mark.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntroductionScreen(
      globalBackgroundColor: theme.scaffoldBackgroundColor,
      pages: [
        _buildPage(
          theme: theme,
          icon: Icons.memory_rounded,
          brandMark: LifeOsMark(
            size: 54,
            onDarkBackground: theme.brightness == Brightness.dark,
          ),
          gradientColors: [colorScheme.primary, colorScheme.tertiary],
          title: 'Welcome to LifeOS AI',
          body:
              'Capture life fragments through voice or text.\n'
              'Turn them into structured personal memory.',
        ),
        _buildPage(
          theme: theme,
          icon: Icons.graphic_eq_rounded,
          gradientColors: [colorScheme.tertiary, colorScheme.secondary],
          title: 'Remember Naturally',
          body:
              'Speak freely, review what AI understood,\n'
              'and keep your memory accurate.',
        ),
        _buildPage(
          theme: theme,
          icon: Icons.privacy_tip_rounded,
          gradientColors: [colorScheme.secondary, colorScheme.primary],
          title: 'Private by Design',
          body:
              'You control what is remembered,\n'
              'edited, exported, or deleted.',
        ),
      ],
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
      next: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Start',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      onDone: () {
        ref.read(onboardingStateProvider.notifier).completeOnboarding();
      },
      onSkip: () {
        ref.read(onboardingStateProvider.notifier).completeOnboarding();
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(8.0),
        activeSize: const Size(24.0, 8.0),
        activeColor: colorScheme.primary,
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        spacing: const EdgeInsets.symmetric(horizontal: 4),
      ),
      isProgressTap: false,
      curve: Curves.easeOutCubic,
      scrollPhysics: const BouncingScrollPhysics(),
      controlsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }

  PageViewModel _buildPage({
    required ThemeData theme,
    required IconData icon,
    Widget? brandMark,
    required List<Color> gradientColors,
    required String title,
    required String body,
  }) {
    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            height: 1.1,
          ),
        ),
      ),
      bodyWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.47,
          ),
        ),
      ),
      image: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          brandMark ??
                          Icon(
                            icon,
                            size: 32,
                            color: theme.colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.zero,
        bodyPadding: EdgeInsets.symmetric(horizontal: 8),
        titlePadding: EdgeInsets.only(bottom: 0),
        bodyAlignment: Alignment.center,
        imageAlignment: Alignment.center,
      ),
    );
  }
}
