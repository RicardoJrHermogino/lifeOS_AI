import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/presentation/providers/settings_controller.dart';
import 'package:mobile/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/lifeos_mark.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _requiredConsent = true;
  bool _personalization = true;
  bool _proactiveInsights = false;
  bool _dailyReminder = false;
  String _reflectionTone = 'warm';
  bool _isSaving = false;

  Future<void> _finish() async {
    if (!_requiredConsent || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(settingsControllerProvider.notifier).patch({
        'aiProcessingConsent': _requiredConsent,
        'aiPersonalization': _personalization,
        'proactiveInsights': _proactiveInsights,
        'dailyReminder': _dailyReminder,
        'reflectionTone': _reflectionTone,
      });
      await ref.read(onboardingStateProvider.notifier).completeOnboarding();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save onboarding choices: $e')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceGradient(brightness),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Center(
                child: LifeOsMark(
                  size: 72,
                  onDarkBackground: brightness == Brightness.dark,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Text(
                'Set up your private memory',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  color: AppColors.primary(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'LifeOS turns your captures into editable memories. You control what is processed, remembered, exported, or deleted.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(brightness),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColors.accent(brightness),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Text(
                          'Privacy promise',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const _PromiseRow(
                      icon: Icons.edit_note_rounded,
                      text: 'AI memories are reviewable and editable.',
                    ),
                    const _PromiseRow(
                      icon: Icons.delete_outline_rounded,
                      text: 'You can delete memories or your account data.',
                    ),
                    const _PromiseRow(
                      icon: Icons.download_outlined,
                      text: 'You can export your readable life data.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Required AI processing',
                      subtitle:
                          'Needed to transcribe captures and structure memories.',
                      value: _requiredConsent,
                      onChanged: (value) =>
                          setState(() => _requiredConsent = value),
                    ),
                    _Divider(brightness: brightness),
                    _SwitchTile(
                      icon: Icons.tune_rounded,
                      title: 'Personalized reflections',
                      subtitle: 'Use saved memories to tune summaries.',
                      value: _personalization,
                      onChanged: (value) =>
                          setState(() => _personalization = value),
                    ),
                    _Divider(brightness: brightness),
                    _SwitchTile(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Proactive insights',
                      subtitle: 'Surface patterns after enough memories exist.',
                      value: _proactiveInsights,
                      onChanged: (value) =>
                          setState(() => _proactiveInsights = value),
                    ),
                    _Divider(brightness: brightness),
                    _SwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Daily reminder',
                      subtitle: 'A gentle nudge to capture your day.',
                      value: _dailyReminder,
                      onChanged: (value) =>
                          setState(() => _dailyReminder = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reflection tone', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.s12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'warm', label: Text('Warm')),
                        ButtonSegment(value: 'neutral', label: Text('Neutral')),
                        ButtonSegment(value: 'direct', label: Text('Direct')),
                      ],
                      selected: {_reflectionTone},
                      onSelectionChanged: (values) {
                        setState(() => _reflectionTone = values.first);
                      },
                    ),
                  ],
                ),
              ),
              if (!_requiredConsent) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Required processing must be enabled to use core memory features.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                onPressed: _requiredConsent && !_isSaving ? _finish : null,
                isLoading: _isSaving,
                child: const Text('Continue to first capture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromiseRow extends StatelessWidget {
  const _PromiseRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText(brightness)),
          const SizedBox(width: AppSpacing.s8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.accent(brightness)),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.secondaryText(brightness),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: AppColors.border(brightness));
  }
}
