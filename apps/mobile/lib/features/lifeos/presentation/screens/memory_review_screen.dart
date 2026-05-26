import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/presentation/providers/memories_provider.dart';

class MemoryReviewScreen extends ConsumerWidget {
  const MemoryReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memoryCandidatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Review memories')),
      body: SafeArea(
        child: async.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No candidates to review.'));
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(memoryCandidatesProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _CandidateTile(memory: items[i]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _CandidateTile extends ConsumerStatefulWidget {
  const _CandidateTile({required this.memory});
  final MemoryModel memory;

  @override
  ConsumerState<_CandidateTile> createState() => _CandidateTileState();
}

class _CandidateTileState extends ConsumerState<_CandidateTile> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.memory.title,
  );
  late final TextEditingController _summaryController = TextEditingController(
    text: widget.memory.summary,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(memoryActionsProvider.notifier);
    final m = widget.memory;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.sensitivity != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(label: Text('Sensitive: ${m.sensitivity}')),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _summaryController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Summary'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ...m.topics.map((t) => Chip(label: Text(t))),
                ...m.people.map((p) => Chip(label: Text('@$p'))),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () async {
                    await actions.save(
                      id: m.id,
                      title: _titleController.text,
                      summary: _summaryController.text,
                    );
                  },
                  child: const Text('Save'),
                ),
                OutlinedButton(
                  onPressed: () => actions.archive(m.id),
                  child: const Text('Archive'),
                ),
                TextButton(
                  onPressed: () => actions.delete(m.id),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
