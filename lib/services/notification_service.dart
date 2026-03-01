import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Bildirim ayarları
  bool _notificationsEnabled = true;
  bool _zikirRemindersEnabled = true;
  bool _trophyNotificationsEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get zikirRemindersEnabled => _zikirRemindersEnabled;
  bool get trophyNotificationsEnabled => _trophyNotificationsEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone setup
    tz.initializeTimeZones();

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

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Payload ileride gerektiğinde kullanılabilir
      },
    );
    
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    
    // Ayarları yükle
    await _loadSettings();
    
    _isInitialized = true;
    print('Bildirim servisi başlatıldı');
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _zikirRemindersEnabled = prefs.getBool('zikir_reminders_enabled') ?? true;
      _trophyNotificationsEnabled = prefs.getBool('trophy_notifications_enabled') ?? true;
      
      final hour = prefs.getInt('daily_reminder_hour') ?? 9;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Bildirim ayarları yükleme hatası: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('zikir_reminders_enabled', _zikirRemindersEnabled);
      await prefs.setBool('trophy_notifications_enabled', _trophyNotificationsEnabled);
      await prefs.setInt('daily_reminder_hour', _dailyReminderTime.hour);
      await prefs.setInt('daily_reminder_minute', _dailyReminderTime.minute);
    } catch (e) {
      print('Bildirim ayarları kaydetme hatası: $e');
    }
  }

  // Kupa kazanma bildirimi
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      print('Scheduling notification: $title at $scheduledDate');
      
      final tz.TZDateTime scheduledDateTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      print('Timezone converted date: $scheduledDateTZ');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDateTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'zikirmatik_channel',
            'Zikirmatik Bildirimleri',
            channelDescription: 'Zikir hatırlatıcı bildirimleri',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      
      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Kupa kazanma bildirimi
  Future<void> showTrophyNotification(String trophyName, String description) async {
    if (!_notificationsEnabled || !_trophyNotificationsEnabled) return;

    try {
      await _notifications.show(
        1,
        '🏆 Kupa Kazanıldı!',
        '$trophyName\n$description',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trophy_notifications',
            'Kupa Bildirimleri',
            channelDescription: 'Kupa kazanıldığında bildirim gösterir',
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 255, 215, 0),
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            autoCancel: true,
          ),
        ),
      );
    } catch (e) {
      print('Kupa bildirimi hatası: $e');
    }
  }

  // Zikir tamamlama bildirimi
  Future<void> showZikirCompletionNotification(String zikirName, int count, int target) async {
    if (!_notificationsEnabled) return;

    try {
      await _notifications.show(
        2,
        '🎯 Zikir Tamamlandı!',
        '$zikirName\n$count/$target zikir tamamlandı!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general_notifications',
            'Genel Bildirimler',
            channelDescription: 'Genel uygulama bildirimleri',
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 76, 175, 80),
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            autoCancel: true,
          ),
        ),
      );
    } catch (e) {
      print('Zikir tamamlama bildirimi hatası: $e');
    }
  }

  // Ayarları güncelle
  Future<void> updateSettings({
    bool? notificationsEnabled,
    bool? zikirRemindersEnabled,
    bool? trophyNotificationsEnabled,
    TimeOfDay? dailyReminderTime,
  }) async {
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled!;
    if (zikirRemindersEnabled != null) _zikirRemindersEnabled = zikirRemindersEnabled!;
    if (trophyNotificationsEnabled != null) _trophyNotificationsEnabled = trophyNotificationsEnabled!;
    if (dailyReminderTime != null) _dailyReminderTime = dailyReminderTime!;

    await _saveSettings();
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Bildirimleri iptal etme hatası: $e');
    }
  }

  // Günlük hatırlatıcı bildirimi
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_zikirRemindersEnabled) return;

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Eğer belirtilen zaman geçmişse, ertesi gün için planla
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        3, // Benzersiz ID
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Günlük Hatırlatıcılar',
            channelDescription: 'Günlük zikir hatırlatıcıları',
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 33, 150, 243),
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            autoCancel: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
      );

      print('Günlük hatırlatıcı planlandı: $title saat $hour:$minute');
    } catch (e) {
      print('Günlük hatırlatıcı planlama hatası: $e');
    }
  }
}
