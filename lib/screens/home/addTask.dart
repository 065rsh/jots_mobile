import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/home/taskSheet.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) {
    final themeX = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkThemeEnabled = themeNotifier.getTheme() == darkTheme;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: themeX.dialogBackgroundColor,
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(30),
              //   topRight: Radius.circular(30),
              //   bottomLeft: Radius.circular(widget.borderRadius),
              //   bottomRight: Radius.circular(widget.borderRadius),
              // ),
              border: Border(
                top: BorderSide(
                  color: themeX.dividerColor,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkThemeEnabled ? 40 : 20),
                  blurRadius: 3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            // # Inside add task text form field container
            child: AnimatedPadding(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 45,
                        width: 100,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: lightDarkColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(30),
//                          boxShadow: [
//                            BoxShadow(
//                              color: Colors.black.withOpacity(0.1),
//                              blurRadius: 3,
//                              offset: Offset(0, 2),
//                            ),
//                          ],
//                      border: Border.all(
//                        width: 1,
//                        color: lightDarkColor.withAlpha(50),
//                      ),
                        ),
                        child: TextFormField(
//                controller: _emailTextController,
                          style: TextStyle(
                            color: darkTextColor,
                            decoration: TextDecoration.none,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(11),
                            hintText: "Write new task...",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 10),
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
//                    boxShadow: [
//                      BoxShadow(
//                        color: Colors.black.withOpacity(0.2),
//                        blurRadius: 10,
//                        offset: Offset(2, 4),
//                      )
//                    ],
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
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
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
