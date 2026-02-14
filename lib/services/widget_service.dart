import 'package:home_widget/home_widget.dart';

class WidgetService {
  static Future<void> updateWidget(int counter) async {
    await HomeWidget.saveWidgetData<int>('counter', counter);
    await HomeWidget.updateWidget(
      name: 'ZikrWidgetProvider',
      androidName: 'ZikrWidgetProvider',
    );
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.zikirmatik');
  }
}
