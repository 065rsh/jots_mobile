import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskItem.dart';
import 'package:jots_mobile/theme.dart' as Theme;

class PageItem extends StatefulWidget {
  final pageId;
  final pageName;
  final bookRef;
  final int filterSelected;

  PageItem(this.pageName, this.pageId, this.bookRef, this.filterSelected);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  List taskValues = [];
  List taskIds = [];
  DocumentReference sectionRef;
  StreamSubscription<DocumentSnapshot> sectionRefSnapshot;
  bool showTasks = false;
  bool showPageHeader = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();

    if (widget.pageName == "General") {
      setState(() {
        showTasks = true;
        showPageHeader = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    sectionRefSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Page header
        showPageHeader
            ? Container(
                margin: EdgeInsets.only(bottom: 5),
                alignment: Alignment.centerLeft,
                child: FlatButton(
                  onPressed: () => setState(() => showTasks = !showTasks),
                  padding: EdgeInsets.only(left: 0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Transform.rotate(
                          angle: showTasks ? 0 : 0.5,
                          child: SvgPicture.asset(
                            "assets/vectors/DownArrowIcon.svg",
                            color: Theme.semiDarkColor,
                          ),
                        ),
                      ),
                      Text(
                        widget.pageName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.darkTextColor,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),

        showTasks
            ? Container(
                child: filteredTasks(),
              )
            : Container(),
      ],
    );
  }

  _fetchTasks() async {
    sectionRef = widget.bookRef
        .document(widget.pageId)
        .collection("Sections")
        .document("not_sectioned");

    sectionRefSnapshot = sectionRef.snapshots().listen((doc) {
      List fetchedTaskValues = [];
      List fetchedTaskIds = [];

      doc.data.keys.forEach((taskId) {
        if (taskId != "newly_created") {
          fetchedTaskValues.add(doc.data[taskId]);
          fetchedTaskIds.add(taskId);
        }
      });

      setState(() {
        taskValues = fetchedTaskValues;
        taskIds = fetchedTaskIds;
      });
    });
  }

  filteredTasks() {
    List filteredTaskValues = [];
    List filteredTaskIds = [];

    for (int i = 0; i < taskValues.length; i++) {
      if (widget.filterSelected == 0 && !taskValues[i]["is_checked"]) {
        filteredTaskValues.add(taskValues[i]);
        filteredTaskIds.add(taskIds[i]);
      } else if (widget.filterSelected == 1 && taskValues[i]["is_checked"]) {
        filteredTaskValues.add(taskValues[i]);
        filteredTaskIds.add(taskIds[i]);
      } else if (widget.filterSelected == 2) {
        filteredTaskValues.add(taskValues[i]);
        filteredTaskIds.add(taskIds[i]);
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTaskValues.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskItem(
          filteredTaskIds[index],
          filteredTaskValues[index],
          sectionRef,
        );
      },
    );
  }
}
