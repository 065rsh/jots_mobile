import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("onBackgroundMessage: $message");
  // _showBigPictureNotification(message);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // var initializationSettingsAndroid;
  // var initializationSettingsIOS;
  // var initializationSettings;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    "channel_id",
    "channel name",
    "channel description",
    importance: Importance.Max,
    priority: Priority.High,
    ticker: "text ticker",
  );

  var iosChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics,
    iosChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    "HEY!!",
    "Triggered onBackground!",
    platformChannelSpecifics,
    payload: "test payload",
  );

  FirebaseUser user = await FirebaseAuth.instance.currentUser();

  Firestore.instance
      .collection("Users")
      .document(user.uid)
      .setData({"changed": true}, merge: true);

  return Future<void>.value();
}

Future onSelectNotification(String payload) async {
  if (payload != null) {
    debugPrint("The Context is : " + payload.toString());
  }
}

class NotificationHandler {
  FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  static final NotificationHandler _singleton =
      new NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }
  NotificationHandler._internal();

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        // var initializationSettingsAndroid;
        // var initializationSettingsIOS;
        // var initializationSettings;

        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "channel_id",
          "channel name",
          "channel description",
          importance: Importance.Max,
          priority: Priority.High,
          ticker: "text ticker",
        );

        var iosChannelSpecifics = IOSNotificationDetails();

        var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics,
          iosChannelSpecifics,
        );

        await flutterLocalNotificationsPlugin.show(
          0,
          "HEY!!",
          "Triggered onMessage!",
          platformChannelSpecifics,
          payload: "test payload",
        );
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  /// Get the token, save it to the database for current user

  _saveDeviceToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    // get the token for this device
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = Firestore.instance
          .collection("Users")
          .document(user.uid)
          .collection("Tokens")
          .document(fcmToken);

      await tokenRef.setData({
        "token": fcmToken,
        "created_time": FieldValue.serverTimestamp(),
        "platform": Platform.operatingSystem,
      });
    }
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }
}
