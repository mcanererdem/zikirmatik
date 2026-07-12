import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone setup
    tz.initializeTimeZones();
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      debugPrint('Timezone set to: $timezoneName');
    } catch (e) {
      // Eğer cihaz timezone bilgisini vermezse, varsayılan local kalır.
      debugPrint('Failed to set local timezone, using default: $e');
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

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Payload ileride gerektiğinde kullanılabilir
        debugPrint('Bildirim tıklandı: ${response.payload}');
      },
    );
    
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    // İzinleri kontrol et
    bool? granted = await androidImpl?.requestNotificationsPermission();
    debugPrint('Bildirim izni verildi: $granted');
    
    // Bildirim kanallarını oluştur (hatırlatıcılar bu kanalı kullanır)
    const androidChannel = AndroidNotificationChannel(
      'daily_reminders',
      'Günlük Hatırlatıcılar',
      description: 'Günlük zikir hatırlatıcıları',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    await androidImpl?.createNotificationChannel(androidChannel);
    const zikrChannel = AndroidNotificationChannel(
      'zikirmatik_channel',
      'Zikirmatik Bildirimleri',
      description: 'Zikir hatırlatıcı bildirimleri',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    await androidImpl?.createNotificationChannel(zikrChannel);
    debugPrint('Bildirim kanalları oluşturuldu');

    _isInitialized = true;
    debugPrint('Bildirim servisi başlatıldı');
  }

  /// Android 12+ tam saat bildirimleri için exact alarm izni (ayarlar diyaloğundan çağrılır)
  Future<void> requestExactAlarmsPermission() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestExactAlarmsPermission();
  }

  /// 10 saniye (veya verilen süre) sonra tek bir test bildirimi planlar.
  static const int testScheduledId = 998;
  static const int testInstantId = 997;

  /// Hemen bir test bildirimi gösterir (kanal ve izin testi).
  Future<void> showInstantTestNotification() async {
    try {
      await _notifications.show(
        testInstantId,
        'Zikirmatik Test',
        'Bildirimler çalışıyor!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'zikirmatik_channel',
            'Zikirmatik Bildirimleri',
            channelDescription: 'Zikir hatırlatıcı bildirimleri',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
      );
      debugPrint('Anlık test bildirimi gösterildi');
    } catch (e) {
      debugPrint('Anlık test bildirimi hatası: $e');
    }
  }

  Future<void> scheduleTestNotificationInSeconds(int seconds) async {
    try {
      await _notifications.cancel(testScheduledId);
      final scheduledTime = DateTime.now().add(Duration(seconds: seconds));
      final scheduledTz = tz.TZDateTime.from(scheduledTime, tz.local);
      // inexactAllowWhileIdle: birçok cihazda exact kısıtlı; inexact daha az engellenir (birkaç dakika sapma olabilir)
      await _notifications.zonedSchedule(
        testScheduledId,
        'Zikirmatik Test',
        'Bildirimler çalışıyor! ($seconds sn sonra)',
        scheduledTz,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'zikirmatik_channel',
            'Zikirmatik Bildirimleri',
            channelDescription: 'Zikir hatırlatıcı bildirimleri',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Test bildirimi $seconds saniye sonra planlandı ($scheduledTz)');
    } catch (e) {
      debugPrint('Test bildirimi planlama hatası: $e');
    }
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Bildirimleri iptal etme hatası: $e');
    }
  }

  /// Sadece kullandığımız hatırlatıcı ID'lerini iptal et (sabah 1001–1007, akşam 2001–2007)
  Future<void> cancelReminderNotifications() async {
    try {
      const morningIds = [1001, 1002, 1003, 1004, 1005, 1006, 1007];
      const eveningIds = [2001, 2002, 2003, 2004, 2005, 2006, 2007];
      for (final id in [...morningIds, ...eveningIds]) {
        await _notifications.cancel(id);
      }
    } catch (e) {
      debugPrint('Hatırlatıcı iptal hatası: $e');
    }
  }

  /// Ayarlar diyaloğundan çağrılır: sabah/akşam saatleri ve günlere göre hatırlatıcı planla
  Future<void> scheduleReminderNotifications({
    required List<String> selectedDays,
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
    required bool morningEnabled,
    required bool eveningEnabled,
  }) async {
    try {
      await cancelReminderNotifications();
      if (selectedDays.isEmpty) {
        debugPrint('Hatırlatıcı: gün seçilmedi, planlama atlandı');
        return;
      }
      for (String day in selectedDays) {
        final dayIndex = _dayNameToWeekday(day);
        if (morningEnabled) {
          final dt = _nextWeekdayWithTime(DateTime.now(), dayIndex, morningTime.hour, morningTime.minute);
          await _notifications.zonedSchedule(
            1000 + dayIndex,
            'Sabah Zikri',
            'Zikir vakti geldi!',
            tz.TZDateTime.from(dt, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'zikirmatik_channel',
                'Zikirmatik Bildirimleri',
                channelDescription: 'Zikir hatırlatıcı bildirimleri',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
        if (eveningEnabled) {
          final dt = _nextWeekdayWithTime(DateTime.now(), dayIndex, eveningTime.hour, eveningTime.minute);
          await _notifications.zonedSchedule(
            2000 + dayIndex,
            'Akşam Zikri',
            'Zikir vakti geldi!',
            tz.TZDateTime.from(dt, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'zikirmatik_channel',
                'Zikirmatik Bildirimleri',
                channelDescription: 'Zikir hatırlatıcı bildirimleri',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('Hatırlatıcı planlandı. Bekleyen: ${pending.length}');
    } catch (e) {
      debugPrint('Hatırlatıcı planlama hatası: $e');
    }
  }

  int _dayNameToWeekday(String day) {
    switch (day) {
      case 'Monday': return DateTime.monday;
      case 'Tuesday': return DateTime.tuesday;
      case 'Wednesday': return DateTime.wednesday;
      case 'Thursday': return DateTime.thursday;
      case 'Friday': return DateTime.friday;
      case 'Saturday': return DateTime.saturday;
      case 'Sunday': return DateTime.sunday;
      default: return DateTime.monday;
    }
  }

  DateTime _nextWeekdayWithTime(DateTime from, int weekday, int hour, int minute) {
    int daysUntil = (weekday - from.weekday + 7) % 7;

    if (daysUntil == 0) {
      final todayCandidate = DateTime(from.year, from.month, from.day, hour, minute);
      if (todayCandidate.isAfter(from)) {
        return todayCandidate;
      } else {
        daysUntil = 7;
      }
    }

    final next = from.add(Duration(days: daysUntil));
    return DateTime(next.year, next.month, next.day, hour, minute);
  }

}
