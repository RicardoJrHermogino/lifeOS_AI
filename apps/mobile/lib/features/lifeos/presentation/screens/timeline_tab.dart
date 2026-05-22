import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class TimelineTab extends StatelessWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filter timeline',
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              'Your life, organized by memory.',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s16),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FilterChip(label: 'All', selected: true),
                  _FilterChip(label: 'Mood'),
                  _FilterChip(label: 'People'),
                  _FilterChip(label: 'Goals'),
                  _FilterChip(label: 'Decisions'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            const _DayHeader(label: 'Today'),
            const _TimelineMemory(
              time: '2:40 PM',
              title: 'Clarified MVP direction',
              summary:
                  'Defined the first frontend surface for LifeOS AI and separated MVP memory capture from future proactive intelligence.',
              mood: 'Focused',
              icon: Icons.flag_outlined,
            ),
            const _TimelineMemory(
              time: '8:10 PM',
              title: 'Launch pressure surfaced',
              summary:
                  'Noted stress around execution timelines and the need to keep the first build focused.',
              mood: 'Stressed',
              icon: Icons.monitor_heart_outlined,
            ),
            const _DayHeader(label: 'Yesterday'),
            const _TimelineMemory(
              time: '9:15 PM',
              title: 'Product identity locked',
              summary:
                  'Captured that LifeOS AI should feel like a private second mind, not a chatbot or task manager.',
              mood: 'Clear',
              icon: Icons.auto_awesome_outlined,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.pillRadius,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? AppGradients.buttonGradient(brightness)
                  : AppGradients.cardGradient(brightness),
              border:
                  Border.all(color: AppColors.border(brightness), width: 0.5),
              borderRadius: AppRadii.pillRadius,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12, top: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.secondaryText(brightness),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimelineMemory extends StatelessWidget {
  const _TimelineMemory({
    required this.time,
    required this.title,
    required this.summary,
    required this.mood,
    required this.icon,
    this.isLast = false,
  });

  final String time;
  final String title;
  final String summary;
  final String mood;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 4),
                    width: 1,
                    height: 80,
                    color: AppColors.border(brightness),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AppCard(
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
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(summary, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    mood.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryText(brightness),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
