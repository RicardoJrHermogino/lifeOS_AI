import 'dart:async';

import 'package:mobile/features/lifeos/data/exports_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_controller.g.dart';

/// Drives a single data-export request and polls its status until it is
/// `ready` or `failed`. State is the latest [ExportModel], or null when idle.
@riverpod
class ExportController extends _$ExportController {
  Timer? _timer;

  @override
  ExportModel? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// Requests a new export and starts polling. No-op while one is in flight.
  Future<void> request() async {
    if (state?.status == 'pending') return;
    _timer?.cancel();
    final exp = await ref.read(exportsRepositoryProvider).request();
    state = exp;
    if (exp.status == 'pending') _startPolling(exp.id);
  }

  void _startPolling(String id) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final exp = await ref.read(exportsRepositoryProvider).get(id);
        state = exp;
        if (exp.status != 'pending') timer.cancel();
      } catch (_) {
        // Keep last known state; stop polling on error.
        timer.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = null;
  }
}
