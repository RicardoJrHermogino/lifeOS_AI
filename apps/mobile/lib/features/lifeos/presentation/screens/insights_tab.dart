import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/data/reflections_repository.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(reflectionsRepositoryProvider)
          .submitFeedback(id: r.id, feedback: value);
      ref.invalidate(reflectionForDateProvider(_dateKey));
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks for the feedback')),
      );
    } catch (e) {
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(reflectionsRepositoryProvider)
          .update(id: r.id, content: result);
      ref.invalidate(reflectionForDateProvider(_dateKey));
      messenger.showSnackBar(
        const SnackBar(content: Text('Reflection updated')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMemory(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final memory = await ref.read(memoriesRepositoryProvider).getById(id);
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => MemoryReviewDetailScreen(memory: memory),
        ),
      );
    } catch (e) {
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
                onRefresh: () async =>
                    ref.invalidate(reflectionForDateProvider(_dateKey)),
                child: async.when(
                  data: (r) => _content(theme, r),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorOrEmpty(
                    message: '$e',
                    onRetry: () =>
                        ref.invalidate(reflectionForDateProvider(_dateKey)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeData theme, ReflectionModel r) {
    final brightness = theme.brightness;
    if (r.content.trim().isEmpty) {
      return _ErrorOrEmpty(
        message: 'No reflection for this day yet. Capture and save memories to '
            'generate one.',
        onRetry: () => ref.invalidate(reflectionForDateProvider(_dateKey)),
        isEmpty: true,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  if (r.isUserEdited)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.elevated(brightness),
                        borderRadius: AppRadii.pillRadius,
                        border: Border.all(
                          color: AppColors.border(brightness),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Edited',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: _busy ? null : () => _edit(r),
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
                    onPressed: _busy ? null : () => _feedback(r, 'helpful'),
                  ),
                  _FeedbackChip(
                    label: 'Not accurate',
                    selected: r.feedback == 'inaccurate',
                    onPressed: _busy ? null : () => _feedback(r, 'inaccurate'),
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
                  onPressed: _busy
                      ? null
                      : () => _openMemory(r.sourceMemoryIds[i]),
                ),
            ],
          ),
        ],
      ],
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
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onPick,
              child: Center(
                child: Text(label, style: theme.textTheme.titleSmall),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
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

class _ErrorOrEmpty extends StatelessWidget {
  const _ErrorOrEmpty({
    required this.message,
    required this.onRetry,
    this.isEmpty = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
          child: Column(
            children: [
              Icon(
                isEmpty ? Icons.auto_awesome_outlined : Icons.error_outline,
                size: 44,
                color: isEmpty
                    ? AppColors.secondaryText(brightness)
                    : theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                isEmpty ? 'No reflection yet' : "Couldn't load reflection",
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              ),
              if (!isEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: FilledButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
