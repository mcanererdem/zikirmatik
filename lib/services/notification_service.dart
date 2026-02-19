import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    String timezoneId = 'UTC';
    try {
      const channel = MethodChannel('com.example.zikirmatik/timezone');
      final String? id = await channel.invokeMethod<String>('getLocalTimezoneId');
      if (id != null && id.isNotEmpty) {
        timezoneId = id;
      }
    } catch (_) {}
    try {
      tz.setLocalLocation(tz.getLocation(timezoneId));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

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
    
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    // Uygulama başlarken izinleri iste
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  static Future<bool> hasExactAlarmsPermission() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await androidImpl?.canScheduleExactNotifications() ?? false;
  }

  static Future<bool> scheduleReminder(int hour, int minute) async {
    try {
      final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canSchedule = await androidImpl?.canScheduleExactNotifications() ?? false;

      await cancelAll();
      
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      print('[BILDIRICIM] Scheduling for: $scheduledTime');
      final details = const NotificationDetails(
        android: AndroidNotificationDetails(
          'zikir_reminder',
          'Zikir Reminders',
          channelDescription: 'Daily zikir reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      if (canSchedule) {
        await _notifications.zonedSchedule(
          0,
          'Zikir Reminder ⏰',
          'Time for your daily dhikr! 📿',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        print('[BILDIRICIM] Exact alarm permission not granted. Scheduling inexact daily reminder.');
        await _notifications.zonedSchedule(
          0,
          'Zikir Reminder ⏰',
          'Time for your daily dhikr! 📿',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      
      print('[BILDIRICIM] Scheduled successfully!');
      return true;
    } catch (e) {
      print('[BILDIRICIM] Error: $e');
      return false;
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('[BILDIRICIM] All notifications cancelled');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> showTestNotification() async {
    await _notifications.show(
      1,
      'Test Notification ✅',
      'Notifications are working! If permissions are granted, your reminder will appear at the scheduled time.',
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
