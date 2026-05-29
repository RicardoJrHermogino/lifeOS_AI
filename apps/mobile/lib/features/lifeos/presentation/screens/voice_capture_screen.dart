import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/presentation/providers/captures_provider.dart';
import 'package:mobile/features/lifeos/presentation/screens/capture_status_screen.dart';
import 'package:mobile/shared/widgets/app_button.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceCaptureScreen extends ConsumerStatefulWidget {
  const VoiceCaptureScreen({super.key});

  @override
  ConsumerState<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

class _VoiceCaptureScreenState extends ConsumerState<VoiceCaptureScreen> {
  final _recorder = AudioRecorder();
  final _moodController = TextEditingController();
  final _hostedUrlController = TextEditingController();

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _localPath;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPreparing = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _moodController.dispose();
    _hostedUrlController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_isPreparing || _isRecording) return;
    setState(() {
      _isPreparing = true;
      _error = null;
    });

    try {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        setState(() {
          _isPreparing = false;
          _error = permission.isPermanentlyDenied
              ? 'Microphone access is off. Enable it in app settings or use text capture.'
              : 'Microphone access is needed for voice capture.';
        });
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final capturesDir = Directory('${dir.path}/voice_captures');
      if (!await capturesDir.exists()) {
        await capturesDir.create(recursive: true);
      }

      final path =
          '${capturesDir.path}/lifeos_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_isPaused && mounted) {
          setState(() => _elapsed += const Duration(seconds: 1));
        }
      });

      setState(() {
        _localPath = path;
        _elapsed = Duration.zero;
        _isRecording = true;
        _isPaused = false;
        _isPreparing = false;
      });
    } catch (e) {
      setState(() {
        _isPreparing = false;
        _error = 'Could not start recording: $e';
      });
    }
  }

  Future<void> _pauseOrResume() async {
    if (!_isRecording) return;
    try {
      if (_isPaused) {
        await _recorder.resume();
      } else {
        await _recorder.pause();
      }
      setState(() => _isPaused = !_isPaused);
    } catch (e) {
      setState(() => _error = 'Could not update recording: $e');
    }
  }

  Future<void> _stop() async {
    if (!_isRecording) return;
    try {
      final path = await _recorder.stop();
      _timer?.cancel();
      setState(() {
        _localPath = path ?? _localPath;
        _isRecording = false;
        _isPaused = false;
      });
    } catch (e) {
      setState(() => _error = 'Could not save recording: $e');
    }
  }

  Future<void> _cancel() async {
    try {
      if (_isRecording) await _recorder.stop();
      _timer?.cancel();
      final path = _localPath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
      setState(() {
        _localPath = null;
        _elapsed = Duration.zero;
        _isRecording = false;
        _isPaused = false;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Could not discard recording: $e');
    }
  }

  Future<void> _submitHostedUrl() async {
    final url = _hostedUrlController.text.trim();
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

  Future<void> _submitLocalRecording() async {
    final path = _localPath;
    if (path == null || _isRecording) return;

    final mood = _moodController.text.trim();
    final notifier = ref.read(createCaptureProvider.notifier);
    final result = await notifier.submitVoiceFile(
      path: path,
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
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hasRecording = _localPath != null && !_isRecording;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice capture')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('Record a thought', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'LifeOS saves the audio locally first, then uploads it for transcription when you submit.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText(brightness),
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                children: [
                  _RecordPulse(
                    isRecording: _isRecording,
                    isPaused: _isPaused,
                    brightness: brightness,
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    _formatDuration(_elapsed),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    _statusLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  if (!_isRecording && !hasRecording)
                    AppButton(
                      onPressed: _isPreparing ? null : _start,
                      isLoading: _isPreparing,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record_rounded, size: 18),
                          SizedBox(width: AppSpacing.s8),
                          Text('Start recording'),
                        ],
                      ),
                    )
                  else if (_isRecording)
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            onPressed: _pauseOrResume,
                            isSecondary: true,
                            child: Text(_isPaused ? 'Resume' : 'Pause'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: AppButton(
                            onPressed: _stop,
                            child: const Text('Stop'),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          onPressed: isLoading ? null : _submitLocalRecording,
                          isLoading: isLoading,
                          child: const Text('Upload for transcription'),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        AppButton(
                          onPressed: _start,
                          isSecondary: true,
                          child: const Text('Record again'),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        AppButton(
                          onPressed: _cancel,
                          isSecondary: true,
                          child: const Text('Discard local audio'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s16),
              _ErrorCard(
                message: _error!,
                canOpenSettings: _error!.contains('settings'),
              ),
            ],
            if (hasRecording) ...[
              const SizedBox(height: AppSpacing.s16),
              _LocalRecordingCard(path: _localPath!),
            ],
            const SizedBox(height: AppSpacing.s24),
            TextField(
              controller: _moodController,
              decoration: const InputDecoration(
                labelText: 'Mood (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temporary backend submission',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'You can still paste a hosted audio URL if you already uploaded audio elsewhere.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  TextField(
                    controller: _hostedUrlController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Hosted audio URL',
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: Text(
                        '${state.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  AppButton(
                    onPressed: isLoading ? null : _submitHostedUrl,
                    isLoading: isLoading,
                    child: const Text('Submit hosted audio'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusLabel {
    if (_isPreparing) return 'Preparing microphone...';
    if (_isRecording && _isPaused) return 'Paused';
    if (_isRecording) return 'Recording...';
    if (_localPath != null) return 'Saved locally on this device';
    return 'Ready when you are';
  }
}

class _RecordPulse extends StatelessWidget {
  const _RecordPulse({
    required this.isRecording,
    required this.isPaused,
    required this.brightness,
  });

  final bool isRecording;
  final bool isPaused;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final color = isRecording && !isPaused
        ? Colors.redAccent
        : AppColors.accent(brightness);

    return AnimatedContainer(
      duration: AppMotion.durationStandard,
      width: isRecording ? 132 : 116,
      height: isRecording ? 132 : 116,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.14,
        ),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Icon(
        isPaused ? Icons.pause_rounded : Icons.mic_rounded,
        color: color,
        size: 56,
      ),
    );
  }
}

class _LocalRecordingCard extends StatelessWidget {
  const _LocalRecordingCard({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, color: AppColors.accent(brightness)),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Local audio saved', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.canOpenSettings});

  final String message;
  final bool canOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          if (canOpenSettings) ...[
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              onPressed: openAppSettings,
              isSecondary: true,
              child: const Text('Open settings'),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
