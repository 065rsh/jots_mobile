import 'package:flutter/material.dart';

final drawerBgColor = CompanyColors.veryLightColor;

final darkTextColor = Color(0xFF555555);
final semiDarkTextColor = Color(0xFF777777);
final semiDarkColor = Color(0xFF777777);
final lightDarkColor = Color(0xFF999999);
final darkLightColor = Color(0xFFBBBBBB);
final semiLightColor = Color(0xFFDDDDDD);
final lightColor = Color(0xFFEEEEEE);
final veryLightColor = Color(0xFFF9F9F9);
final orangeGradientStartColor = Color(0xFFFF5137);
final orangeGradientEndColor = Color(0xFFFF7F46);
final darkTransparentColor = Color(0x22000000);
final lightSemiTransparentColor = Color(0x88FFFFFF);
final lightTransparentColor = Color(0xDDFFFFFF);
final redTransparentColor = Color(0x22FF3333);
final themeBlueTransparentColor = Color(0x223E9FFF);
final lightBorderColor = CompanyColors.darkLightColor;
final linkColor = CompanyColors.blue;
final errorColor = CompanyColors.semiRed;
final warningColor = Color(0xFFFF3333);
final themeblue = CompanyColors.themeBlue;
// # Button colors
// Border colors
final disabledButtonColor = CompanyColors.darkLightColor;
// # Due date colors
final nearDueDateColor = CompanyColors.themeBlue;
final pastDueDateColor = CompanyColors.semiRed;
final futureDueDateColor = CompanyColors.semiDarkColor;
// # Priority colors
final priorityColorsArr = [
  lightDarkColor,
  CompanyColors.lightYellowColor,
  CompanyColors.mediumOrangeColor,
  CompanyColors.red,
];

final lowPriorityColor = CompanyColors.lightYellowColor;
final mediumPriorityColor = CompanyColors.mediumOrangeColor;
final highPriorityColor = CompanyColors.red;
// # Tags Color Array
final tagsColorArr = [
  Color(0xFFAAAAAA),
  Color(0xFFFF415A),
  Color(0xFFFF7C50),
  Color(0xFFFFAB27),
  Color(0xFFF9D015),
  Color(0xFFB9E938),
  Color(0xFF4CD65C),
  Color(0xFF32D6B8),
  Color(0xFF23B9FF),
  Color(0xFF4C97F8),
  Color(0xFF7D71FF),
  Color(0xFFAD60EB),
  Color(0xFFE362E3),
  Color(0xFFE94E9D),
  Color(0xFFFC91AD),
  Color(0xFF93B2B7),
];

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class
  static const blue = Color(0xFF2382FF);
  static const veryLightColor = Color(0xFFF5F5F5);
  static const darkLightColor = Color(0xFFCCCCCC);
  static const semiRed = Color(0xFFFF5151);
  static const red = Color(0xFFFF3333);
  static const themeBlue = Color(0xFF3E9FFF);
  static const semiDarkTextColor = Color(0xFF777777);
  static const semiDarkColor = Color(0xFF777777);
  static const lightDarkColor = Color(0xFF999999);
  static const semiLightColor = Color(0xFFDDDDDD);
  static const lightYellowColor = Color(0xFFFFCC00);
  static const mediumOrangeColor = Color(0xFFFF6F00);
}

final darkTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  backgroundColor: Color(0xFF111111),
  dividerColor: Color(0xFF222222),
  hintColor: Color(0xFF555555),
  dialogBackgroundColor: Color(0xFF111111),
  accentColor: Color(0XFF236CFF),
  textTheme: TextTheme(
    headline1: TextStyle(
      color: Color(0xFFDDDDDD),
    ),
    headline2: TextStyle(
      color: Color(0xFFAAAAAA),
    ),
    headline3: TextStyle(
      color: Color(0xFF999999),
    ),
    bodyText1: TextStyle(
      color: Color(0xFFEEEEEE),
    ),
    bodyText2: TextStyle(
      color: Color(0xFFDDDDDD),
    ),
  ),
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  brightness: Brightness.dark,
  backgroundColor: Color(0xFFF5F5F5),
  dividerColor: Color(0xFFEEEEEE),
  hintColor: Color(0xFFBBBBBB),
  dialogBackgroundColor: Colors.white,
  accentColor: themeblue,
  textTheme: TextTheme(
    headline1: TextStyle(
      color: Color(0xFF555555),
    ),
    headline2: TextStyle(
      color: Color(0xFF555555),
    ),
    headline3: TextStyle(
      color: Color(0xFF777777),
    ),
    // task name color
    bodyText1: TextStyle(
      color: Color(0xFF333333),
    ),
    bodyText2: TextStyle(
      color: Color(0xFF777777),
    ),
  ),
);

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}
