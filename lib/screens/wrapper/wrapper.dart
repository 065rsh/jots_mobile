import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/authenticate/authenticate.dart';
import 'package:jots_mobile/screens/home/home.dart';
import 'package:provider/provider.dart';

bool sentVerificationEmail = false;

class Wrapper extends StatefulWidget {
  WrapperState createState() {
    return WrapperState();
  }
}

class WrapperState extends State<Wrapper> {
  bool isEmailVerified = false;

  sendVerification(user) async {
    if (user != null && !user.isEmailVerified && !sentVerificationEmail) {
      print("Sending verification email...");
      await user.sendEmailVerification();
      sentVerificationEmail = true;
    }
  }

  void checkEmailVerification() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser != null) {
      currentUser.reload();
      if (currentUser.isEmailVerified)
        setState(() {
          isEmailVerified = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);

    sendVerification(user);

    // return either home or authenticate widget
    if (user != null && isEmailVerified)
      return Home();
    else {
      checkEmailVerification();
      return Authenticate();
    }
  }
}
