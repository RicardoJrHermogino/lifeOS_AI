// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the user's settings and applies partial updates, keeping the cached
/// state in sync without a full refetch flicker.

@ProviderFor(SettingsController)
const settingsControllerProvider = SettingsControllerProvider._();

/// Loads the user's settings and applies partial updates, keeping the cached
/// state in sync without a full refetch flicker.
final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, SettingsModel> {
  /// Loads the user's settings and applies partial updates, keeping the cached
  /// state in sync without a full refetch flicker.
  const SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() =>
    r'6706f0d21fdecd534059708bfe86f03e964ba5ff';

/// Loads the user's settings and applies partial updates, keeping the cached
/// state in sync without a full refetch flicker.

abstract class _$SettingsController extends $AsyncNotifier<SettingsModel> {
  FutureOr<SettingsModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SettingsModel>, SettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsModel>, SettingsModel>,
              AsyncValue<SettingsModel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
