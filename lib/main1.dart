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
import 'package:workmanager/workmanager.dart';

void myBackgroundMessageHandler() {}

void callbackDispatcher() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _demoNotification() async {
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
      "How are you!",
      platformChannelSpecifics,
      payload: "test payload",
    );
  }

  void _showNotification() async {
    await _demoNotification();
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

  Workmanager.executeTask(
    (task, inputData) {
      final FirebaseMessaging _fcm = FirebaseMessaging();
      var initializationSettingsAndroid;
      var initializationSettingsIOS;
      var initializationSettings;

      initializationSettingsAndroid =
          new AndroidInitializationSettings("app_icon");
      initializationSettingsIOS = new IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: $message');

          _showNotification();
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch: $message');

          _showNotification();
        },
        onResume: (Map<String, dynamic> message) async {
          print('onResume: $message');

          _showNotification();
        },
        // onBackgroundMessage: myBackgroundMessageHandler,
      );

      print("Native called background task"); //simpleTask will be emitted here.

      return Future.value(true);
    },
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager.registerOneOffTask("1", "simpleTask");

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

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
  }

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

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Ok"),
            onPressed: () async {
              print("HOLA");
            },
          ),
        ],
      ),
    );
  }
}

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   // if (message.containsKey('data')) {
//   //   // Handle data message
//   //   final dynamic data = message['data'];
//   // }

//   // if (message.containsKey('notification')) {
//   //   // Handle notification message
//   //   final dynamic notification = message['notification'];
//   // }

//   print('onBackgroundMessage: $message');

//   _MyAppState()._showNotification();

//   // Or do other work.
// }
