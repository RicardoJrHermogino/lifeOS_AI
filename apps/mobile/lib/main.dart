import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/features/home/presentation/providers/home_tab_controller.dart';
import 'package:mobile/features/lifeos/data/memories_repository.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_detail_screen.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/notifications/notification_service.dart';
import 'package:mobile/services/storage/secure_storage_service.dart';
import 'package:mobile/services/storage/theme_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProviderContainer? _appContainer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize awesome_notifications before runApp so channels are registered.
  await NotificationService.instance.initialize();

  // Initialize services in parallel for faster startup
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    Future.value(SecureStorageService()),
  ]);

  final sharedPreferences = results[0] as SharedPreferences;
  final storage = results[1] as SecureStorageService;
  final dio = await createDio(storage);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      secureStorageProvider.overrideWithValue(storage),
      dioProvider.overrideWithValue(dio),
    ],
  );
  _appContainer = container;

  runApp(UncontrolledProviderScope(container: container, child: const App()));

  // Set up notification action listeners after runApp so navigation and
  // UI updates work correctly when the user taps a notification.
  await NotificationService.instance.setListeners(
    onAction: _handleNotificationAction,
  );
}

/// Global handler for notification tap and action button events.
///
/// This runs on the main isolate after [runApp], so it has access to the
/// navigator and can route the user to the appropriate screen. Extend this
/// function to add routing logic based on the payload.
@pragma('vm:entry-point')
Future<void> _handleNotificationAction(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload;
  if (payload == null) return;

  final screen = payload['screen'];
  debugPrint(
    'Notification action received: '
    'buttonKey=${receivedAction.buttonKeyPressed}, '
    'screen=$screen',
  );

  final container = _appContainer;
  if (container == null) return;

  switch (screen) {
    case 'capture':
      container.read(homeTabControllerProvider.notifier).setIndex(0);
      break;
    case 'timeline':
      container.read(homeTabControllerProvider.notifier).setIndex(1);
      final memoryId = payload['memoryId'];
      if (memoryId == null || memoryId.isEmpty) break;
      final memory = await container
          .read(memoriesRepositoryProvider)
          .getById(memoryId);
      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) break;
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MemoryReviewDetailScreen(memory: memory),
        ),
      );
      break;
    case 'insights':
      container.read(homeTabControllerProvider.notifier).setIndex(3);
      break;
  }
}
