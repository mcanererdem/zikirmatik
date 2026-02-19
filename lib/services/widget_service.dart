import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';
import '../utils/localizations.dart';

class WidgetService {
  static const platform = MethodChannel('com.example.zikirmatik/widget');
  
  static Future<void> updateWidget(int _ignoredCounterParam) async {
    final settingsService = SettingsService();
    final today = DateTime.now();

    // Always read the latest values from SettingsService to avoid off-by-one.
    final currentCounter = await settingsService.getCurrentCount();
    final todayCount = await settingsService.getDailyCount(today);
    final totalCount = await settingsService.getTotalCount();
    final streak = await settingsService.getStreak();
    final languageCode = await settingsService.getLanguage();
    final loc = AppLocalizations(languageCode);

    await HomeWidget.saveWidgetData<int>('counter', currentCounter);
    await HomeWidget.saveWidgetData<int>('today_count', todayCount);
    await HomeWidget.saveWidgetData<int>('total_count', totalCount);
    await HomeWidget.saveWidgetData<int>('streak', streak);
    await HomeWidget.saveWidgetData<String>('label_today', loc.today);
    await HomeWidget.saveWidgetData<String>('label_total', loc.total);
    await HomeWidget.saveWidgetData<String>('label_streak', loc.streak);
    await HomeWidget.saveWidgetData<String>('label_title', loc.appName);

    await HomeWidget.updateWidget(
      name: 'ZikrWidgetProvider',
      androidName: 'ZikrWidgetProvider',
    );
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.zikirmatik');
    
    final settingsService = SettingsService();
    final currentCount = await settingsService.getCurrentCount();
    await updateWidget(currentCount);
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
        await updateWidget(widgetCount);
      }
    } catch (_) {}
  }
}
