import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/home/taskSheet.dart';
// import 'package:jots_mobile/theme.dart';
// import 'package:provider/provider.dart';

class AddTask extends StatefulWidget {
  final pages;
  final pageRef;
  final allTags;
  final double borderRadius;

  AddTask(this.pages, this.pageRef, this.allTags, this.borderRadius);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeX = Theme.of(context);
    // final themeNotifier = Provider.of<ThemeNotifier>(context);
    // bool isDarkThemeEnabled = themeNotifier.getTheme() == darkTheme;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: themeX.accentColor,
//                gradient: LinearGradient(
//                  begin: Alignment.topLeft,
//                  end: Alignment.bottomRight,
//                  colors: [
//                    Color(0xFF3D8BFF),
//                    Color(0xFF5ABDFF),
//                  ],
//                ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(2, 4),
                )
              ],
            ),
            child: FlatButton(
              splashColor: Colors.transparent,
              onPressed: showAddTaskSheet,
              padding: EdgeInsets.all(0),
              child: Text(
                "+",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(50),
      builder: (context) {
        return TaskSheet(widget.pages, widget.pageRef, null, null, null, null,
            widget.allTags);
      },
    );
  }
}
