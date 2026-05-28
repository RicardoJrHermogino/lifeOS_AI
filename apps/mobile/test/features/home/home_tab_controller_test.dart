import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/presentation/providers/home_tab_controller.dart';

import '../../helpers/test_helpers.dart';

void main() {
  test('defaults to capture tab and updates index', () {
    final container = makeContainer();

    expect(container.read(homeTabControllerProvider), 0);

    container.read(homeTabControllerProvider.notifier).setIndex(3);

    expect(container.read(homeTabControllerProvider), 3);
  });
}
