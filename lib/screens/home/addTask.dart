import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/theme.dart';

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
                    Color(0xFF3D8BFF),
                    Color(0xFF5ABDFF),
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
              child: Text(
                "+",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
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
        return TaskAddBottomSheet(widget.pages, widget.pageRef);
      },
    );
  }
}

class TaskAddBottomSheet extends StatefulWidget {
  final pages;
  final pageRef;

  TaskAddBottomSheet(this.pages, this.pageRef);

  @override
  _TaskAddBottomSheetState createState() => _TaskAddBottomSheetState();
}

class _TaskAddBottomSheetState extends State<TaskAddBottomSheet> {
  String selectedPageIdToAddTask;
  String newAddTaskName;
  FocusNode addNewTaskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    addNewTaskFocusNode.addListener(handleAddNewTaskFocusNode);
  }

  handleAddNewTaskFocusNode() async {
    if (widget.pages.length == 1) {
      setState(() => selectedPageIdToAddTask = widget.pages[0].documentID);
    }

    if (!addNewTaskFocusNode.hasFocus &&
        newAddTaskName != null &&
        newAddTaskName != "") {
      var bytes = utf8.encode(hashCode.toString());
      var randomTaskId = base64.encode(bytes);

      DocumentReference sectionRef = widget.pageRef
          .document(selectedPageIdToAddTask)
          .collection("Sections")
          .document("not_sectioned");

      await sectionRef.setData({
        randomTaskId: {
          "completion_date": "",
          "creation_date": new DateTime.now(),
          "due_date": "",
          "is_checked": false,
          "note": "",
          "priority": 0,
          "tag_ids": [],
          "task_name": newAddTaskName,
        }
      }, merge: true);

      try {
        Navigator.pop(context);
      } catch (w) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(2, 4),
            )
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // # Drag logo
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: semiLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // # Add to page row
            widget.pages.length == 1
                ? Container()
                : Container(
                    margin: EdgeInsets.only(left: 20, top: 15, right: 20),
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Color(0xFFdddddd),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Text(
                            "ADD TO PAGE",
                            style: TextStyle(
                              color: lightDarkColor,
                              fontSize: 10,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: parsePageButtons(),
                          ),
                        ),
                      ],
                    ),
                  ),
            // # Text form field
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 10, right: 20, top: 10),
              child: TextFormField(
                autofocus: true,
                focusNode: addNewTaskFocusNode,
                onChanged: (text) {
                  setState(() {
                    newAddTaskName = text;
                  });
                },
                style: TextStyle(
                  color: darkTextColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Task name...",
                  hintStyle: TextStyle(
                    color: lightDarkColor,
                  ),
                  isDense: true,
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  parsePageButtons() {
    List<Widget> pageButtonWidgets = [];

    if (selectedPageIdToAddTask == null) {
      setState(() => selectedPageIdToAddTask = widget.pages[0].documentID);
    }

    for (int i = 0; i < widget.pages.length; i++) {
      bool isSelectedPage = false;
      if (widget.pages[i].documentID == selectedPageIdToAddTask) {
        isSelectedPage = true;
      }
      pageButtonWidgets.add(
        Container(
          child: ButtonTheme(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: 10,
            height: 10,
            child: FlatButton(
              onPressed: () {
                setState(
                    () => selectedPageIdToAddTask = widget.pages[i].documentID);
              },
              splashColor: Colors.transparent,
              padding: EdgeInsets.only(right: 15, top: 3, bottom: 5),
              child: Text(
                i == 0 ? "None" : widget.pages[i].data["page_name"],
                style: TextStyle(
                  color: isSelectedPage ? darkTextColor : darkLightColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtonWidgets;
  }
}
