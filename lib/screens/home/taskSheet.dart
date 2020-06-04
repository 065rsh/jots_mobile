import 'dart:convert';

import 'package:jots_mobile/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskSheet extends StatefulWidget {
  final pages;
  final pageRef;
  final selectedPage;

  TaskSheet(this.pages, this.pageRef, this.selectedPage);

  @override
  _TaskSheetState createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  String selectedPageIdToAddTask;
  String newAddTaskName;
  FocusNode addNewTaskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    addNewTaskFocusNode.addListener(handleAddNewTaskFocusNode);

    setState(() {
      selectedPageIdToAddTask = widget.selectedPage;
    });
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
      } catch (e) {
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
                    width: double.infinity,
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
              margin: EdgeInsets.only(left: 20, bottom: 40, right: 20, top: 10),
              child: TextFormField(
                autofocus: true,
                focusNode: addNewTaskFocusNode,
                textCapitalization: TextCapitalization.sentences,
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
