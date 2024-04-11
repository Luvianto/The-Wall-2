import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NotificationService {
  static String serverKey =
      'AAAA75KC-5o:APA91bHNalR-dJkjiQpI_LfVaT-zKuhiqf1tkTMU7rUZcwWtWes5hoQWJH4uHCG1dfQyN9ZAM5oAZ1iT_PuqHGuexQK0iWVR4W2d-60be_8S3YFexxwD9PjFvnFWT10H4ahzsPaigR5J';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeNotification() async {
    AwesomeNotifications().initialize('resource://drawable/res_launcher_icon', [
      NotificationChannel(
        channelKey: 'high_importance_channel',
        channelName: 'Chat notifications',
        importance: NotificationImportance.Max,
        vibrationPattern: highVibrationPattern,
        channelShowBadge: true,
        channelDescription: 'Chat notifications.',
      )
    ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void configurePushNotification(BuildContext context) async {
    initializeNotification();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isIOS) getIOSPermission();

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // print('================');
      // print('========${message.notification!.body}========');
      // print('================');
      if (message.notification != null) {
        createOrderNotification(
            title: message.notification!.title,
            body: message.notification!.body);
      }
    });
  }

  Future<void> createOrderNotification({String? title, String? body}) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 0,
      channelKey: 'high_importance_channel',
      title: title,
      body: body,
    ));
  }

  void eventListenerCallBack(BuildContext context) {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod);
  }

  void getIOSPermission() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
  }

  static Future<void> sendNotification(
      {String? title, String? message, String? token}) async {
    // print('\n');
    // print('token: $token');
    // print('\n');

    final data = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "message": message
    };

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': title,
            },
            'priority': 'high',
            'data': data,
            "to": "$token"
          },
        ),
      );
    } catch (e) {
      // print('Excepton: $e');
    }
  }
}

@pragma("vm:entry-point")
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    // here
  }
}
