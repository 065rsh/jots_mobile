import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomNotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initializeHandler() async {
    var initializationSettingsAndroid = AndroidInitializationSettings(
      "app_logo",
    );
    var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print("RAN onDidReceiveLocalNotification for IOS");
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint("Notification payload: $payload");
    }

    debugPrint("OX: DONE WITH PAYLOAD");
  }

  static Future scheduleNotification(
      DateTime selectedDateTime, String taskName, String taskNote) async {

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      0,
      taskName,
      taskNote,
      selectedDateTime,
      platformChannelSpecifics,
    );
  }
}
