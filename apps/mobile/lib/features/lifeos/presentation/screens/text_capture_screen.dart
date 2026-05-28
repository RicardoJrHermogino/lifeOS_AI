import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/lifeos/presentation/providers/capture_sync_controller.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
import 'package:mobile/features/lifeos/presentation/providers/connectivity_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/capture_status_screen.dart';

class TextCaptureScreen extends ConsumerStatefulWidget {
  const TextCaptureScreen({super.key});

  @override
  ConsumerState<TextCaptureScreen> createState() => _TextCaptureScreenState();
}

class _TextCaptureScreenState extends ConsumerState<TextCaptureScreen> {
  final _controller = TextEditingController();
  final _moodController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    final mood = _moodController.text.trim();
    final moodValue = mood.isEmpty ? null : mood;

    // Offline: queue locally and let the sync controller upload on reconnect.
    final online = ref.read(isOnlineProvider).value ?? true;
    if (!online) {
      await _queueOffline(body, moodValue);
      return;
    }

    final notifier = ref.read(createCaptureProvider.notifier);
    final result = await notifier.submitText(body: body, mood: moodValue);
    if (!mounted) return;

    // Online attempt failed (e.g. transient network) — fall back to the queue.
    if (result == null) {
      await _queueOffline(body, moodValue);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CaptureStatusScreen(captureId: result.id),
      ),
    );
  }

  Future<void> _queueOffline(String body, String? mood) async {
    await ref
        .read(captureSyncControllerProvider.notifier)
        .enqueueText(body: body, mood: mood);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved offline — will sync when connected')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCaptureProvider);
    final isLoading = state.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick thought')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 8,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _moodController,
                decoration: const InputDecoration(
                  labelText: 'Mood (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                child: Text(isLoading ? 'Saving...' : 'Save capture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
