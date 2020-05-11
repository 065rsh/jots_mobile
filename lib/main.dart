import 'package:flutter/material.dart';
import 'package:jots_mobile/models/user.dart';
import 'package:jots_mobile/screens/wrapper/wrapper.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
