/*
 * Creating custom color palettes is part of creating a custom app. The idea is to create
 * your class of custom colors, in this case `CompanyColors` and then create a `ThemeData`
 * object with those colors you just defined.
 *
 * Resource:
 * A good resource would be this website: http://mcg.mbitson.com/
 * You simply need to put in the colour you wish to use, and it will generate all shades
 * for you. Your primary colour will be the `500` value.
 *
 * Colour Creation:
 * In order to create the custom colours you need to create a `Map<int, Color>` object
 * which will have all the shade values. `const Color(0xFF...)` will be how you create
 * the colours. The six character hex code is what follows. If you wanted the colour
 * #114488 or #D39090 as primary colours in your theme, then you would have
 * `const Color(0x114488)` and `const Color(0xD39090)`, respectively.
 *
 * Usage:
 * In order to use this newly created theme or even the colours in it, you would just
 * `import` this file in your project, anywhere you needed it.
 * `import 'path/to/theme.dart';`
 */

import 'package:flutter/material.dart';

final drawerBgColor = CompanyColors.veryLightColor;

final darkTextColor = Color(0xFF555555);
final semiDarkTextColor = Color(0xFF777777);
final semiDarkColor = Color(0xFF777777);
final lightDarkColor = Color(0xFF999999);
final darkLightColor = Color(0xFFBBBBBB);
final semiLightColor = Color(0xFFDDDDDD);
final lightColor = Color(0xFFEEEEEE);
final orangeGradientStartColor = Color(0xFFFF5137);
final orangeGradientEndColor = Color(0xFFFF7F46);
final darkTransparentColor = Color(0x22000000);
final lightSemiTransparentColor = Color(0x88FFFFFF);
final lightTransparentColor = Color(0xDDFFFFFF);
final lightBorderColor = CompanyColors.darkLightColor;
final linkColor = CompanyColors.blue;
final errorColor = CompanyColors.red;
final warningColor = Color(0xFFFF3333);
final themeblue = CompanyColors.themeBlue;

// final ThemeData CompanyThemeData = new ThemeData(
//   brightness: Brightness.light,
//   primarySwatch: CompanyColors.blue,
// );

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class
  static const blue = Color(0xFF2382FF);
  static const veryLightColor = Color(0xFFF5F5F5);
  static const darkLightColor = Color(0xFFCCCCCC);
  static const red = Color(0xFFFF5151);
  static const themeBlue = Color(0xFF3E9FFF);

  // static const Map<int, Color> blue = const <int, Color>{
  //   50: const Color(/* some hex code */),
  // };

}
