import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const NotificationSettingsDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  bool _isNotificationEnabled = false;
  List<String> _selectedDays = [];
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  bool _morningNotification = true;
  bool _eveningNotification = true;
  
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    tz.initializeTimeZones();
  }

  Future<void> _loadSettings() async {
    final isNotificationEnabled = await _settingsService.getReminderEnabled();
    final selectedDays = await _settingsService.getNotificationDays();
    final morningTime = await _settingsService.getMorningNotificationTime();
    final eveningTime = await _settingsService.getEveningNotificationTime();
    final morningNotification = await _settingsService.getMorningNotificationEnabled();
    final eveningNotification = await _settingsService.getEveningNotificationEnabled();

    setState(() {
      _isNotificationEnabled = isNotificationEnabled;
      _selectedDays = selectedDays;
      _morningTime = morningTime;
      _eveningTime = eveningTime;
      _morningNotification = morningNotification;
      _eveningNotification = eveningNotification;
    });
  }

  Future<void> _saveSettings() async {
    try {
      print('Saving notification settings...');
      print('Enabled: $_isNotificationEnabled');
      print('Morning enabled: $_morningNotification');
      print('Evening enabled: $_eveningNotification');
      print('Morning time: $_morningTime');
      print('Evening time: $_eveningTime');
      print('Selected days: $_selectedDays');
      
      await _settingsService.saveReminderEnabled(_isNotificationEnabled);
      await _settingsService.saveNotificationDays(_selectedDays);
      await _settingsService.saveMorningNotificationTime(_morningTime);
      await _settingsService.saveEveningNotificationTime(_eveningTime);
      await _settingsService.saveMorningNotificationEnabled(_morningNotification);
      await _settingsService.saveEveningNotificationEnabled(_eveningNotification);

      // Bildirimleri yeniden planla (izin varsa)
      if (_isNotificationEnabled) {
        final granted = await _requestNotificationPermissionWithRationale(context);
        if (granted) {
          await _notificationService.requestExactAlarmsPermission();
          await _notificationService.scheduleReminderNotifications(
            selectedDays: _selectedDays,
            morningTime: _morningTime,
            eveningTime: _eveningTime,
            morningEnabled: _morningNotification,
            eveningEnabled: _eveningNotification,
          );
        } else {
          await _settingsService.saveReminderEnabled(false);
          setState(() => _isNotificationEnabled = false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Bildirimler için izin gerekli. Ayarlardan açabilirsiniz.',
                    'en': 'Notification permission required. You can enable it in Settings.',
                    'ar': 'الإشعارات تتطلب إذناً. يمكنك تفعيله من الإعدادات.',
                    'id': 'Izin notifikasi diperlukan. Aktifkan di Pengaturan.',
                    'ur': 'نوٹیفکیشن کے لیے اجازت ضروری ہے۔ آپ اسے ترتیبات میں فعال کر سکتے ہیں۔',
                    'ms': 'Izin pemberitahuan diperlukan. Anda boleh mengaktifkannya dalam Tetapan.',
                    'fa': 'برای اعلان‌ها اجازه لازم است. از تنظیمات فعال کنید.',
                    'zh': '需要通知权限。可在设置中开启。',
                    'ja': '通知の許可が必要です。設定で有効にできます。',
                    'ru': 'Нужно разрешение на уведомления. Включите в настройках.',
                    'de': 'Benachrichtigungsberechtigung nötig. In Einstellungen aktivieren.',
                  }),
                ),
              ),
            );
          }
        }
      } else {
        await _notificationService.cancelReminderNotifications();
      }

      print('Notification settings saved successfully');
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  /// Android 13+ POST_NOTIFICATIONS isteği; gerekirse rationale gösterir.
  Future<bool> _requestNotificationPermissionWithRationale(BuildContext context) async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Bildirim izni',
              'en': 'Notification permission',
              'ar': 'إذن الإشعارات',
              'id': 'Izin notifikasi',
              'ur': 'نوٹیفکیشن کی اجازت',
              'ms': 'Kebenaran pemberitahuan',
              'zh': '通知权限',
              'ja': '通知の許可',
              'ru': 'Разрешение уведомлений',
              'de': 'Benachrichtigungsberechtigung',
            }),
          ),
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': 'Zikir hatırlatıcılarının çalışması için bildirim izni gereklidir. İzin verilsin mi?',
              'en': 'Notification permission is needed for dhikr reminders. Allow?',
              'ar': 'مطلوب إذن الإشعارات لتذكيرات الذكر. السماح؟',
              'id': 'Izin notifikasi diperlukan untuk pengingat zikir. Izinkan?',
              'ur': 'ذکر کی یاد دہانیوں کے لیے نوٹیفکیشن کی اجازت ضروری ہے۔ کیا اجازت دی جائے؟',
              'ms': 'Izin pemberitahuan diperlukan untuk pengingat dhikr. Benarkan?',
              'zh': '需要通知权限以发送记念提醒。是否允许？',
              'ja': 'ジクルリマインダーには通知の許可が必要です。許可しますか？',
              'ru': 'Для напоминаний о зикре нужно разрешение. Разрешить?',
              'de': 'Für Zikir-Erinnerungen ist die Benachrichtigungsberechtigung nötig. Erlauben?',
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        ),
      );
      if (shouldOpen != true) return false;
    }
    status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> _selectTime({required bool isMorning}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morningTime : _eveningTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: widget.themeConfig.accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9; // biraz daha yüksek
    
    return Dialog(
      backgroundColor: widget.themeConfig.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: dialogHeight,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.themeConfig.primaryColor,
              widget.themeConfig.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (biraz daha kompakt)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: widget.themeConfig.accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DynamicLocalizationHelper.getText({
                        'tr': 'Bildirim Ayarları',
                        'en': 'Notification Settings',
                        'ar': 'إعدادات الإشعارات',
                        'id': 'Pengaturan Notifikasi',
                        'ur': 'اطلاعات آن کریں',
                        'ms': 'Tetapan Pemberitahuan',
                      }),
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content (mevcut kaydırma alanı)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
              // Ana bildirim switch
              _buildSwitchTile(
                DynamicLocalizationHelper.getText({
                  'tr': 'Bildirimleri Aç',
                  'en': 'Enable Notifications',
                  'ar': 'تفعيل الإشعارات',
                  'id': 'Aktifkan Notifikasi',
                  'ur': 'اطلاعات آن کریں',
                  'ms': 'Aktifkan Pemberitahuan',
                }),
                DynamicLocalizationHelper.getText({
                  'tr': 'Zikir hatırlatıcılarını etkinleştir',
                  'en': 'Enable dhikr reminder notifications',
                  'ar': 'تفعيل إشعارات تذكيرات الذكر',
                  'id': 'Aktifkan notifikasi pengingat zikir',
                  'ur': 'ذکر کی یاد دہانی کی اطلاعات آن کریں',
                  'ms': 'Aktifkan notifikasi peringatan dhikr',
                }),
                _isNotificationEnabled,
                (value) => setState(() => _isNotificationEnabled = value),
              ),
              
              if (_isNotificationEnabled) ...[
                const SizedBox(height: 20),
                
                // Gün seçimi
                Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Hatırlatma Günleri',
                    'en': 'Reminder Days',
                    'ar': 'أيام التذكير',
                    'id': 'Hari Pengingat',
                    'ur': 'یاد دہانی کے دن',
                    'ms': 'Hari Peringatan',
                  }),
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDaySelector(),
                
                const SizedBox(height: 24),
                
                // Sabah bildirimi
                _buildNotificationTimeCard(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Sabah Bildirimi',
                    'en': 'Morning Notification',
                    'ar': 'إشعار صباحي',
                    'id': 'Notifikasi Pagi',
                    'ur': 'صبح کی اطلاع',
                    'ms': 'Pemberitahuan Pagi',
                  }),
                  DynamicLocalizationHelper.getText({
                    'tr': 'Sabah zikri hatırlatıcısı',
                    'en': 'Morning dhikr reminder',
                    'ar': 'تذكير ذكر صباحًا',
                    'id': 'Pengingat zikir pagi',
                    'ur': 'صبح کا ذکر یاد دہانی',
                    'ms': 'Peringatan dhikr waktu pagi',
                  }),
                  _morningNotification,
                  _morningTime,
                  true,
                ),
                
                const SizedBox(height: 16),
                
                // Akşam bildirimi
                _buildNotificationTimeCard(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Akşam Bildirimi',
                    'en': 'Evening Notification',
                    'ar': 'إشعار مسائي',
                    'id': 'Notifikasi Malam',
                    'ur': 'شام کی اطلاع',
                    'ms': 'Pemberitahuan Petang',
                  }),
                  DynamicLocalizationHelper.getText({
                    'tr': 'Akşam zikri hatırlatıcısı',
                    'en': 'Evening dhikr reminder',
                    'ar': 'تذكير ذكر مساءً',
                    'id': 'Pengingat zikir malam',
                    'ur': 'شام کا ذکر یاد دہانی',
                    'ms': 'Peringatan dhikr waktu petang',
                  }),
                  _eveningNotification,
                  _eveningTime,
                  false,
                ),
              ],
                  ],
                ),
              ),
            ),
            
            // Test bildirimi butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _notificationService.requestExactAlarmsPermission();
                  await _notificationService.scheduleTestNotificationInSeconds(10);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          DynamicLocalizationHelper.getText({
                            'tr': '10 saniye sonra test bildirimi gelecek. Uygulamayı kapatıp bekleyin.',
                            'en': 'Test notification in 10 seconds. Minimize app and wait.',
                            'ur': '10 سیکنڈ بعد ٹیسٹ نوٹیفکیشن آئے گا۔ ایپ کو کم سے کم کر کے انتظار کریں۔',
                            'ms': 'Notifikasi ujian dalam 10 saat. Minimumkan aplikasi dan tunggu.',
                          }),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active, size: 20),
                label: Text(
                  DynamicLocalizationHelper.getText({
                    'tr': 'Bildirimi test et (10 sn)',
                    'en': 'Test notification (10 sec)',
                    'ur': 'نوٹیفکیشن ٹیسٹ کریں (10 سیکنڈ)',
                    'ms': 'Uji pemberitahuan (10 saat)',
                  }),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.themeConfig.accentColor,
                  side: BorderSide(color: widget.themeConfig.accentColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // İpucu: Bildirimlerin zamanında gelmesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                DynamicLocalizationHelper.getText({
                  'tr': 'Bildirimlerin zamanında gelmesi için uygulamayı pil optimizasyonundan muaf tutmanız gerekebilir (Ayarlar > Uygulamalar > Tasbih Counter > Pil).',
                  'en': 'For notifications to arrive on time, you may need to disable battery optimization for this app (Settings > Apps > Tasbih Counter > Battery).',
                  'ur': 'اطلاعات وقت پر پہنچنے کے لیے ہو سکتا ہے آپ کو اس ایپ کے لیے بیٹری آپٹیمائزیشن بند کرنی پڑے (ترتیبات > ایپس > Tasbih Counter > بیٹری)۔',
                  'ms': 'Untuk memastikan pemberitahuan sampai tepat pada masanya, anda mungkin perlu mematikan pengoptimuman bateri untuk aplikasi ini (Tetapan > Aplikasi > Tasbih Counter > Bateri).',
                }),
                style: GoogleFonts.notoSans(fontSize: 12, color: widget.themeConfig.textColor.withValues(alpha: 0.8)),
              ),
            ),
            const SizedBox(height: 12),
            // Bottom buttons (daha az dikey padding)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      widget.localizations.cancel,
                      () => Navigator.pop(context),
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      widget.localizations.save,
                      () async {
                        await _saveSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: widget.themeConfig.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayIds = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final day = fullDays[index];
        final shortDay = widget.localizations.translate(dayIds[index]);
        final isSelected = _selectedDays.contains(day);
        
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? widget.themeConfig.accentColor : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? widget.themeConfig.accentColor : Colors.white.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                shortDay,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTimeCard(
    String title,
    String subtitle,
    bool isEnabled,
    TimeOfDay time,
    bool isMorning,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    if (isMorning) {
                      _morningNotification = value;
                    } else {
                      _eveningNotification = value;
                    }
                  });
                },
                activeColor: widget.themeConfig.accentColor,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectTime(isMorning: isMorning),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.themeConfig.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: widget.themeConfig.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time.format(context),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: widget.themeConfig.accentColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit,
                      color: widget.themeConfig.accentColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {bool isSecondary = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: isSecondary 
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              )
            : widget.themeConfig.buttonGradient,
        borderRadius: BorderRadius.circular(12),
        border: isSecondary 
            ? Border.all(color: Colors.white.withOpacity(0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
