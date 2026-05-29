import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/data/models/capture_model.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
import 'package:mobile/features/lifeos/presentation/providers/memories_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_detail_screen.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_screen.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class CaptureStatusScreen extends ConsumerWidget {
  const CaptureStatusScreen({super.key, required this.captureId});

  final String captureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(captureStatusProvider(captureId));
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('First memory')),
      body: SafeArea(
        child: stream.when(
          data: (capture) {
            final step = _ProcessingStep.fromStatus(capture.status);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(step.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  step.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText(brightness),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusRow(
                        icon: Icons.save_alt_rounded,
                        label: 'Raw capture saved',
                        isComplete: true,
                      ),
                      _StatusRow(
                        icon: capture.type == 'voice'
                            ? Icons.graphic_eq_rounded
                            : Icons.psychology_alt_outlined,
                        label: capture.type == 'voice'
                            ? 'Transcribing voice'
                            : 'Structuring memory',
                        isComplete: step.index >= 2,
                        isActive: step.index == 1,
                      ),
                      _StatusRow(
                        icon: Icons.rate_review_outlined,
                        label: 'Ready for your review',
                        isComplete: capture.status == 'done',
                        isActive: capture.status == 'done',
                        isFailed: capture.status == 'failed',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                if (capture.status == 'failed')
                  _FailedCard(capture: capture)
                else if (capture.status == 'done')
                  _ReadyMemoryCard(captureId: capture.id)
                else
                  const LinearProgressIndicator(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: '$e'),
        ),
      ),
    );
  }
}

class _ProcessingStep {
  const _ProcessingStep({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  static _ProcessingStep fromStatus(String status) {
    return switch (status) {
      'done' => const _ProcessingStep(
        index: 3,
        title: 'Your memory is ready',
        body:
            'Review what LifeOS understood, correct anything off, then save it to your timeline.',
      ),
      'failed' => const _ProcessingStep(
        index: 0,
        title: 'Processing needs attention',
        body:
            'Your original capture is still saved. You can retry later or create another capture.',
      ),
      'transcribing' => const _ProcessingStep(
        index: 1,
        title: 'Transcribing your capture',
        body:
            'LifeOS is turning the audio into editable text before memory extraction.',
      ),
      'extracting' => const _ProcessingStep(
        index: 2,
        title: 'Structuring your memory',
        body:
            'LifeOS is extracting a title, summary, topics, people, decisions, and actions.',
      ),
      _ => const _ProcessingStep(
        index: 1,
        title: 'Saving your first memory',
        body:
            'Your raw capture is saved. LifeOS is preparing a structured memory for review.',
      ),
    };
  }
}

class _ReadyMemoryCard extends ConsumerWidget {
  const _ReadyMemoryCard({required this.captureId});

  final String captureId;

  Future<MemoryModel?> _loadCandidate(WidgetRef ref) async {
    ref.invalidate(memoryCandidatesProvider);
    final candidates = await ref
        .read(memoriesRepositoryProvider)
        .listCandidates();
    for (final candidate in candidates) {
      if (candidate.rawCaptureId == captureId) return candidate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return FutureBuilder<MemoryModel?>(
      future: _loadCandidate(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final memory = snapshot.data;
        if (memory == null) {
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Review queue updated',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'The capture finished, but the matching candidate was not found in the latest queue response.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText(brightness),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                AppButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const MemoryReviewScreen(),
                    ),
                  ),
                  child: const Text('Open review queue'),
                ),
              ],
            ),
          );
        }

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accent(brightness),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      memory.title.isEmpty ? 'Untitled memory' : memory.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                memory.summary,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (memory.topics.isNotEmpty ||
                  memory.people.isNotEmpty ||
                  memory.actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s16),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    ...memory.topics.take(3).map((t) => _Chip(label: t)),
                    ...memory.people.take(2).map((p) => _Chip(label: '@$p')),
                    ...memory.actions.take(2).map((a) => _Chip(label: a)),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.s20),
              AppButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => MemoryReviewDetailScreen(memory: memory),
                  ),
                ),
                child: const Text('Review this memory'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.isComplete,
    this.isActive = false,
    this.isFailed = false,
  });

  final IconData icon;
  final String label;
  final bool isComplete;
  final bool isActive;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = isFailed
        ? theme.colorScheme.error
        : isComplete || isActive
        ? AppColors.accent(brightness)
        : AppColors.secondaryText(brightness);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.s12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          if (isActive && !isComplete && !isFailed)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isFailed ? Icons.error_outline : Icons.check_circle_outline,
              color: color,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _FailedCard extends StatelessWidget {
  const _FailedCard({required this.capture});

  final CaptureModel capture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final source = capture.transcript ?? capture.body ?? capture.audioUrl;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original capture kept', style: theme.textTheme.titleMedium),
          if (source != null && source.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              source,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.elevated(brightness),
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Text('Could not load capture status: $message'),
      ),
    );
  }
}
