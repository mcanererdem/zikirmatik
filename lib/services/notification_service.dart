import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
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
    
    // Ayarları yükle
    await _loadSettings();
    
    _isInitialized = true;
    debugPrint('Bildirim servisi başlatıldı');
  }

  /// Android 12+ tam saat bildirimleri için exact alarm izni (ayarlar diyaloğundan çağrılır)
  Future<void> requestExactAlarmsPermission() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestExactAlarmsPermission();
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
      debugPrint('Bildirim ayarları yükleme hatası: $e');
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
      debugPrint('Bildirim ayarları kaydetme hatası: $e');
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
      debugPrint('Scheduling notification: $title at $scheduledDate');
      
      final tz.TZDateTime scheduledDateTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('Timezone converted date: $scheduledDateTZ');
      
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
            importance: Importance.max,
            priority: Priority.max,
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
      
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
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
      debugPrint('Kupa bildirimi hatası: $e');
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
      debugPrint('Zikir tamamlama bildirimi hatası: $e');
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

  // Anlık bildirim test
  Future<void> showTestNotification() async {
    try {
      // Basit bildirim testi
      await _notifications.show(
        999, // Test için benzersiz ID
        'Test Bildirimi',
        'Bildirimler çalışıyor! Saat: ${DateTime.now().toString().substring(11, 16)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Bildirimleri',
            channelDescription: 'Test bildirimleri',
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 33, 150, 243),
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            autoCancel: true,
          ),
        ),
      );
      
      debugPrint('Test bildirimi gösterildi');
      
      // 5 saniye sonra planlanmış bildirim test
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      final scheduledTime = now.add(const Duration(seconds: 5));
      
      await _notifications.zonedSchedule(
        1000, // Planlanmış test için ID
        'Planlanmış Test',
        'Bu bildirim 5 saniye sonra gösterilmeliydi! Saat: ${scheduledTime.toString().substring(11, 16)}',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Bildirimleri',
            channelDescription: 'Test bildirimleri',
            icon: '@mipmap/ic_launcher',
            color: Color.fromARGB(255, 255, 152, 0),
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            autoCancel: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      debugPrint('Planlanmış test bildirimi 5 saniye sonra gösterilecek');
      
    } catch (e) {
      debugPrint('Test bildirimi hatası: $e');
    }
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

  // Günlük hatırlatıcı bildirimi
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    List<String>? selectedDays,
  }) async {
    if (!_zikirRemindersEnabled) {
      debugPrint('Zikir hatırlatıcılar devre dışı');
      return;
    }

    try {
      // Önceki bildirimleri iptal et
      await _notifications.cancel(3);
      
      final now = DateTime.now();
      debugPrint('Current time (local): ${now.toString()}');
      debugPrint('Scheduling reminder for $hour:$minute');
      
      if (selectedDays != null && selectedDays.isNotEmpty) {
        debugPrint('Selected days: $selectedDays');
        
        // Her seçilen gün için bildirim planla
        for (int i = 0; i < selectedDays.length; i++) {
          final dayName = selectedDays[i];
          final dayIndex = _getDayIndex(dayName);
          
          if (dayIndex >= 0) {
            var scheduledDate = _getNextWeekday(now, dayIndex, hour, minute);
            
            await _notifications.zonedSchedule(
              3 + i, // Benzersiz ID
              title,
              body,
              tz.TZDateTime.from(scheduledDate, tz.local),
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'daily_reminders',
                  'Günlük Hatırlatıcılar',
                  channelDescription: 'Günlük zikir hatırlatıcıları',
                  icon: '@mipmap/ic_launcher',
                  color: Color.fromARGB(255, 33, 150, 243),
                  importance: Importance.max,
                  priority: Priority.max,
                  showWhen: true,
                  autoCancel: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Haftanın günü ve saat
            );
            
            debugPrint('Hatırlatıcı planlandı: $title ($dayName) saat $hour:$minute - ${scheduledDate.toString()}');
          }
        }
      } else {
        // Gün seçimi yoksa her gün planla
        var scheduledDate = DateTime(
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
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminders',
              'Günlük Hatırlatıcılar',
              channelDescription: 'Günlük zikir hatırlatıcıları',
              icon: '@mipmap/ic_launcher',
              color: Color.fromARGB(255, 33, 150, 243),
              importance: Importance.max,
              priority: Priority.max,
              showWhen: true,
              autoCancel: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Her gün tekrarla
        );

        debugPrint('Günlük hatırlatıcı planlandı: $title saat $hour:$minute - ${scheduledDate.toString()}');
      }
      
      // Bekleyen bildirimleri kontrol et
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      debugPrint('Bekleyen bildirim sayısı: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        debugPrint('ID: ${notification.id}, Title: ${notification.title}');
      }
      
    } catch (e) {
      debugPrint('Günlük hatırlatıcı planlama hatası: $e');
    }
  }
  
  // Gün adını index'e çevir
  int _getDayIndex(String dayName) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Pzr'];
    return days.indexOf(dayName);
  }
  
  // Bir sonraki belirtilen günü hesapla
  DateTime _getNextWeekday(DateTime now, int targetDayIndex, int hour, int minute) {
    int currentDayIndex = now.weekday % 7; // Pazartesi=1, Pazar=7 -> 0-6 formatına çevir
    if (currentDayIndex == 0) currentDayIndex = 6; // Pazar'ı 6 yap
    else currentDayIndex--; // Diğer günleri 0-5 arasına getir
    
    int daysUntilTarget = (targetDayIndex - currentDayIndex + 7) % 7;
    if (daysUntilTarget == 0) daysUntilTarget = 7; // Bugün ise bir sonraki hafta
    
    var nextDate = now.add(Duration(days: daysUntilTarget));
    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      hour,
      minute,
    );
  }
}
