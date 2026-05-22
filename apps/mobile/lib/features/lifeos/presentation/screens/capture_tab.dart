import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class CaptureTab extends StatelessWidget {
  const CaptureTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('LifeOS AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Processing queue',
            onPressed: () {},
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              'What should your future self remember?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Speak freely or jot down a fragment. LifeOS will structure it into memory after review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AppCard(
              radius: AppRadii.cardLarge,
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient(brightness),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border(brightness),
                        width: 0.5,
                      ),
                      boxShadow: AppShadows.floating(brightness),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primary(brightness),
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record_rounded, size: 18),
                        SizedBox(width: AppSpacing.s8),
                        Text('Start voice capture'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppButton(
                    onPressed: () {},
                    isSecondary: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 18),
                        SizedBox(width: AppSpacing.s8),
                        Text('Write quick thought'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_alt_outlined,
                        color: AppColors.primary(brightness),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        'Memory preview',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'After capture, AI extracts a title, summary, emotions, people, goals, decisions, and actions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: const [
                      _InfoChip(label: 'Mood'),
                      _InfoChip(label: 'People'),
                      _InfoChip(label: 'Goals'),
                      _InfoChip(label: 'Actions'),
                      _InfoChip(label: 'Topics'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text('Recent captures', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s12),
            const _RecentCaptureTile(
              title: 'Clarified MVP direction',
              time: 'Today, 2:40 PM',
              mood: 'Focused',
              source: Icons.mic_none_rounded,
            ),
            const SizedBox(height: AppSpacing.s12),
            const _RecentCaptureTile(
              title: 'Noticed pressure around launch scope',
              time: 'Today, 8:10 PM',
              mood: 'Stressed',
              source: Icons.edit_note_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient(brightness),
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
        borderRadius: AppRadii.pillRadius,
      ),
      child: Text(label, style: theme.textTheme.labelLarge),
    );
  }
}

class _RecentCaptureTile extends StatelessWidget {
  const _RecentCaptureTile({
    required this.title,
    required this.time,
    required this.mood,
    required this.source,
  });

  final String title;
  final String time;
  final String mood;
  final IconData source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.buttonGradient(brightness),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: AppColors.border(brightness),
                width: 0.5,
              ),
            ),
            child: Icon(source, color: AppColors.primary(brightness), size: 22),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  '$time · $mood',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(brightness),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryText(brightness),
          ),
        ],
      ),
    );
  }
}
