import 'dart:async';
import 'dart:convert' show json;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

abstract class IFCMNotificationService {
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message");
  }
  Future<void> sendNotificationToUser({
     String fcmToken,
     String title,
     String body,
  });
  Future<void> sendNotificationToGroup({
    String group,
    String title,
    String body,
  });
  Future<void> unsubscribeFromTopic({
    String topic,
  });
  Future<void> subscribeToTopic({
    String topic,
  });
}

class FCMNotificationService extends IFCMNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _endpoint = 'https://fcm.googleapis.com/fcm/send';
  final String _contentType = 'application/json';
  final String _authorization =
      'key=AAAAC3q4vXc:APA91bGXu1sevFn-eWoTHwY0tt56_vZdSCTjjjDjognBa0w7TmLvCfiOu8DzUJcuazwjVbCyQtfba22unPqrtjXef_3rvSbLqo6hcN73Q9-AexjEVtqw41RlNYMFK8hPk5M9IHJ2WYdd';

  Future<http.Response> _sendNotification(
    String to,
    String title,
    String body,
  ) async {
    try {
      final dynamic data = json.encode(
        {
          'to': to,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
          },
          'content_available': true
        },
      );
      http.Response response = await http.post(
        Uri.parse(_endpoint),
        body: data,
        headers: {
          'Content-Type': _contentType,
          'Authorization': _authorization
        },
      );

      return response;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<void> unsubscribeFromTopic({String topic}) {
    return _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<void> subscribeToTopic({String topic}) {
    return _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> sendNotificationToUser({
    String fcmToken,
    String title,
    String body,
  }) {
    return _sendNotification(
      fcmToken,
      title,
      body,
    );
  }

  @override
  Future<void> sendNotificationToGroup(
      {String group, String title, String body}) {
    return _sendNotification('/topics/' + group, title, body);
  }
}
