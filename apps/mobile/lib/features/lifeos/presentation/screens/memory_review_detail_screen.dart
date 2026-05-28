import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/captures_repository.dart';
import 'package:mobile/features/lifeos/data/models/capture_model.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/presentation/providers/memories_provider.dart';
import 'package:mobile/features/lifeos/presentation/providers/timeline_controller.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_text_field.dart';
import 'package:mobile/shared/widgets/section_header.dart';

/// Full review/edit experience for a single memory candidate.
///
/// Lets the user inspect the original capture, correct AI-extracted fields, and
/// save (candidate -> saved), archive, or discard the memory. Saving sends user
/// edits as the source of truth via `PATCH /v1/memories/{id}`.
class MemoryReviewDetailScreen extends ConsumerStatefulWidget {
  const MemoryReviewDetailScreen({super.key, required this.memory});

  final MemoryModel memory;

  @override
  ConsumerState<MemoryReviewDetailScreen> createState() =>
      _MemoryReviewDetailScreenState();
}

class _MemoryReviewDetailScreenState
    extends ConsumerState<MemoryReviewDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;

  late DateTime _eventDate;
  late List<String> _emotions;
  late List<String> _people;
  late List<String> _places;
  late List<String> _topics;
  late List<String> _goals;
  late List<String> _decisions;
  late List<String> _actions;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final m = widget.memory;
    _titleController = TextEditingController(text: m.title);
    _summaryController = TextEditingController(text: m.summary);
    _eventDate = m.eventDate;
    _emotions = [...m.emotions];
    _people = [...m.people];
    _places = [...m.places];
    _topics = [...m.topics];
    _goals = [...m.goals];
    _decisions = [...m.decisions];
    _actions = [...m.actions];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  double? _confidence(String key) => widget.memory.confidence[key];

  bool get _isCandidate => widget.memory.status == 'candidate';

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await action();
      ref.invalidate(timelineControllerProvider);
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      if (navigator.canPop()) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() {
    final actions = ref.read(memoryActionsProvider.notifier);
    return _run(
      () => actions.save(
        id: widget.memory.id,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        eventDate: _eventDate,
        emotions: _emotions,
        people: _people,
        places: _places,
        topics: _topics,
        goals: _goals,
        decisions: _decisions,
        actions: _actions,
      ),
      'Memory saved.',
    );
  }

  Future<void> _archive() {
    final actions = ref.read(memoryActionsProvider.notifier);
    return _run(() => actions.archive(widget.memory.id), 'Memory archived.');
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isCandidate ? 'Discard memory?' : 'Delete memory?'),
        content: Text(
          _isCandidate
              ? 'This removes the candidate. Your original capture is kept.'
              : 'This permanently removes the memory from your timeline, search, and reflections. Your original capture is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_isCandidate ? 'Discard' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final actions = ref.read(memoryActionsProvider.notifier);
    await _run(
      () => actions.delete(widget.memory.id),
      _isCandidate ? 'Memory discarded.' : 'Memory deleted.',
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final m = widget.memory;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCandidate ? 'Review memory' : 'Memory'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (m.sensitivity != null) ...[
              _SensitivityBanner(label: m.sensitivity!),
              const SizedBox(height: 16),
            ],
            _SourceCard(rawCaptureId: m.rawCaptureId),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Title'),
            _ConfidenceHint(value: _confidence('title')),
            AppTextField(
              controller: _titleController,
              labelText: 'Title',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Summary'),
            _ConfidenceHint(value: _confidence('summary')),
            AppTextField(
              controller: _summaryController,
              labelText: 'Summary',
              minLines: 3,
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'When'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: _busy ? null : _pickDate,
              child: Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 20,
                    color: AppColors.secondaryText(brightness),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDate(_eventDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    'Change',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent(brightness),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _TagEditor(
              title: 'Emotions',
              values: _emotions,
              onChanged: (v) => setState(() => _emotions = v),
            ),
            _TagEditor(
              title: 'People',
              prefix: '@',
              values: _people,
              onChanged: (v) => setState(() => _people = v),
            ),
            _TagEditor(
              title: 'Places',
              values: _places,
              onChanged: (v) => setState(() => _places = v),
            ),
            _TagEditor(
              title: 'Topics',
              values: _topics,
              onChanged: (v) => setState(() => _topics = v),
            ),
            _TagEditor(
              title: 'Goals',
              values: _goals,
              onChanged: (v) => setState(() => _goals = v),
            ),
            _TagEditor(
              title: 'Decisions',
              values: _decisions,
              onChanged: (v) => setState(() => _decisions = v),
            ),
            _TagEditor(
              title: 'Actions',
              values: _actions,
              onChanged: (v) => setState(() => _actions = v),
            ),
            const SizedBox(height: 24),
            AppButton(
              onPressed: _busy ? null : _save,
              isLoading: _busy,
              child: Text(_isCandidate ? 'Save memory' : 'Save changes'),
            ),
            const SizedBox(height: 12),
            AppButton(
              onPressed: _busy ? null : _archive,
              isSecondary: true,
              child: const Text('Archive'),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _busy ? null : _confirmDelete,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(_isCandidate ? 'Discard candidate' : 'Delete memory'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

/// Loads and shows the original capture (body or transcript). For voice
/// captures with a transcript it allows a correction that re-runs extraction.
class _SourceCard extends ConsumerStatefulWidget {
  const _SourceCard({required this.rawCaptureId});

  final String? rawCaptureId;

  @override
  ConsumerState<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends ConsumerState<_SourceCard> {
  Future<CaptureModel?>? _future;

  @override
  void initState() {
    super.initState();
    final id = widget.rawCaptureId;
    if (id != null) {
      _future = ref.read(capturesRepositoryProvider).getCapture(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rawCaptureId == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return FutureBuilder<CaptureModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final capture = snapshot.data;
        if (capture == null) return const SizedBox.shrink();
        final source = capture.transcript ?? capture.body;
        if (source == null || source.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: capture.type == 'voice' ? 'Original transcript' : 'Original capture',
            ),
            AppCard(
              padding: const EdgeInsets.all(16),
              elevated: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText(brightness),
                      height: 1.5,
                    ),
                  ),
                  if (capture.type == 'voice')
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _editTranscript(capture, source),
                        child: const Text('Correct transcript'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTranscript(CaptureModel capture, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Correct transcript'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          minLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Fix any mis-heard words…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save & re-extract'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || result == current) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(capturesRepositoryProvider)
          .patchTranscript(id: capture.id, transcript: result);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Transcript saved. Re-extracting memory…'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save transcript: $e')),
      );
    }
  }
}

class _SensitivityBanner extends StatelessWidget {
  const _SensitivityBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final tint = AppColors.accentTint(brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: AppRadii.mediumRadius,
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 20,
            color: AppColors.primary(brightness),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Marked sensitive ($label). Review carefully before saving.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a small hint when the AI's confidence for a field is low.
class _ConfidenceHint extends StatelessWidget {
  const _ConfidenceHint({required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null || v >= 0.6) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.secondaryText(brightness),
          ),
          const SizedBox(width: 6),
          Text(
            'Low confidence — please double-check',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editable list of string tags: removable chips plus an add field.
class _TagEditor extends StatefulWidget {
  const _TagEditor({
    required this.title,
    required this.values,
    required this.onChanged,
    this.prefix = '',
  });

  final String title;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String prefix;

  @override
  State<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<_TagEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    if (widget.values.contains(raw)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.values, raw]);
    _controller.clear();
  }

  void _remove(String value) {
    widget.onChanged(widget.values.where((v) => v != value).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: widget.title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...widget.values.map(
                (v) => Chip(
                  label: Text('${widget.prefix}$v'),
                  onDeleted: () => _remove(v),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add ${widget.title.toLowerCase()}…',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText(brightness),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _add,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
