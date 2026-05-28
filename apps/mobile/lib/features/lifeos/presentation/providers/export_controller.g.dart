// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives a single data-export request and polls its status until it is
/// `ready` or `failed`. State is the latest [ExportModel], or null when idle.

@ProviderFor(ExportController)
const exportControllerProvider = ExportControllerProvider._();

/// Drives a single data-export request and polls its status until it is
/// `ready` or `failed`. State is the latest [ExportModel], or null when idle.
final class ExportControllerProvider
    extends $NotifierProvider<ExportController, ExportModel?> {
  /// Drives a single data-export request and polls its status until it is
  /// `ready` or `failed`. State is the latest [ExportModel], or null when idle.
  const ExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportControllerHash();

  @$internal
  @override
  ExportController create() => ExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportModel?>(value),
    );
  }
}

String _$exportControllerHash() => r'f6389a3ce5c116ec15cbf8cbcb91d42b1882e452';

/// Drives a single data-export request and polls its status until it is
/// `ready` or `failed`. State is the latest [ExportModel], or null when idle.

abstract class _$ExportController extends $Notifier<ExportModel?> {
  ExportModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExportModel?, ExportModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExportModel?, ExportModel?>,
              ExportModel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
