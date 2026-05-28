import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/presentation/providers/settings_controller.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  test('build calls get', () async {
    final repo = FakeSettingsRepository();
    final container = makeContainer(settings: repo);

    final settings = await container.read(settingsControllerProvider.future);

    expect(settings.userId, 'user-1');
  });

  test(
    'patch forwards partial map and updates state without loading',
    () async {
      final repo = FakeSettingsRepository();
      final container = makeContainer(settings: repo);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).patch({
        'proactiveInsights': false,
      });

      expect(repo.patches.single, {'proactiveInsights': false});
      expect(
        container.read(settingsControllerProvider).value!.proactiveInsights,
        false,
      );
    },
  );
}
