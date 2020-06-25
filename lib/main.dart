import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jots_mobile/screens/wrapper/wrapper.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jots_mobile/services/customNotificationHandler.dart';

_showFlutterLocalNotification(String title, String message) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    "DUE_DATE_REMINDER",
    "Due date reminder notification",
    "Notification channel for task due date reminder.",
  );

  var iosChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics,
    iosChannelSpecifics,
  );

  await CustomNotificationHandler.flutterLocalNotificationsPlugin.schedule(
    0,
    title,
    message,
    DateTime.now(),
    platformChannelSpecifics,
  );
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  await _showFlutterLocalNotification(
    "HEY!!",
    "onBackgroundMessage ran myBackgroundMessageHandler()",
  );

  return Future<void>.value();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    SharedPreferences.getInstance().then((prefs) {
      var darkModeOn = prefs.getBool('darkMode') ?? false;

      runApp(
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
          child: MyApp(),
        ),
      );
    });
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final CustomNotificationHandler customNotificationHandler =
      CustomNotificationHandler();

  @override
  void initState() {
    super.initState();

    customNotificationHandler.initializeHandler();

    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
  }

  _saveDeviceToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String fcmToken = await _fcm.getToken(); // gets the token for this device

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

  // Future<void> _demoNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     "channel_id",
  //     "channel name",
  //     "channel description",
  //     importance: Importance.Max,
  //     priority: Priority.High,
  //     ticker: "text ticker",
  //   );

  //   var iosChannelSpecifics = IOSNotificationDetails();

  //   var platformChannelSpecifics = NotificationDetails(
  //     androidPlatformChannelSpecifics,
  //     iosChannelSpecifics,
  //   );

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     "HEY!!",
  //     "onMessage ran _demoNotifications()",
  //     platformChannelSpecifics,
  //     payload: "test payload",
  //   );
  // }
}
