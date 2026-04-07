import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules and cancels local push notifications for background timers.
///
/// On web, all operations are no-ops since push notifications
/// are not supported.
class NotificationService {
  NotificationService();

  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  /// Must be called once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    tz.initializeTimeZones();
    _plugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin!.initialize(settings: settings);
    _initialized = true;
  }

  /// Schedules a notification at [fireAt] for a background timer.
  Future<void> scheduleTimerNotification({
    required int stepId,
    required String label,
    required DateTime fireAt,
  }) async {
    if (_plugin == null) return;
    final scheduledDate = tz.TZDateTime.from(fireAt, tz.local);

    await _plugin!.zonedSchedule(
      id: stepId,
      title: 'Stepify',
      body: '⏱ $label — час вийшов!',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel',
          'Таймери',
          channelDescription: 'Сповіщення про завершення таймерів',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels the notification for [stepId].
  Future<void> cancelNotification(int stepId) async {
    await _plugin?.cancel(id: stepId);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin?.cancelAll();
  }
}
