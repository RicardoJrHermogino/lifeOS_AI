import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// Singleton service wrapping [AwesomeNotifications] for local push
/// notification management.
///
/// Call [initialize] once in main.dart before `runApp`, then optionally
/// call [setListeners] after `runApp` so action callbacks have access to
/// the navigator / provider scope.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Registers the default notification channel and requests permission.
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // use default app icon
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Default notification channel',
          defaultColor: const Color(0xFF3B3580),
          ledColor: const Color(0xFFE1F5EE),
          importance: NotificationImportance.High,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
    );

    // Request permission if not already granted
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // ── Listeners ─────────────────────────────────────────────────────────────

  /// Sets the notification action listener.
  ///
  /// Must be called *after* `runApp` so the callback has access to the widget
  /// tree and the navigator.
  Future<void> setListeners({
    required Future<void> Function(ReceivedAction) onAction,
  }) async {
    await AwesomeNotifications().setListeners(onActionReceivedMethod: onAction);
  }

  // ── Scheduled reminders ───────────────────────────────────────────────────

  /// Fixed id for the single daily capture reminder so it can be replaced.
  static const int dailyReminderId = 1001;
  static const int reflectionReadyId = 2001;
  static const int captureProcessedId = 3001;

  /// Schedules (or replaces) a daily repeating capture reminder at [hour]:[minute]
  /// local time. Persisted natively, so it survives app restarts.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().cancel(dailyReminderId);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dailyReminderId,
        channelKey: 'basic_channel',
        title: 'Capture your day',
        body: 'Take a moment to record a thought for your future self.',
        payload: const {'screen': 'capture'},
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Cancels the daily capture reminder, if scheduled.
  Future<void> cancelDailyReminder() async {
    await AwesomeNotifications().cancel(dailyReminderId);
  }

  // ── Show notification ─────────────────────────────────────────────────────

  /// Shows a simple local notification.
  Future<void> show({
    required String title,
    required String body,
    Map<String, String?>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  Future<void> showReflectionReady({required String date}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reflectionReadyId,
        channelKey: 'basic_channel',
        title: 'Reflection ready',
        body: 'Your reflection for $date is ready.',
        payload: {'screen': 'insights', 'kind': 'reflection', 'date': date},
        category: NotificationCategory.Reminder,
      ),
    );
  }

  Future<void> showCaptureProcessed({
    required String memoryId,
    required String title,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: captureProcessedId,
        channelKey: 'basic_channel',
        title: 'Memory ready',
        body: title,
        payload: {'screen': 'timeline', 'kind': 'memory', 'memoryId': memoryId},
        category: NotificationCategory.Status,
      ),
    );
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    AwesomeNotifications().dispose();
  }
}
