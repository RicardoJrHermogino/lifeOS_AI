import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/lifeos/presentation/providers/search_controller.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_helpers.dart';

void main() {
  test('empty query short-circuits', () async {
    final repo = FakeSearchRepository();
    final container = makeContainer(search: repo);

    final result = await container.read(searchControllerProvider.future);

    expect(result, isEmpty);
    expect(repo.calls, isEmpty);
  });

  test('debounces and maps results', () async {
    final repo = FakeSearchRepository();
    final container = makeContainer(search: repo);

    container.read(searchQueryProvider.notifier).set('family');
    final result = await container.read(searchControllerProvider.future);

    expect(repo.calls.single['query'], 'family');
    expect(result.single.memoryId, '11111111-1111-4111-8111-111111111111');
    expect(result.single.title, 'Memory');
  });
}
