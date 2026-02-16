import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

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
    
    final granted = await androidImpl?.requestNotificationsPermission();
    print('[BILDIRICIM] Notification permission: $granted');
    
    final exactAlarmGranted = await androidImpl?.requestExactAlarmsPermission();
    print('[BILDIRICIM] Exact alarm permission: $exactAlarmGranted');
    
    final canSchedule = await androidImpl?.canScheduleExactNotifications();
    print('[BILDIRICIM] Can schedule exact: $canSchedule');
  }

  static Future<void> scheduleReminder(int hour, int minute) async {
    try {
      await cancelAll();
      
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      print('[BILDIRICIM] Scheduling for: $scheduledTime');
      print('[BILDIRICIM] Current: $now');
      print('[BILDIRICIM] Minutes from now: ${scheduledTime.difference(now).inMinutes}');
      
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
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      final pending = await _notifications.pendingNotificationRequests();
      print('[BILDIRICIM] Scheduled! Pending: ${pending.length}');
    } catch (e) {
      print('[BILDIRICIM] Error: $e');
      rethrow;
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
