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

    FirebaseUser user = Provider.of<FirebaseUser>(context);

    if (user != null) {
      return Home();
    } else {
      return Authenticate();
    }
  }
}
