import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/capture_status_screen.dart';

/// Voice capture screen.
///
/// A full native recording pipeline (microphone permission, recorder, upload)
/// requires platform plugins (`record`, `permission_handler`) that are not
/// currently in `pubspec.yaml`. To avoid breaking the build, this screen lets
/// the user paste an already-hosted audio URL (e.g. from cloud storage). The
/// backend transcription worker will fetch it and run Whisper.
///
/// When the `record` and `permission_handler` packages are added, replace the
/// URL field with a record/upload flow that hits the storage layer.
class VoiceCaptureScreen extends ConsumerStatefulWidget {
  const VoiceCaptureScreen({super.key});

  @override
  ConsumerState<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends ConsumerState<VoiceCaptureScreen> {
  final _urlController = TextEditingController();
  final _moodController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    final mood = _moodController.text.trim();
    final notifier = ref.read(createCaptureProvider.notifier);
    final result = await notifier.submitVoice(
      audioUrl: url,
      mood: mood.isEmpty ? null : mood,
    );
    if (!mounted || result == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CaptureStatusScreen(captureId: result.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCaptureProvider);
    final isLoading = state.isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Voice capture')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste a publicly accessible audio URL to transcribe. Native recording will be added once the `record` and `permission_handler` plugins are installed.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Audio URL',
                  hintText: 'https://...',
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
                child: Text(isLoading ? 'Uploading...' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
