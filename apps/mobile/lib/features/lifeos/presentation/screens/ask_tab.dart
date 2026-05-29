import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/ask_repository.dart';
import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_detail_screen.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/profile_icon_button.dart';

class AskTab extends ConsumerStatefulWidget {
  const AskTab({super.key});

  @override
  ConsumerState<AskTab> createState() => _AskTabState();
}

class _AskTabState extends ConsumerState<AskTab> {
  final _controller = TextEditingController();
  String? _question;
  AskResult? _result;
  bool _loading = false;
  bool _opening = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask([String? prefill]) async {
    final q = (prefill ?? _controller.text).trim();
    if (q.isEmpty || _loading) return;
    if (prefill != null) _controller.text = prefill;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _question = q;
      _result = null;
    });
    try {
      final result = await ref.read(askRepositoryProvider).ask(q);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openMemory(String id) async {
    if (_opening) return;
    setState(() => _opening = true);
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
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Ask Memory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [ProfileIconButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 124),
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ask about your goals, moods, people, or decisions',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _loading ? null : () => _ask(),
                ),
              ),
              onSubmitted: (_) => _ask(),
            ),
            const SizedBox(height: AppSpacing.s16),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final p in const [
                  'What did I say about my goals?',
                  'When was I most focused?',
                  'Why was I stressed last week?',
                ])
                  ActionChip(
                    label: Text(p),
                    onPressed: _loading ? null : () => _ask(p),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            ..._buildResult(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResult(ThemeData theme) {
    final brightness = theme.brightness;

    if (_loading) {
      return [
        if (_question != null) ...[
          _QuestionLabel(question: _question!),
          const SizedBox(height: AppSpacing.s16),
        ],
        const Center(child: CircularProgressIndicator()),
      ];
    }

    if (_error != null) {
      return [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Could not answer right now',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              ),
              const SizedBox(height: 12),
              if (_question != null)
                FilledButton(
                  onPressed: () => _ask(_question),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      ];
    }

    final result = _result;
    if (result == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 40,
                color: AppColors.secondaryText(brightness),
              ),
              const SizedBox(height: 12),
              Text(
                'Ask anything about your memories',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Answers are grounded only in what you have captured and saved.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      if (_question != null) ...[
        _QuestionLabel(question: _question!),
        const SizedBox(height: AppSpacing.s16),
      ],
      AppCard(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.answer, style: theme.textTheme.bodyLarge),
            if (result.citations.isEmpty) ...[
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.secondaryText(brightness),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No specific memories matched — answer is based on limited evidence.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryText(brightness),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Sources',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.citations
                    .map(
                      (c) => ActionChip(
                        avatar: const Icon(Icons.north_east, size: 14),
                        label: Text(c.title),
                        onPressed: _opening
                            ? null
                            : () => _openMemory(c.memoryId),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

class _QuestionLabel extends StatelessWidget {
  const _QuestionLabel({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.help_outline,
          size: 18,
          color: AppColors.secondaryText(theme.brightness),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            question,
            style: theme.textTheme.titleSmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
