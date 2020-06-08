import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskItem.dart';
import 'editPageSheet.dart';

class PageItem extends StatefulWidget {
  final int pageIndex;
  final int filterSelected;
  final selectedBook;
  final allTags;
  final pages;
  final pageRef;

  PageItem(
    this.pageIndex,
    this.filterSelected,
    this.selectedBook,
    this.allTags,
    this.pages,
    this.pageRef,
  );

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

    if (widget.pages[widget.pageIndex]["page_name"] == "General") {
      setState(() {
        showTasks = true;
        showPageHeader = false;
      });
    }

    if (widget.pages.length == 2) {
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

    final themex = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(
        top: showPageHeader ? 15 : 10,
        left: 15,
        right: showPageHeader ? 15 : 5,
        bottom: widget.pageIndex == widget.pages.length - 1
            ? 30
            : showPageHeader ? 5 : 0,
      ),
      padding: EdgeInsets.only(
        top: showPageHeader ? 10 : 0,
        bottom: showPageHeader ? (!showTasks ? 10 : 0) : 0,
        left: showPageHeader ? 15 : 0,
        right: showPageHeader ? 10 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 0.3,
          color: showPageHeader ? themex.hintColor : Colors.transparent,
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
                                ? themex.dividerColor
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
                              // # page down arrow
                              Container(
                                margin: EdgeInsets.only(top: 2, right: 10),
                                child: Transform.rotate(
                                  angle: showTasks ? 0 : 0.5,
                                  child: SvgPicture.asset(
                                    "assets/vectors/DownArrowIcon.svg",
                                    color: themex.textTheme.bodyText2.color,
                                  ),
                                ),
                              ),
                              Text(
                                widget.pages[widget.pageIndex]["page_name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themex.textTheme.headline1.color,
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
                                color: themex.textTheme.bodyText2.color,
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
    sectionRef = widget.pageRef
        .document(widget.pages[widget.pageIndex].documentID)
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
          widget.pages,
          widget.pageRef,
          widget.pages[widget.pageIndex].documentID,
          widget.selectedBook,
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
        return EditPageSheet(
          widget.selectedBook,
          widget.pages[widget.pageIndex]["page_name"],
          widget.pages[widget.pageIndex].documentID,
          widget.pages,
          widget.pageRef,
        );
      },
    );
  }
}
