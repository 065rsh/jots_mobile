import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/authenticate/authenticate.dart';
import 'package:jots_mobile/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  WrapperState createState() {
    return WrapperState();
  }
}

class WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    // return either home or authenticate widget

    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        Widget widget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          );
        }

        switch (snapshot.hasData) {
          case (true):
            widget = Home();
            break;
          case (false):
            widget = Authenticate();
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: widget,
        );
      },
    );
  }
}
