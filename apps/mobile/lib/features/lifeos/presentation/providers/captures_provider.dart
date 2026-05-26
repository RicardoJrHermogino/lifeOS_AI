import 'package:mobile/features/lifeos/data/captures_repository.dart';
import 'package:mobile/features/lifeos/data/models/capture_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'captures_provider.g.dart';

@riverpod
class CreateCapture extends _$CreateCapture {
  @override
  AsyncValue<CaptureModel?> build() => const AsyncValue.data(null);

  Future<CaptureModel?> submitText({required String body, String? mood}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(capturesRepositoryProvider);
      final result = await repo.createCapture(
        type: 'text',
        body: body,
        mood: mood,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<CaptureModel?> submitVoice({
    required String audioUrl,
    String? mood,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(capturesRepositoryProvider);
      final result = await repo.createCapture(
        type: 'voice',
        audioUrl: audioUrl,
        mood: mood,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

/// Polls capture status until done or failed.
@riverpod
Stream<CaptureModel> captureStatus(Ref ref, String captureId) async* {
  final repo = ref.read(capturesRepositoryProvider);
  while (true) {
    final capture = await repo.getCapture(captureId);
    yield capture;
    if (capture.status == 'done' || capture.status == 'failed') {
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }
}
