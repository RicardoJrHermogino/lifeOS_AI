// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_tab_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeTabController)
const homeTabControllerProvider = HomeTabControllerProvider._();

final class HomeTabControllerProvider
    extends $NotifierProvider<HomeTabController, int> {
  const HomeTabControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeTabControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeTabControllerHash();

  @$internal
  @override
  HomeTabController create() => HomeTabController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$homeTabControllerHash() => r'dff771930d5a9e642e0cce19c8bad12c53477d83';

abstract class _$HomeTabController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
