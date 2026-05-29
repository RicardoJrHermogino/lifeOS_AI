import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/insights_repository.dart';
import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/data/reflections_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/insights_controller.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_detail_screen.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class InsightsTab extends ConsumerStatefulWidget {
  const InsightsTab({super.key});

  @override
  ConsumerState<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends ConsumerState<InsightsTab> {
  DateTime _date = DateTime.now();
  bool _busy = false;

  String get _dateKey =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  void _shiftDay(int days) {
    final next = _date.add(Duration(days: days));
    if (next.isAfter(DateTime.now())) return;
    setState(() => _date = DateTime(next.year, next.month, next.day));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _feedback(ReflectionModel r, String value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(reflectionsRepositoryProvider)
          .submitFeedback(id: r.id, feedback: value);
      if (!mounted) return;
      ref.invalidate(reflectionForDateProvider(_dateKey));
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks for the feedback')),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(ReflectionModel r) async {
    final controller = TextEditingController(text: r.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit reflection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 10,
          decoration: const InputDecoration(hintText: 'Your reflection…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || result == r.content) return;
    if (!mounted) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(reflectionsRepositoryProvider)
          .update(id: r.id, content: result);
      if (!mounted) return;
      ref.invalidate(reflectionForDateProvider(_dateKey));
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Reflection updated')),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMemory(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final memory = await ref.read(memoriesRepositoryProvider).getById(id);
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => MemoryReviewDetailScreen(memory: memory),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open memory: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(reflectionForDateProvider(_dateKey));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _DateBar(
              label: _isToday ? 'Today' : _dateKey,
              onPrev: () => _shiftDay(-1),
              onNext: _isToday ? null : () => _shiftDay(1),
              onPick: _pickDate,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(reflectionForDateProvider(_dateKey));
                  ref.invalidate(insightsControllerProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 124),
                  children: [
                    ..._reflectionSection(theme, async),
                    const SizedBox(height: AppSpacing.s24),
                    const _PatternsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _reflectionSection(
    ThemeData theme,
    AsyncValue<ReflectionModel> async,
  ) {
    final brightness = theme.brightness;
    return [
      async.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => _inlineCard(
          theme,
          icon: Icons.error_outline,
          iconColor: theme.colorScheme.error,
          title: "Couldn't load reflection",
          message: '$e',
        ),
        data: (r) {
          if (r.content.trim().isEmpty) {
            return _inlineCard(
              theme,
              icon: Icons.auto_awesome_outlined,
              iconColor: AppColors.secondaryText(brightness),
              title: 'No reflection yet',
              message:
                  'Capture and save memories to generate a daily reflection.',
            );
          }
          return _ReflectionCard(
            reflection: r,
            busy: _busy,
            onEdit: () => _edit(r),
            onFeedback: (v) => _feedback(r, v),
            onOpenMemory: _openMemory,
          );
        },
      ),
    ];
  }

  Widget _inlineCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    final brightness = theme.brightness;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.reflection,
    required this.busy,
    required this.onEdit,
    required this.onFeedback,
    required this.onOpenMemory,
  });

  final ReflectionModel reflection;
  final bool busy;
  final VoidCallback onEdit;
  final ValueChanged<String> onFeedback;
  final ValueChanged<String> onOpenMemory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final r = reflection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Daily reflection', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  if (r.isUserEdited) _Pill(label: 'Edited'),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: busy ? null : onEdit,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(r.content, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.s16),
              Wrap(
                spacing: 8,
                children: [
                  _FeedbackChip(
                    label: '👍 Helpful',
                    selected: r.feedback == 'helpful',
                    onPressed: busy ? null : () => onFeedback('helpful'),
                  ),
                  _FeedbackChip(
                    label: 'Not accurate',
                    selected: r.feedback == 'inaccurate',
                    onPressed: busy ? null : () => onFeedback('inaccurate'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (r.sourceMemoryIds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Based on ${r.sourceMemoryIds.length} '
            '${r.sourceMemoryIds.length == 1 ? "memory" : "memories"}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < r.sourceMemoryIds.length; i++)
                ActionChip(
                  avatar: const Icon(Icons.north_east, size: 14),
                  label: Text('Memory ${i + 1}'),
                  onPressed: busy
                      ? null
                      : () => onOpenMemory(r.sourceMemoryIds[i]),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Pattern insights derived from saved memories.
class _PatternsSection extends ConsumerWidget {
  const _PatternsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final async = ref.watch(insightsControllerProvider);
    final isGenerating = async.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Patterns', style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: isGenerating
                  ? null
                  : () => ref
                        .read(insightsControllerProvider.notifier)
                        .generate(),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(isGenerating ? 'Analyzing…' : 'Generate'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            'Could not load insights: $e',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'No patterns yet. Save a few memories, then tap Generate to '
                'surface grounded patterns across them.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              );
            }
            return Column(
              children: [
                for (final insight in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: _InsightCard(insight: insight),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InsightCard extends ConsumerWidget {
  const _InsightCard({required this.insight});

  final InsightModel insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final notifier = ref.read(insightsControllerProvider.notifier);
    final isSaved = insight.status == 'saved';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(insight.title, style: theme.textTheme.titleSmall),
              ),
              _EvidencePill(evidence: insight.evidence),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(insight.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Based on ${insight.sourceMemoryIds.length} memories',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
          const Divider(height: AppSpacing.s24),
          Row(
            children: [
              TextButton(
                onPressed: isSaved ? null : () => notifier.save(insight.id),
                child: Text(isSaved ? 'Saved' : 'Save'),
              ),
              TextButton(
                onPressed: () => notifier.dismiss(insight.id),
                child: const Text('Dismiss'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Helpful',
                visualDensity: VisualDensity.compact,
                color: insight.feedback == 'helpful'
                    ? AppColors.accent(brightness)
                    : null,
                icon: const Icon(Icons.thumb_up_outlined, size: 18),
                onPressed: () => notifier.feedback(insight.id, 'helpful'),
              ),
              IconButton(
                tooltip: 'Not helpful',
                visualDensity: VisualDensity.compact,
                color: insight.feedback == 'not_helpful'
                    ? AppColors.accent(brightness)
                    : null,
                icon: const Icon(Icons.thumb_down_outlined, size: 18),
                onPressed: () => notifier.feedback(insight.id, 'not_helpful'),
              ),
              IconButton(
                tooltip: 'Wrong',
                visualDensity: VisualDensity.compact,
                color: insight.feedback == 'wrong'
                    ? theme.colorScheme.error
                    : null,
                icon: const Icon(Icons.report_gmailerrorred_outlined, size: 18),
                onPressed: () => notifier.feedback(insight.id, 'wrong'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidencePill extends StatelessWidget {
  const _EvidencePill({required this.evidence});

  final String evidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final label = switch (evidence) {
      'strong' => 'Strong',
      'weak' => 'Tentative',
      _ => 'Moderate',
    };
    return _Pill(label: label, color: AppColors.secondaryText(brightness));
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.elevated(brightness),
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color ?? AppColors.secondaryText(brightness),
        ),
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Expanded(
            child: GestureDetector(
              onTap: onPick,
              child: Center(
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.accent(theme.brightness);
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: selected ? accent.withValues(alpha: 0.15) : null,
      side: selected ? BorderSide(color: accent) : null,
    );
  }
}
