import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/home/taskItem.dart';
import 'package:jots_mobile/theme.dart' as Theme;

class PageItem extends StatefulWidget {
  final pageId;
  final bookRef;

  PageItem(this.pageId, this.bookRef);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  List taskValues = [];
  List taskIds = [];
  DocumentReference sectionRef;
  StreamSubscription<DocumentSnapshot> sectionRefSnapshot;

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
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: taskValues.length,
        itemBuilder: (BuildContext context, int index) {
          return TaskItem(taskIds[index], taskValues[index], sectionRef);
        },
      ),
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
