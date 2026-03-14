import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String androidWidgetName = 'LifeOSWidgetProvider';
  
  static Future<void> updateWidget({
    required String title,
    required String message,
  }) async {
    await HomeWidget.saveWidgetData<String>('title', title);
    await HomeWidget.saveWidgetData<String>('message', message);
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
    );
  }
}
