import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            AppCard(
              radius: AppRadii.cardLarge,
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.ambientGlow,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.today_outlined,
                            color: AppColors.primary(brightness),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Text(
                            'Daily reflection',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        'A focused build day with a clear product direction. Your captures show momentum around the LifeOS frontend, with some pressure around keeping scope controlled.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              onPressed: () {},
                              isSecondary: true,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: AppSpacing.s8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: AppButton(
                              onPressed: () {},
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bookmark_border_rounded, size: 18),
                                  SizedBox(width: AppSpacing.s8),
                                  Text('Save'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text('Patterns', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s12),
            const _InsightCard(
              icon: Icons.bolt_outlined,
              title: 'Clarity follows product writing',
              body:
                  'Your strongest focus signals appear after turning broad product ideas into structured docs or flows.',
              evidence: '3 supporting memories',
            ),
            const SizedBox(height: AppSpacing.s12),
            const _InsightCard(
              icon: Icons.warning_amber_rounded,
              title: 'Scope pressure is rising',
              body:
                  'Recent entries mention pressure around launch size. This may be worth reviewing before the next build sprint.',
              evidence: '2 supporting memories',
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.evidence,
  });

  final IconData icon;
  final String title;
  final String body;
  final String evidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient(brightness),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border(brightness),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary(brightness),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s12),
          Text(
            evidence.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText(brightness),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
