import 'package:flutter/material.dart';
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
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
    _checkPendingNotifications();
  }

  Future<void> _loadSavedTime() async {
    final savedTime = await _settingsService.getReminderTime();
    setState(() {
      _selectedTime = TimeOfDay(
        hour: savedTime['hour']!,
        minute: savedTime['minute']!,
      );
    });
  }

  Future<void> _checkPendingNotifications() async {
    final pending = await NotificationService.getPendingNotifications();
    setState(() {
      _statusMessage = pending.isEmpty 
          ? 'No active reminders' 
          : 'Active reminder: ${_selectedTime.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
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
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await NotificationService.showTestNotification();
                    },
                    child: const Text(
                      'Test',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await NotificationService.cancelAll();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      widget.localizations.cancelReminder,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final savedTime = await _settingsService.getReminderTime();
                      if (savedTime['hour'] == _selectedTime.hour && savedTime['minute'] == _selectedTime.minute) {
                        if (context.mounted) Navigator.pop(context);
                        return;
                      }
                      await _settingsService.saveReminderTime(
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      await NotificationService.scheduleReminder(
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      await _checkPendingNotifications();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder set for ${_selectedTime.format(context)}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeConfig.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    child: Text(
                      widget.localizations.ok,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
