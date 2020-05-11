import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/authenticate/authenticate.dart';
import 'package:jots_mobile/screens/home/home.dart';
import 'package:jots_mobile/models/user.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return either home or authenticate widget
    if (user == null)
      return Authenticate();
    else
      return Home();
  }
}
