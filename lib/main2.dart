import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/wrapper/wrapper.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jots_mobile/services/notificationHandler.dart';
// import 'package:workmanager/workmanager.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // if (message.containsKey('data')) {
  //   // Handle data message
  //   final dynamic data = message['data'];
  // }

  // if (message.containsKey('notification')) {
  //   // Handle notification message
  //   final dynamic notification = message['notification'];
  // }

  // final FirebaseMessaging _fcm = FirebaseMessaging();
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

  FirebaseUser user = await FirebaseAuth.instance.currentUser();

  Firestore.instance
      .collection("Users")
      .document(user.uid)
      .setData({"changed": true}, merge: true);

  await flutterLocalNotificationsPlugin.show(
    0,
    "HEY!!",
    "How are you!",
    platformChannelSpecifics,
    payload: "test payload",
  );

  // void _showNotification() async {
  //   await _demoNotification();
  // }

  // Future onDidReceiveLocalNotification(
  //     int id, String title, String body, String payload) async {
  //   print("RAN onDidReceiveLocalNotification for IOS");
  // }

  // Future onSelectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint("Notification payload: $payload");
  //   }

  //   debugPrint("OX: DONE WITH PAYLOAD");
  // }

  print('onBackgroundMessage: $message');

  return Future<void>.value();
  // Or do other work.
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  @override
  void initState() {
    super.initState();

    new NotificationHandler().initializeFcmNotification();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: Wrapper(),
      ),
    );
  }
}
