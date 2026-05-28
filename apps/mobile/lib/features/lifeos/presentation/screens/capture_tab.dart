import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/models/queued_capture.dart';
import 'package:mobile/features/lifeos/presentation/providers/capture_sync_controller.dart';
import 'package:mobile/features/lifeos/presentation/providers/connectivity_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_screen.dart';
import 'package:mobile/features/lifeos/presentation/screens/text_capture_screen.dart';
import 'package:mobile/features/lifeos/presentation/screens/voice_capture_screen.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class CaptureTab extends ConsumerWidget {
  const CaptureTab({super.key});

  void _openVoice(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const VoiceCaptureScreen()));
  }

  void _openText(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TextCaptureScreen()));
  }

  void _openReview(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MemoryReviewScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final online = ref.watch(isOnlineProvider).value ?? true;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('LifeOS AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Review queue',
            onPressed: () => _openReview(context),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (!online) ...[
              const _OfflineBanner(),
              const SizedBox(height: AppSpacing.s16),
            ],
            Text(
              'What should your future self remember?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Speak freely or jot down a fragment. LifeOS will structure it into memory after review.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AppCard(
              radius: AppRadii.cardLarge,
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient(brightness),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border(brightness),
                        width: 0.5,
                      ),
                      boxShadow: AppShadows.floating(brightness),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primary(brightness),
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppButton(
                    onPressed: () => _openVoice(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record_rounded, size: 18),
                        SizedBox(width: AppSpacing.s8),
                        Text('Start voice capture'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppButton(
                    onPressed: () => _openText(context),
                    isSecondary: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 18),
                        SizedBox(width: AppSpacing.s8),
                        Text('Write quick thought'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_alt_outlined,
                        color: AppColors.primary(brightness),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text('Memory preview', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'After capture, AI extracts a title, summary, emotions, people, goals, decisions, and actions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: const [
                      _InfoChip(label: 'Mood'),
                      _InfoChip(label: 'People'),
                      _InfoChip(label: 'Goals'),
                      _InfoChip(label: 'Actions'),
                      _InfoChip(label: 'Topics'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            const _PendingSyncSection(),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.elevated(brightness),
        borderRadius: AppRadii.mediumRadius,
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: AppColors.secondaryText(brightness),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "You're offline. Captures are saved and sync automatically when you reconnect.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows captures waiting to upload, with per-item status and a manual sync.
class _PendingSyncSection extends ConsumerWidget {
  const _PendingSyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final queue = ref.watch(captureSyncControllerProvider).value ?? const [];
    final online = ref.watch(isOnlineProvider).value ?? true;

    if (queue.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Pending sync', style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            Text(
              '${queue.length}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const Spacer(),
            if (online)
              TextButton(
                onPressed: () =>
                    ref.read(captureSyncControllerProvider.notifier).syncNow(),
                child: const Text('Sync now'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < queue.length; i++) ...[
                if (i > 0)
                  Container(
                    height: 0.5,
                    color: AppColors.border(brightness),
                  ),
                _QueuedRow(item: queue[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QueuedRow extends ConsumerWidget {
  const _QueuedRow({required this.item});

  final QueuedCapture item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final (statusLabel, statusColor) = switch (item.status) {
      QueuedCaptureStatus.pending => (
        'Waiting',
        AppColors.secondaryText(brightness),
      ),
      QueuedCaptureStatus.syncing => ('Syncing…', AppColors.accent(brightness)),
      QueuedCaptureStatus.failed => (
        'Failed — will retry',
        theme.colorScheme.error,
      ),
    };

    final preview = item.type == 'voice'
        ? 'Voice capture'
        : (item.body?.trim().isNotEmpty == true
              ? item.body!.trim()
              : 'Text capture');

    return ListTile(
      leading: Icon(
        item.type == 'voice'
            ? Icons.mic_none_rounded
            : Icons.edit_note_rounded,
        color: AppColors.primary(brightness),
      ),
      title: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        statusLabel,
        style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
      ),
      trailing: item.status == QueuedCaptureStatus.syncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => ref
                  .read(captureSyncControllerProvider.notifier)
                  .remove(item.syncId),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient(brightness),
        border: Border.all(color: AppColors.border(brightness), width: 0.5),
        borderRadius: AppRadii.pillRadius,
      ),
      child: Text(label, style: theme.textTheme.labelLarge),
    );
  }
}
