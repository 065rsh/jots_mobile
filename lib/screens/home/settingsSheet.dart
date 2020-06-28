import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
            padding: EdgeInsets.only(left: 15, top: 20, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.settings,
                      color: themex.textTheme.headline1.color,
                      size: 22,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        "Settings • ",
                        style: TextStyle(
                          color: themex.textTheme.headline1.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: themeblue.withAlpha(30),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: themeblue),
                      ),
                      child: Text(
                        isDarkThemeEnabled ? "DARK" : "LIGHT",
                        style: TextStyle(
                          color: themeblue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                ButtonTheme(
                  minWidth: 0,
                  padding: EdgeInsets.only(right: 20),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: FlatButton(
                    onPressed: () {
                      onThemeChanged(!isDarkThemeEnable, themeNotifier);
                      setState(() {
                        isDarkThemeEnable = !isDarkThemeEnable;
                      });
                    },
                    child: SvgPicture.asset(
                      "assets/vectors/" +
                          (isDarkThemeEnabled ? "Dark" : "Light") +
                          "ThemeSwitchIcon.svg",
                      width: 70,
                    ),
                  ),
                )
              ],
            ),
          ),
          // # Divider
          Container(
            color: themex.dividerColor,
            height: 1,
          ),
          // # Feedback container
          Container(
            margin: EdgeInsets.only(left: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              color: lightDarkColor.withAlpha(30),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ButtonTheme(
              minWidth: 0,
              height: 0,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  "Give us feedback",
                  style: TextStyle(
                    color: themex.textTheme.bodyText2.color,
                  ),
                ),
              ),
            ),
          ),
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
