import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';

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
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

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

      // Bildirimleri yeniden planla
      if (_isNotificationEnabled) {
        await _scheduleNotifications();
      } else {
        await _cancelAllNotifications();
      }
      
      print('Notification settings saved successfully');
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  Future<void> _scheduleNotifications() async {
    await _cancelAllNotifications();

    if (_selectedDays.isEmpty) {
      print('No days selected, skipping notification scheduling');
      return;
    }

    print('Scheduling notifications for days: $_selectedDays');
    
    for (String day in _selectedDays) {
      final dayIndex = _getDayIndex(day);
      
      // Sabah bildirimi
      if (_morningNotification) {
        final morningDate = _getNextOccurrence(DateTime.now(), dayIndex)
            .copyWith(hour: _morningTime.hour, minute: _morningTime.minute);
        print('Scheduling morning notification for $day at $morningDate');
        await _scheduleNotification(
        id: 1000 + dayIndex,
        title: 'Sabah Zikri',
        body: 'Zikir vakti geldi!',
        scheduledDate: morningDate,
      );
      }
      
      // Akşam bildirimi
      if (_eveningNotification) {
        final eveningDate = _getNextOccurrence(DateTime.now(), dayIndex)
            .copyWith(hour: _eveningTime.hour, minute: _eveningTime.minute);
        print('Scheduling evening notification for $day at $eveningDate');
        await _scheduleNotification(
        id: 2000 + dayIndex,
        title: 'Akşam Zikri',
        body: 'Zikir vakti geldi!',
        scheduledDate: eveningDate,
      );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      print('Scheduling notification: $title at $scheduledDate');
      
      final tz.TZDateTime scheduledDateTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      print('Timezone converted date: $scheduledDateTZ');
      
      await _notificationsPlugin.zonedSchedule(
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

  DateTime _getNextOccurrence(DateTime scheduledDate, int day) {
    final currentDay = scheduledDate.weekday;
    int daysUntilTarget = day - currentDay;
    
    if (daysUntilTarget <= 0) {
      daysUntilTarget += 7;
    }
    
    return scheduledDate.add(Duration(days: daysUntilTarget));
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
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
    final dialogHeight = screenHeight * 0.85;
    
    return Dialog(
      backgroundColor: widget.themeConfig.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
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
                      'Bildirim Ayarları',
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
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
              // Ana bildirim switch
              _buildSwitchTile(
                'Bildirimleri Aç',
                'Zikir hatırlatıcılarını etkinleştir',
                _isNotificationEnabled,
                (value) => setState(() => _isNotificationEnabled = value),
              ),
              
              if (_isNotificationEnabled) ...[
                const SizedBox(height: 20),
                
                // Gün seçimi
                Text(
                  'Hatırlatma Günleri',
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
                  'Sabah Bildirimi',
                  'Sabah zikri hatırlatıcısı',
                  _morningNotification,
                  _morningTime,
                  true,
                ),
                
                const SizedBox(height: 16),
                
                // Akşam bildirimi
                _buildNotificationTimeCard(
                  'Akşam Bildirimi',
                  'Akşam zikri hatırlatıcısı',
                  _eveningNotification,
                  _eveningTime,
                  false,
                ),
              ],
                  ],
                ),
              ),
            ),
            
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      'İptal',
                      () => Navigator.pop(context),
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      'Kaydet',
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
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final day = fullDays[index];
        final shortDay = days[index];
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
