import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class ReminderDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const ReminderDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final SettingsService _settingsService = SettingsService();
  bool _isReminderEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final savedTime = await _settingsService.getReminderTime();
    final enabled = await _settingsService.getReminderEnabled();

    setState(() {
      _isReminderEnabled = enabled;
      _selectedTime = TimeOfDay(
        hour: savedTime['hour'] ?? 9,
        minute: savedTime['minute'] ?? 0,
      );
    });
  }

  Future<void> _toggleReminder(bool isEnabled) async {
    setState(() => _isReminderEnabled = isEnabled);

    if (isEnabled) {
      final hasExact = await NotificationService.hasExactAlarmsPermission();
      if (!hasExact) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.themeConfig.accentColor.withValues(alpha: 0.2),
                      widget.themeConfig.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.themeConfig.textColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.localizations.translate('permissions_required') ?? 'Permissions required',
                      style: TextStyle(color: widget.themeConfig.accentColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.localizations.translate('please_enable_notifications') ?? 'Please enable notifications and exact alarms in system settings.',
                      style: TextStyle(color: widget.themeConfig.textColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: widget.themeConfig.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              widget.localizations.ok,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: widget.themeConfig.textColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      final success = await NotificationService.scheduleReminder(
        _selectedTime.hour,
        _selectedTime.minute,
      );
      if (success) {
        await _settingsService.saveReminderTime(_selectedTime.hour, _selectedTime.minute);
        await _settingsService.saveReminderEnabled(true);
        final now = DateTime.now();
        var scheduled = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
        if (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        final diff = scheduled.difference(now);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final msg = '${widget.localizations.translate('reminder_set_success') ?? 'Reminder set!'}  •  ${hours}h ${minutes}m kaldı';
        _showSnackBar(msg, Colors.green);
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) Navigator.pop(context);
      } else {
        await _settingsService.saveReminderEnabled(false);
        setState(() => _isReminderEnabled = false);
        _showSnackBar(widget.localizations.translate('reminder_set_fail') ?? 'Could not set reminder. Please grant permissions.', Colors.red);
      }
    } else {
      await NotificationService.cancelAll();
      await _settingsService.clearReminder();
      _showSnackBar(widget.localizations.translate('reminder_cancelled') ?? 'Reminder cancelled.', Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = widget.themeConfig.textColor.computeLuminance() < 0.5;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.themeConfig.textColor.withValues(alpha: 0.08),
          image: (() {
            final asset = isLightTheme ? widget.themeConfig.lightBackgroundAsset : widget.themeConfig.darkBackgroundAsset;
            return asset != null
                ? DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  )
                : null;
          })(),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.localizations.setReminder,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.themeConfig.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isReminderEnabled 
                    ? widget.localizations.reminderEnabled
                    : widget.localizations.reminderDisabled,
                  style: TextStyle(color: widget.themeConfig.textColor, fontSize: 16),
                ),
                Switch(
                  value: _isReminderEnabled,
                  onChanged: _toggleReminder,
                  activeColor: widget.themeConfig.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _isReminderEnabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: !_isReminderEnabled ? null : () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() => _selectedTime = time);
                        // If the reminder is already enabled, reschedule with the new time
                        if (_isReminderEnabled) {
                          _toggleReminder(true);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.themeConfig.textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 32,
                          color: _isReminderEnabled ? widget.themeConfig.textColor : widget.themeConfig.textColor.withValues(alpha: 0.54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          NotificationService.showTestNotification();
                          _showSnackBar(widget.localizations.translate('test_notification_sent') ?? 'Test notification sent!', Colors.blue);
                        },
                        child: Text(
                          widget.localizations.translate('test') ?? 'Test',
                          style: TextStyle(color: widget.themeConfig.accentColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          widget.localizations.translate('close') ?? 'Close',
                          style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
