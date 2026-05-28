import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/presentation/providers/insights_controller.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  test('build calls list', () async {
    final repo = FakeInsightsRepository();
    final container = makeContainer(insights: repo);

    await container.read(insightsControllerProvider.future);

    expect(repo.calls, ['list']);
  });

  test('generate calls generate then refreshes', () async {
    final repo = FakeInsightsRepository();
    final container = makeContainer(insights: repo);

    await container.read(insightsControllerProvider.future);
    await container.read(insightsControllerProvider.notifier).generate();

    expect(repo.calls, ['list', 'generate', 'list']);
  });

  test('save, dismiss, and feedback call repo then refresh state', () async {
    final repo = FakeInsightsRepository();
    final container = makeContainer(insights: repo);

    await container.read(insightsControllerProvider.future);
    await container.read(insightsControllerProvider.notifier).save('i1');
    await container.read(insightsControllerProvider.notifier).dismiss('i1');
    await container
        .read(insightsControllerProvider.notifier)
        .feedback('i1', 'helpful');

    expect(repo.calls, [
      'list',
      'save:i1',
      'list',
      'dismiss:i1',
      'list',
      'feedback:i1:helpful',
      'list',
    ]);
  });
}
