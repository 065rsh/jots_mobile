import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskSheet.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';

class AddTask extends StatefulWidget {
  final pages;
  final pageRef;

  AddTask(this.pages, this.pageRef);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  List pageNames = [];
  List pagesRefs = [];

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkThemeEnabled = themeNotifier.getTheme() == darkTheme;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 60,
            height: 60,
            margin: EdgeInsets.only(bottom: 60, right: 30),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDarkThemeEnabled ? Color(0xFFDDDDDD) : Color(0xFF3D8BFF),
                    isDarkThemeEnabled ? Color(0xFFDDDDDD) : Color(0xFF5ABDFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  )
                ]),
            child: FlatButton(
              splashColor: Colors.transparent,
              onPressed: showAddTaskSheet,
              child: isDarkThemeEnabled
                  ? SvgPicture.asset(
                      "assets/vectors/GradientAddIcon.svg",
                      width: 20,
                    )
                  : Text(
                      "+",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
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
        return TaskSheet(widget.pages, widget.pageRef, null, null, null);
      },
    );
  }
}
