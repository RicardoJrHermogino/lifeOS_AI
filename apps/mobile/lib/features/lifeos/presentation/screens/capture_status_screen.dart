import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_screen.dart';

class CaptureStatusScreen extends ConsumerWidget {
  const CaptureStatusScreen({super.key, required this.captureId});

  final String captureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(captureStatusProvider(captureId));
    return Scaffold(
      appBar: AppBar(title: const Text('Processing capture')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: stream.when(
            data: (capture) {
              final isDone = capture.status == 'done';
              final isFailed = capture.status == 'failed';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Status: ${capture.status}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (!isDone && !isFailed)
                    const LinearProgressIndicator()
                  else if (isFailed)
                    const Text('Processing failed. Please try again later.')
                  else
                    const Text('Memory ready for review.'),
                  const SizedBox(height: 24),
                  if (isDone)
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const MemoryReviewScreen(),
                          ),
                        );
                      },
                      child: const Text('Open review queue'),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}
