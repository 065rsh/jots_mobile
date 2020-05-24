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

  PageItem(this.pageName, this.pageId, this.bookRef);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  List taskValues = [];
  List taskIds = [];
  DocumentReference sectionRef;
  StreamSubscription<DocumentSnapshot> sectionRefSnapshot;
  bool showTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
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
        Container(
          margin: EdgeInsets.only(top: 5),
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
        ),
        showTasks
            ? Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: taskValues.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TaskItem(
                        taskIds[index], taskValues[index], sectionRef);
                  },
                ),
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
        // if (!doc.data[taskId]["is_checked"])
        fetchedTaskValues.add(doc.data[taskId]);
        fetchedTaskIds.add(taskId);
      });

      setState(() {
        taskValues = fetchedTaskValues;
        taskIds = fetchedTaskIds;
      });
    });
  }
}
