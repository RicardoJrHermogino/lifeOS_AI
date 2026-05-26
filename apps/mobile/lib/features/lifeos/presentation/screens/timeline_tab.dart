import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/data/timeline_repository.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class TimelineTab extends ConsumerWidget {
  const TimelineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(timelineProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: async.when(
          data: (page) {
            if (page.groups.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No saved memories yet. Capture and save a memory to see it here.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(timelineProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: page.groups.length,
                itemBuilder: (context, i) {
                  final group = page.groups[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.s12,
                          bottom: AppSpacing.s12,
                        ),
                        child: Text(
                          group.date,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      ...group.memories.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.s12,
                          ),
                          child: _MemoryCard(memory: m),
                        ),
                      ),
                    ],
                  );
                },
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

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(memory.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s8),
          Text(memory.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: 6,
            children: memory.topics
                .take(3)
                .map((t) => Chip(label: Text(t)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
