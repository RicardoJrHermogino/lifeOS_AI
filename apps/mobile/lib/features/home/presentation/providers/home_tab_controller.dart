import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_tab_controller.g.dart';

@Riverpod(keepAlive: true)
class HomeTabController extends _$HomeTabController {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}
