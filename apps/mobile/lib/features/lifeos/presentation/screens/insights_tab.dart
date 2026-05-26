import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/reflections_repository.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(todayReflectionProvider);
    final repo = ref.read(reflectionsRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: async.when(
          data: (reflection) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily reflection',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        reflection.content,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('👍 Helpful'),
                            onPressed: () async {
                              await repo.submitFeedback(
                                id: reflection.id,
                                feedback: 'helpful',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thanks for the feedback'),
                                  ),
                                );
                              }
                            },
                          ),
                          ActionChip(
                            label: const Text('Not accurate'),
                            onPressed: () async {
                              await repo.submitFeedback(
                                id: reflection.id,
                                feedback: 'inaccurate',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thanks for the feedback'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Could not load reflection: $e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
