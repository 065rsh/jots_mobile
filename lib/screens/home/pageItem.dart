import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskItem.dart';
import 'package:jots_mobile/theme.dart' as Theme;
import 'editPageSheet.dart';

class PageItem extends StatefulWidget {
  final pageId;
  final pageName;
  final bookRef;
  final int filterSelected;
  final dynamic selectedBook;
  final dynamic allTags;
  final int pagesLength;
  final pages;
  final pageRef;

  PageItem(
      this.pageName,
      this.pageId,
      this.bookRef,
      this.filterSelected,
      this.selectedBook,
      this.allTags,
      this.pagesLength,
      this.pages,
      this.pageRef);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem>
    with AutomaticKeepAliveClientMixin<PageItem> {
  List taskValues = [];
  List taskIds = [];
  DocumentReference sectionRef;
  StreamSubscription<DocumentSnapshot> sectionRefSnapshot;
  bool showTasks = false;
  bool showPageHeader = true;

  @override
  bool get wantKeepAlive => true;

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

    if (widget.pagesLength == 2) {
      setState(() {
        showTasks = true;
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
    super.build(context);

    return Container(
      margin: EdgeInsets.only(
        top: showPageHeader ? 15 : 0,
        left: 15,
        right: showPageHeader ? 15 : 5,
        bottom: showPageHeader ? 5 : 5,
      ),
      padding: EdgeInsets.only(
        top: showPageHeader ? 10 : 0,
        bottom: showPageHeader ? (!showTasks ? 10 : 0) : 0,
        left: showPageHeader ? 15 : 0,
        right: showPageHeader ? 15 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(showPageHeader ? 0.15 : 0),
        //     blurRadius: 4,
        //     offset: Offset(0, 2),
        //   ),
        // ],
        border: Border.all(
          width: 0.3,
          color: showPageHeader ? Theme.darkLightColor : Colors.transparent,
        ),
      ),
      child: Column(
        children: <Widget>[
          // # Page header
          showPageHeader
              ? Container(
                  alignment: Alignment.centerLeft,
                  child: FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => setState(() => showTasks = !showTasks),
                    padding: EdgeInsets.all(0),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: showTasks ? 3 : 0, bottom: showTasks ? 10 : 0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: showTasks
                                ? Theme.semiLightColor
                                : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 2, right: 10),
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
                          Container(
                            width: 40,
                            height: 30,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: openEditPageBottomSheet,
                              child: SvgPicture.asset(
                                "assets/vectors/KebabIcon.svg",
                                color: Theme.semiDarkColor,
                                width: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),

          // # Page tasks list
          showTasks
              ? Container(
                  margin: EdgeInsets.only(top: showPageHeader ? 10 : 5),
                  child: filteredTasks(),
                )
              : Container(),
        ],
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
      List fetchedTasks = [];

      doc.data.forEach((k, v) => fetchedTasks.add({k: v}));

      fetchedTasks.sort((a, b) {
        return a[a.keys.first]["creation_date"]
            .compareTo(b[b.keys.first]["creation_date"]);
      });

      fetchedTasks.forEach((task) {
        final taskId = task.keys.first;
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
          widget.allTags,
          showPageHeader,
        );
      },
    );
  }

  openEditPageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(50),
      builder: (context) {
        return EditPageSheet(widget.selectedBook, widget.pageName,
            widget.pageId, widget.pages, widget.pageRef);
      },
    );
  }
}
