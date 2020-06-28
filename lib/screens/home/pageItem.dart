import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskItem.dart';
import 'package:jots_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editPageSheet.dart';

class PageItem extends StatefulWidget {
  final int pageIndex;
  final int filterSelected;
  final int sortBySelected;
  final selectedBook;
  final allTags;
  final pages;
  final pageRef;

  PageItem(
    this.pageIndex,
    this.filterSelected,
    this.sortBySelected,
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

    if (widget.pages.length == 2) {
      setState(() {
        showTasks = true;
      });
    }

    _setPageCollapseValue();
  }

  _setPageCollapseValue() async {
    try {
      SharedPreferences tempPref = await SharedPreferences.getInstance();

      setState(() {
        showTasks = !(tempPref.getBool(
                widget.pages[widget.pageIndex].documentID + "_is_collapsed") ??
            true);
      });

      if (widget.pages[widget.pageIndex]["page_name"] == "General") {
        setState(() {
          showTasks = true;
          showPageHeader = false;
        });
      }
    } catch (e) {
      print(e);
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
        right: 15,
        bottom: widget.pageIndex == widget.pages.length - 1
            ? 140
            : showPageHeader ? 5 : 0,
      ),
      padding: EdgeInsets.only(
        top: showPageHeader ? 10 : 0,
        bottom: showPageHeader ? (!showTasks ? 10 : 0) : 0,
        left: showPageHeader ? 15 : 0,
        right: showPageHeader ? 15 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: showPageHeader ? themex.dividerColor : Colors.transparent,
        ),
      ),
      child: Column(
        children: <Widget>[
          // # Page header
          showPageHeader
              ? Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(bottom: showTasks ? 15 : 0),
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
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                widget.pages[widget.pageIndex]["page_name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themex.textTheme.headline1.color,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // # page down arrow
                              showTasks
                                  ? Container(
                                      margin: EdgeInsets.only(top: 2, left: 10),
                                      child: Transform.rotate(
                                        angle: showTasks ? 0 : 0.5,
                                        child: SvgPicture.asset(
                                          "assets/vectors/DownArrowIcon.svg",
                                          color:
                                              themex.textTheme.bodyText2.color,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                          Container(
                            width: 30,
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
              : Container(
                  height: 5,
                ),

          // # Page tasks list
          showTasks
              ? Container(
                  margin: EdgeInsets.only(top: 5),
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

      try {
        doc.data.forEach((k, v) => fetchedTasks.add({k: v}));

        fetchedTasks.sort((a, b) {
          return a[a.keys.first]["creation_date"]
              .compareTo(b[b.keys.first]["creation_date"]);
        });

        if (widget.sortBySelected == 1) {
          fetchedTasks.sort((a, b) {
            final taskDate1 = a[a.keys.first]["due_date"];
            final taskDate2 = b[b.keys.first]["due_date"];

            final taskDate11 =
                taskDate1 == "" ? DateTime(2099) : taskDate1.toDate();
            final taskDate22 =
                taskDate2 == "" ? DateTime(2099) : taskDate2.toDate();

            return (taskDate11).compareTo(taskDate22);
          });
        } else if (widget.sortBySelected == 2) {
          fetchedTasks.sort((a, b) {
            final taskDate2 = a[a.keys.first]["priority"];
            final taskDate1 = b[b.keys.first]["priority"];

            return (taskDate1).compareTo(taskDate2);
          });
        } else if (widget.sortBySelected == 3) {
          fetchedTasks.sort((a, b) {
            final taskDate1 = a[a.keys.first]["task_name"];
            final taskDate2 = b[b.keys.first]["task_name"];

            return (taskDate1).compareTo(taskDate2);
          });
        }
      } catch (e) {
        print(e);
      }

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
          widget.allTags,
        );
      },
    );
  }
}
