import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_text_field.dart';

class AskTab extends StatelessWidget {
  const AskTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Ask Memory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            AppTextField(
              labelText: 'Ask',
              hintText: 'Ask about your goals, moods, people, or decisions',
              minLines: 1,
              maxLines: 3,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Ask by voice',
                onPressed: () {},
                icon: const Icon(Icons.mic_none_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: const [
                _PromptChip(text: 'What did I say about my goals?'),
                _PromptChip(text: 'When was I most focused?'),
                _PromptChip(text: 'Why was I stressed last week?'),
              ],
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
                        Icons.travel_explore_rounded,
                        color: AppColors.primary(brightness),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        'Grounded answer preview',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'You have talked about launch scope most often when discussing MVP clarity, privacy controls, and memory review. The strongest evidence comes from two memories captured today.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const _SourceTile(
                    title: 'Clarified MVP direction',
                    detail: 'Today, 2:40 PM · focused',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const _SourceTile(
                    title: 'Product identity locked',
                    detail: 'Yesterday, 9:15 PM · clear',
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Confidence: based on 2 memories',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.secondaryText(brightness),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.pillRadius,
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppGradients.cardGradient(brightness),
            border:
                Border.all(color: AppColors.border(brightness), width: 0.5),
            borderRadius: AppRadii.pillRadius,
          ),
          child: Text(text, style: theme.textTheme.labelLarge),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return AppCard(
      elevated: false,
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        children: [
          Icon(Icons.link_rounded, color: AppColors.primary(brightness)),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
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
