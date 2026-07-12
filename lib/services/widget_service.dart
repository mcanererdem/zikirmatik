import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';
import '../utils/localizations.dart';
import 'dart:async';

class WidgetService {
  static const platform = MethodChannel('com.example.zikirmatik/widget');
  static Timer? _debounceTimer;
  
  static Future<void> updateWidget(int ignoredCounterParam) async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await updateWidgetImmediate();
    });
  }

  static Future<void> updateWidgetImmediate() async {
    try {
      final settingsService = SettingsService();
      final today = DateTime.now();

      // Always read the latest values from SettingsService to avoid off-by-one.
      final results = await Future.wait([
        settingsService.getCurrentCount(),
        settingsService.getDailyCount(today),
        settingsService.getTotalCount(),
        settingsService.getStreak(),
        settingsService.getLanguage(),
      ]);
      final currentCounter = results[0] as int;
      final todayCount = results[1] as int;
      final totalCount = results[2] as int;
      final streak = results[3] as int;
      final languageCode = results[4] as String;
      final loc = AppLocalizations(languageCode);

      await Future.wait([
        HomeWidget.saveWidgetData<int>('counter', currentCounter),
        HomeWidget.saveWidgetData<int>('today_count', todayCount),
        HomeWidget.saveWidgetData<int>('total_count', totalCount),
        HomeWidget.saveWidgetData<int>('streak', streak),
        HomeWidget.saveWidgetData<String>('label_today', loc.today),
        HomeWidget.saveWidgetData<String>('label_total', loc.total),
        HomeWidget.saveWidgetData<String>('label_streak', loc.streak),
        HomeWidget.saveWidgetData<String>('label_title', loc.appName),
      ]);

      await HomeWidget.updateWidget(
        name: 'ZikrWidgetProvider',
        androidName: 'ZikrWidgetProvider',
      );
    } catch (_) {}
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.zikirmatik');
    
    final settingsService = SettingsService();
    final currentCount = await settingsService.getCurrentCount();
    await updateWidgetImmediate();
  }

  // Sync app counter with widget counter on app start to reflect widget interactions
  static Future<void> syncWidgetCounter() async {
    try {
      final settingsService = SettingsService();
      final appCount = await settingsService.getCurrentCount();
      final widgetCountRaw = await HomeWidget.getWidgetData<int>('counter', defaultValue: appCount);
      final int widgetCount = widgetCountRaw ?? appCount;
      if (widgetCount != appCount) {
        // If widget increased the counter, adjust daily/total deltas
        if (widgetCount > appCount) {
          final int delta = widgetCount - appCount;
          final now = DateTime.now();
          final currentDaily = await settingsService.getDailyCount(now);
          await settingsService.saveDailyCount(now, currentDaily + delta);
          await settingsService.incrementTotalCount(delta);
        }
        await settingsService.saveCurrentCount(widgetCount);
        await updateWidgetImmediate();
      }
    } catch (_) {}
  }
}
