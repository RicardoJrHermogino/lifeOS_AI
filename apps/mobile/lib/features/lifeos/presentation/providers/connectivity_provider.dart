import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

bool _hasNetwork(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Emits whether the device currently has a network connection. Defaults to
/// `true` until the first reading resolves so we don't wrongly block requests.
@Riverpod(keepAlive: true)
Stream<bool> isOnline(Ref ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield _hasNetwork(initial);
  yield* connectivity.onConnectivityChanged.map(_hasNetwork);
}
