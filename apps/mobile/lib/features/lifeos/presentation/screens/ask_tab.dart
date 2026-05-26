import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/ask_repository.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class AskTab extends ConsumerStatefulWidget {
  const AskTab({super.key});

  @override
  ConsumerState<AskTab> createState() => _AskTabState();
}

class _AskTabState extends ConsumerState<AskTab> {
  final _controller = TextEditingController();
  AskResult? _result;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask([String? prefill]) async {
    final q = (prefill ?? _controller.text).trim();
    if (q.isEmpty) return;
    if (prefill != null) _controller.text = prefill;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(askRepositoryProvider);
      final result = await repo.ask(q);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
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
                  ActionChip(label: Text(p), onPressed: () => _ask(p)),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_result != null)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_result!.answer, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.s16),
                    if (_result!.citations.isNotEmpty) ...[
                      Text(
                        'Sources',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: 6,
                        children: _result!.citations
                            .map((c) => Chip(label: Text(c.title)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
