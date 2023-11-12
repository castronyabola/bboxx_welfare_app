import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class Notifications {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String>();

  static Future notificationDetails() async {
    return NotificationDetails(
    android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      //'channel description',
      importance: Importance.max,
    ),
    iOS: IOSNotificationDetails(),
    );
  }

  static Future init ({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android:android,iOS:iOS);
    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
 }
  static Future showNotification ({
    int id,
    String title ,
    String body ,
    String payload ,
}) async =>
      _notifications.show(
        id == null? 0:id,
        title,
        body,
        await notificationDetails(),
        payload:payload,
      );
}