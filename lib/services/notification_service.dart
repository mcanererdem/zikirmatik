import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul')); // Default timezone

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    
    // Request permissions
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
    print('Notification permissions requested');
  }

  static Future<void> scheduleReminder(int hour, int minute) async {
    try {
      await cancelAll();
      
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      print('Scheduling notification for: $scheduledTime');
      print('Current time: ${tz.TZDateTime.now(tz.local)}');
      
      await _notifications.zonedSchedule(
        0,
        'Zikir Reminder ⏰',
        'Time for your daily dhikr! 📿',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'zikir_reminder',
            'Zikir Reminders',
            channelDescription: 'Daily zikir reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      // Verify scheduled notification
      final pending = await _notifications.pendingNotificationRequests();
      print('Pending notifications: ${pending.length}');
      for (var notif in pending) {
        print('ID: ${notif.id}, Title: ${notif.title}');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> showTestNotification() async {
    await _notifications.show(
      1,
      'Test Notification ✅',
      'Notifications are working! Your reminder is scheduled.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'zikir_reminder',
          'Zikir Reminders',
          channelDescription: 'Daily zikir reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
