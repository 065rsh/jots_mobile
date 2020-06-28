import 'package:flutter/material.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSheet extends StatefulWidget {
  final bool isDarkThemeEnable;

  SettingsSheet(this.isDarkThemeEnable);

  @override
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool isDarkThemeEnable;

  @override
  void initState() {
    super.initState();

    setState(() {
      isDarkThemeEnable = widget.isDarkThemeEnable;
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkThemeEnabled = themeNotifier.getTheme() == darkTheme;

    final themex = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themex.dialogBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(2, 4),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: themex.dividerColor.withAlpha(10)),
              ),
            ),
            padding: EdgeInsets.only(left: 15, top: 20, bottom: 15),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.settings,
                  color: themex.textTheme.headline1.color,
                  size: 22,
                ),
                Container(
                  margin: EdgeInsets.only(left: 6),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: themex.textTheme.headline1.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // # Divider
          Container(
            color: themex.dividerColor,
            // width: 350,
            height: 1,
          ),
          // # Change theme button
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 40),
            child: FlatButton(
              onPressed: () {
                onThemeChanged(!isDarkThemeEnable, themeNotifier);
                setState(() {
                  isDarkThemeEnable = !isDarkThemeEnable;
                });
              },
              child: Row(
                children: <Widget>[
                  Text(
                    "App theme  •  ",
                    style: TextStyle(
                      color: themex.textTheme.headline1.color,
                    ),
                  ),
                  Text(
                    isDarkThemeEnabled ? "DARK" : "LIGHT",
                    style: TextStyle(
                      color: themeblue,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);

    var prefs = await SharedPreferences.getInstance();

    prefs.setBool('darkMode', value);
  }
}
