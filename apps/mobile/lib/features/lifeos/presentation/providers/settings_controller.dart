import 'package:mobile/features/lifeos/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// Loads the user's settings and applies partial updates, keeping the cached
/// state in sync without a full refetch flicker.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsModel> build() {
    return ref.read(settingsRepositoryProvider).get();
  }

  Future<void> patch(Map<String, dynamic> data) async {
    final updated = await ref.read(settingsRepositoryProvider).update(data);
    state = AsyncData(updated);
  }
}
