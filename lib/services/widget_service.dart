import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';

class WidgetService {
  static const platform = MethodChannel('com.example.zikirmatik/widget');
  
  static Future<void> updateWidget(int counter) async {
    await HomeWidget.saveWidgetData<int>('counter', counter);
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
    
    // Widget'tan gelen değişiklikleri dinle
    HomeWidget.widgetClicked.listen((uri) async {
      await _syncFromWidget();
    });
  }
  
  static Future<void> _syncFromWidget() async {
    final widgetCounter = await getWidgetCounter();
    final settingsService = SettingsService();
    final appCounter = await settingsService.getCurrentCount();
    
    if (widgetCounter != appCounter) {
      await settingsService.saveCurrentCount(widgetCounter);
    }
  }
  
  static Future<int> getWidgetCounter() async {
    return await HomeWidget.getWidgetData<int>('counter', defaultValue: 0) ?? 0;
  }
}
