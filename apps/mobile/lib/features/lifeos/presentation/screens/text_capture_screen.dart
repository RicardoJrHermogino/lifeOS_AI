import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
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
    final notifier = ref.read(createCaptureProvider.notifier);
    final result = await notifier.submitText(
      body: body,
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
