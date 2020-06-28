import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/addTagsSheet.dart';
import 'package:jots_mobile/services/customNotificationHandler.dart';
import 'package:jots_mobile/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jots_mobile/handyArr.dart';
import 'changeBookSheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

final double taskSheetIconRightMargin = 20;
final double taskSheetItemTopMargin = 30;
final double taskSheetButtonHeight = 35;

class TaskSheet extends StatefulWidget {
  final pages;
  final pageRef;
  final selectedPage;
  final taskId;
  final task;
  final selectedBook;
  final allTags;

  TaskSheet(
    this.pages,
    this.pageRef,
    this.selectedPage,
    this.taskId,
    this.task,
    this.selectedBook,
    this.allTags,
  );

  @override
  _TaskSheetState createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> with TickerProviderStateMixin {
  AnimationController _taskAboutAC;
  TextEditingController taskNameController, taskNoteController;
  StreamSubscription<QuerySnapshot> booksSnapshot;
  AutoScrollController addToPageScrollController = AutoScrollController();

  int taskPriority = 0;
  bool isTaskValid = false;
  bool closeSheetAfterCreatingTask = true;
  bool showAddNotes = false;
  bool showSelectDate = false;
  String selectedPageIdToAddTask;
  String taskName;
  String taskNote;
  DateTime dueDate;
  DateTime selectedDate;
  List taskTagChips;
  List books = [];

  @override
  void initState() {
    super.initState();

    fetchBooks();

    _taskAboutAC = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.0,
    );

    List tempArr = [];

    if (widget.taskId != null)
      widget.task["tag_ids"].forEach((selectedTag) {
        tempArr.add(selectedTag);
      });

    setState(() {
      selectedPageIdToAddTask =
          widget.selectedPage ?? widget.pages[0].documentID;
      selectedDate = widget.taskId != null
          ? widget.task["due_date"] == ""
              ? null
              : widget.task["due_date"].toDate()
          : null;
      taskName = widget.taskId != null ? widget.task["task_name"] : null;
      isTaskValid = widget.taskId != null;
      taskPriority = widget.taskId != null ? widget.task["priority"] : 0;
      taskNote = widget.taskId != null ? widget.task["note"] : "";
      taskTagChips = tempArr;
    });

    taskNameController = TextEditingController(
      text: widget.taskId != null ? widget.task["task_name"] : "",
    );
    taskNoteController = TextEditingController(text: taskNote);
  }

  @override
  void dispose() {
    super.dispose();

    taskNameController.dispose();
    taskNoteController.dispose();
    booksSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool isNewTask = widget.taskId == null;
    bool isTaskChangedAndIsValid = _checkTaskChange() && isTaskValid;
    final formattedDueDate = selectedDate != null
        ? _formatDueDate(selectedDate)
        : {"date_time": null, "date": null, "time": null, "color": null};
    bool isTimeNotAval = formattedDueDate["time"] == "" ||
        formattedDueDate["time"] == ", " ||
        formattedDueDate["time"] == null;
    final themeX = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeX.dialogBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(2, 4),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: AnimatedPadding(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GestureDetector(
          onHorizontalDragEnd: (details) => _onSheetDragEnd(details),
          onTap: () {
            _taskAboutAC.reverse();
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // # Add to page row
                    widget.pages.length == 1
                        ? Container()
                        : Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: themeX.dividerColor,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "ADD TO PAGE",
                                  style: TextStyle(
                                    color: lightDarkColor,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: addToPageScrollController,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: parsePageButtons(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    // # Task Name
                    Container(
                      margin: EdgeInsets.only(
                          top: widget.pages.length == 1 ? 10 : 5,
                          right: 20,
                          left: 20),
                      child: TextField(
                        autofocus: isNewTask,
                        controller: taskNameController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (text) {
                          setState(() {
                            taskName = text;
                            isTaskValid = text.length > 0;
                          });
                        },
                        maxLength: 100,
                        style: TextStyle(
                          color: themeX.textTheme.headline2.color,
                          fontSize: 22,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
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
                    // # Task Note
                    isNewTask && !showAddNotes
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              top: 5,
                              right: 20,
                              bottom: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      right: taskSheetIconRightMargin, top: 2),
                                  child: SvgPicture.asset(
                                    "assets/vectors/NoteIcon.svg",
                                    width: 20,
                                    color: lightDarkColor,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    autofocus: isNewTask && !showAddNotes,
                                    controller: taskNoteController,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: null,
                                    onChanged: (text) {
                                      setState(() => taskNote = text);
                                    },
                                    style: TextStyle(
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                      color: themeX.textTheme.headline3.color,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Add notes...",
                                      hintStyle:
                                          TextStyle(color: lightDarkColor),
                                      isDense: true,
                                      counterText: '',
                                      contentPadding: EdgeInsets.only(top: 0),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    // # Tags Container
                    isNewTask
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: taskSheetItemTopMargin,
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      right: taskSheetIconRightMargin),
                                  child: SvgPicture.asset(
                                    "assets/vectors/TagIcon.svg",
                                    color: lightDarkColor,
                                    width: 20,
                                  ),
                                ),
                                Wrap(
                                  runSpacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: _addTagsList(),
                                ),
                              ],
                            ),
                          ),
                    // # Due Date Container
                    isNewTask && !showSelectDate
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(
                                top: isNewTask ? 20 : taskSheetItemTopMargin,
                                left: 20),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      right: taskSheetIconRightMargin),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: lightDarkColor,
                                    size: 20,
                                  ),
                                ),
                                Container(
                                  height: taskSheetButtonHeight,
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: formattedDueDate["date"] == null
                                        ? Colors.transparent
                                        : formattedDueDate["color"]
                                            .withAlpha(20),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: ButtonTheme(
                                    minWidth: 0,
                                    child: FlatButton(
                                      onPressed: _selectDate,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              formattedDueDate["date"] == null
                                                  ? 0
                                                  : 15),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      child: Text(
                                        formattedDueDate["date"] ??
                                            "Select date",
                                        style: TextStyle(
                                          color:
                                              formattedDueDate["date"] == null
                                                  ? lightDarkColor
                                                  : formattedDueDate["color"],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                formattedDueDate["date"] != null
                                    ? Container(
                                        height: taskSheetButtonHeight,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.transparent),
                                          color: isTimeNotAval
                                              ? Colors.transparent
                                              : formattedDueDate["color"]
                                                  .withAlpha(20),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          strokeWidth: 0.5,
                                          dashPattern: [3, 2],
                                          color: isTimeNotAval
                                              ? lightDarkColor
                                              : Colors.transparent,
                                          radius: Radius.circular(7),
                                          child: FlatButton(
                                            onPressed: _selectTime,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                              isTimeNotAval
                                                  ? "Select time"
                                                  : formattedDueDate["time"]
                                                      .substring(2),
                                              style: TextStyle(
                                                color: isTimeNotAval
                                                    ? lightDarkColor
                                                    : formattedDueDate["color"],
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                // # clear due date button
                                formattedDueDate["date"] != null
                                    ? Container(
                                        width: 25,
                                        height: 25,
                                        margin: EdgeInsets.only(left: 15),
                                        decoration: BoxDecoration(
                                          color: themeX.dialogBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: FlatButton(
                                          onPressed: _removeDueDate,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.all(0),
                                          child: Icon(
                                            Icons.clear,
                                            color: lightDarkColor,
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                    // # Priority Container
                    isNewTask
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(
                                left: 20, top: taskSheetItemTopMargin),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: lightDarkColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  margin: EdgeInsets.only(
                                      right: taskSheetIconRightMargin),
                                  child: Text(
                                    "!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: lightDarkColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: taskSheetButtonHeight,
                                  decoration: BoxDecoration(
                                    color: taskPriority == 0
                                        ? Colors.transparent
                                        : priorityColorsArr[taskPriority]
                                            .withAlpha(20),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: ButtonTheme(
                                    minWidth: 0,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: taskPriority == 0 ? 0 : 20),
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          taskPriority = taskPriority ==
                                                  priorityArr.length - 1
                                              ? 0
                                              : taskPriority + 1;
                                        });
                                      },
                                      child: Text(
                                        taskPriority == 0
                                            ? priorityArr[taskPriority]
                                            : priorityArr[taskPriority]
                                                .toUpperCase(),
                                        style: TextStyle(
                                          color:
                                              priorityColorsArr[taskPriority],
                                          letterSpacing:
                                              taskPriority == 0 ? 0 : 1,
                                          fontWeight: taskPriority == 0
                                              ? FontWeight.w400
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    // # Action buttons
                    isNewTask
                        ? Container(
                            margin: EdgeInsets.only(
                                top: taskSheetItemTopMargin - 5, bottom: 15),
                            padding:
                                EdgeInsets.only(top: 5, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      ButtonTheme(
                                        minWidth: 0,
                                        padding: EdgeInsets.all(0),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        child: FlatButton(
                                          onPressed: () {
                                            setState(() {
                                              showAddNotes = true;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            "assets/vectors/NoteIcon.svg",
                                            color: showAddNotes
                                                ? lightDarkColor.withAlpha(90)
                                                : lightDarkColor,
                                            width: 20,
                                          ),
                                        ),
                                      ),
                                      ButtonTheme(
                                        minWidth: 0,
                                        padding: EdgeInsets.all(0),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        child: FlatButton(
                                          onPressed: () {
                                            _selectDate();
                                            setState(() {
                                              showSelectDate = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: showSelectDate
                                                ? lightDarkColor.withAlpha(90)
                                                : lightDarkColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    ButtonTheme(
                                      minWidth: 0,
                                      padding: EdgeInsets.all(0),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      child: FlatButton(
                                        onPressed: () {
                                          if (isTaskValid) {
                                            _createNewTask();
                                          }
                                        },
                                        child: Text(
                                          "CREATE",
                                          style: TextStyle(
                                            color: isTaskValid
                                                ? themeblue
                                                : lightDarkColor.withAlpha(80),
                                            letterSpacing: 1,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "   &   ",
                                      style: TextStyle(
                                        color: lightDarkColor.withAlpha(950),
                                      ),
                                    ),
                                    FlatButton(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        setState(() {
                                          closeSheetAfterCreatingTask =
                                              !closeSheetAfterCreatingTask;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: lightDarkColor.withAlpha(30),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                "CLOSE  ",
                                                style: TextStyle(
                                                  color:
                                                      closeSheetAfterCreatingTask
                                                          ? lightDarkColor
                                                          : lightDarkColor
                                                              .withAlpha(90),
                                                  letterSpacing: 1,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              closeSheetAfterCreatingTask
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: closeSheetAfterCreatingTask
                                                  ? lightDarkColor
                                                  : lightDarkColor
                                                      .withAlpha(90),
                                              size: 17,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(
                                top: taskSheetItemTopMargin + 5,
                                left: 20,
                                bottom: 20,
                                right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    // # save changes button
                                    Opacity(
                                      opacity:
                                          isTaskChangedAndIsValid ? 1 : 0.5,
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isTaskChangedAndIsValid
                                                ? themeblue
                                                : lightDarkColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: ButtonTheme(
                                          minWidth: 0,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: FlatButton(
                                            onPressed: () {
                                              if (isTaskChangedAndIsValid) {
                                                isTaskChangedAndIsValid = false;
                                                _makeChangesInOldTask();
                                              }
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(right: 7),
                                                  child: Icon(
                                                    Icons.arrow_upward,
                                                    color:
                                                        isTaskChangedAndIsValid
                                                            ? themeblue
                                                            : lightDarkColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(
                                                  "Save",
                                                  style: TextStyle(
                                                    color:
                                                        isTaskChangedAndIsValid
                                                            ? themeblue
                                                            : lightDarkColor,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    books.length > 1
                                        ? Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: themeX
                                                    .textTheme.headline3.color,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: FlatButton(
                                              onPressed: _openChangeBookSheet,
                                              child: Text(
                                                "Change book",
                                                style: TextStyle(
                                                  color: themeX.textTheme
                                                      .headline3.color,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 35,
                                      height: 35,
                                      child: ButtonTheme(
                                        minWidth: 0,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.all(0),
                                        child: FlatButton(
                                          onPressed: _deleteTask,
                                          child: SvgPicture.asset(
                                            "assets/vectors/DeleteIcon.svg",
                                            width: 22,
                                            color: themeX
                                                .textTheme.headline3.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: ButtonTheme(
                                        minWidth: 0,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.only(left: 10),
                                        child: FlatButton(
                                          onPressed: () =>
                                              _taskAboutAC.forward(),
                                          child: Icon(
                                            Icons.info_outline,
                                            color: themeX
                                                .textTheme.headline3.color
                                                .withAlpha(990),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                // # About dialog
                isNewTask
                    ? Container()
                    : Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: EdgeInsets.only(right: 20, bottom: 20),
                            child: ScaleTransition(
                              alignment: Alignment.bottomRight,
                              scale: CurvedAnimation(
                                parent: _taskAboutAC,
                                curve: Curves.easeIn,
                              ),
                              child: Container(
                                alignment: Alignment.topLeft,
                                width: 230,
                                height: 150,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: themeX.backgroundColor,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Creation date",
                                      style: TextStyle(color: lightDarkColor),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      _formatFullDate(
                                          widget.task["creation_date"]),
                                      style: TextStyle(
                                        color: themeX.textTheme.headline1.color,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Completion date",
                                      style: TextStyle(color: lightDarkColor),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      _formatFullDate(
                                          widget.task["completion_date"]),
                                      style: TextStyle(
                                        color: themeX.textTheme.headline1.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onSheetDragEnd(details) {
    double dragVelocity = details.velocity.pixelsPerSecond.dx;
    List pageIds = [];

    widget.pages.forEach((page) {
      pageIds.add(page.documentID);
    });

    if (dragVelocity.abs() >= 365.0) {
      int currentPageIndex = pageIds.indexOf(selectedPageIdToAddTask);

      if (dragVelocity < 0 && currentPageIndex != pageIds.length) {
        setState(() {
          selectedPageIdToAddTask = pageIds[currentPageIndex + 1];
        });
      } else if (currentPageIndex != 0) {
        setState(() {
          selectedPageIdToAddTask = pageIds[currentPageIndex - 1];
        });
      }
    }
  }

  _openChangeBookSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(20),
      builder: (context) {
        return ChangeBookSheet(
          widget.selectedBook,
          widget.task,
          widget.taskId,
          widget.selectedPage,
          books,
        );
      },
    );
  }

  _checkTaskChange() {
    if (widget.taskId != null) {
      bool isTaskNameChanged = widget.task["task_name"] != taskName.trim();

      bool isDueDateChanged = widget.task["due_date"] != ""
          ? selectedDate != null
              ? !selectedDate.isAtSameMomentAs(widget.task["due_date"].toDate())
              : true
          : selectedDate != null ? true : false;

      bool isPriorityChanged = widget.task["priority"] != taskPriority;

      bool isTaskNoteChanged = widget.task["note"] != taskNote;

      bool isTaskAddPageChanged =
          widget.selectedPage != selectedPageIdToAddTask;

      bool isTaskTagsChanged =
          !areListsEqual(widget.task["tag_ids"], taskTagChips);

      bool isTaskSheetChanged = isTaskNameChanged ||
          isDueDateChanged ||
          isPriorityChanged ||
          isTaskNoteChanged ||
          isTaskTagsChanged ||
          isTaskAddPageChanged;

      return isTaskSheetChanged;
    } else
      return false;
  }

  bool areListsEqual(var list1, var list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  _removeDueDate() {
    setState(() {
      selectedDate = null;
    });
  }

  _selectDate() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final initiallySelectedDate = selectedDate ?? DateTime.now();

    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: initiallySelectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
              //OK/Cancel button text color
              primaryColor: const Color(0xFF4A5BF6), //Head background
              accentColor: const Color(0xFF4A5BF6) //selection color
              //dialogBackgroundColor: Colors.white,//Background color
              ),
          child: child,
        );
      },
    );

    setState(() {
      selectedDate = pickedDate ?? selectedDate;
    });
  }

  _selectTime() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final initiallySelectedTime =
        TimeOfDay.fromDateTime(selectedDate) ?? TimeOfDay.now();

    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: initiallySelectedTime,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
              //OK/Cancel button text color
              primaryColor: const Color(0xFF4A5BF6), //Head background
              accentColor: const Color(0xFF4A5BF6) //selection color
              //dialogBackgroundColor: Colors.white,//Background color
              ),
          child: child,
        );
      },
    );

    final tempTime = pickedTime ?? TimeOfDay.fromDateTime(selectedDate);

    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, tempTime.hour, tempTime.minute);
    });
  }

  _formatDueDate(dueDate) {
    final hour = (dueDate.hour % 12).toString();
    final minutes = dueDate.minute != 0
        ? ":" + (dueDate.minute).toString().padLeft(2, '0')
        : "";
    final meridiem = dueDate.hour < 12 ? "AM" : "PM";

    final dueTime =
        (hour + minutes != "0") ? ", " + hour + minutes + meridiem : "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (aDate == today) {
      return {
        "date_time": "Today" + dueTime,
        "date": "Today",
        "time": dueTime,
        "color": dueTime != "" && dueDate.isBefore(now)
            ? pastDueDateColor
            : nearDueDateColor
      };
    } else if (aDate == yesterday) {
      return {
        "date_time": "Yesterday" + dueTime,
        "date": "Yesterday",
        "time": dueTime,
        "color": pastDueDateColor
      };
    } else if (aDate == tomorrow) {
      return {
        "date_time": "Tomorrow" + dueTime,
        "date": "Tomorrow",
        "time": dueTime,
        "color": nearDueDateColor
      };
    }

    final day = dueDate.day.toString().padLeft(2, '0');
    final month = monthsArr[dueDate.month];

    final tempFormattedDate = day + " " + month;

    final formattedColor =
        dueDate.isBefore(now) ? pastDueDateColor : futureDueDateColor;

    return {
      "date_time": tempFormattedDate + dueTime,
      "date": tempFormattedDate,
      "time": dueTime,
      "color": formattedColor
    };
  }

  parsePageButtons() {
    final themeX = Theme.of(context);
    List<Widget> pageButtonWidgets = [];

    for (int i = 0; i < widget.pages.length; i++) {
      bool isSelectedPage = false;
      String initiallySelectedPageID =
          widget.selectedPage ?? widget.pages[0].documentID;

      if (widget.pages[i].documentID == selectedPageIdToAddTask) {
        isSelectedPage = true;
        addToPageScrollController.scrollToIndex(
          i,
          preferPosition: AutoScrollPosition.middle,
        );
      }

      pageButtonWidgets.add(
        AutoScrollTag(
          key: ValueKey(i),
          controller: addToPageScrollController,
          index: i,
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
                  color: isSelectedPage
                      ? themeX.textTheme.headline1.color
                      : themeX.hintColor.withAlpha(120),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  decoration:
                      initiallySelectedPageID == widget.pages[i].documentID
                          ? TextDecoration.underline
                          : TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtonWidgets;
  }

  _makeChangesInOldTask() async {
    bool isTaskAddPageChanged = widget.selectedPage != selectedPageIdToAddTask;

    if (isTaskAddPageChanged) {
      var bytes = utf8.encode(hashCode.toString());
      var randomTaskId = base64.encode(bytes);

      DocumentReference sectionRef = widget.pageRef
          .document(selectedPageIdToAddTask)
          .collection("Sections")
          .document("not_sectioned");

      await sectionRef.setData({
        randomTaskId: {
          "task_name": taskName.trim(),
          "note": taskNote.trim(),
          "completion_date": "",
          "creation_date": DateTime.now(),
          "due_date": selectedDate ?? "",
          "is_checked": false,
          "priority": taskPriority,
          "tag_ids": taskTagChips,
        }
      }, merge: true);

      Map<String, dynamic> map = {widget.taskId: FieldValue.delete()};

      widget.pageRef
          .document(widget.selectedPage)
          .collection("Sections")
          .document("not_sectioned")
          .updateData(map);

      Navigator.of(context).pop();
    } else {
      var randomTaskId = widget.taskId;

      Map<String, dynamic> tempTaskMap = {
        randomTaskId: {
          "completion_date": "",
          "due_date": selectedDate ?? "",
          "note": taskNote,
          "priority": taskPriority,
          "tag_ids": taskTagChips,
          "task_name": taskName.trim(),
        }
      };

      _uploadTaskDetails(tempTaskMap);
    }
  }

  _createNewTask() async {
    if (widget.pages.length == 1) {
      setState(() => selectedPageIdToAddTask = widget.pages[0].documentID);
    }

    if (taskName != null && taskName != "" && widget.taskId == null) {
      var bytes = utf8.encode(UniqueKey().toString());
      var randomTaskId = base64.encode(bytes);
      randomTaskId = randomTaskId.substring(0, randomTaskId.length - 1);

      Map<String, dynamic> tempTaskMap = {
        randomTaskId: {
          "completion_date": "",
          "creation_date": DateTime.now(),
          "due_date": selectedDate ?? "",
          "is_checked": false,
          "note": taskNote,
          "priority": taskPriority,
          "tag_ids": taskTagChips,
          "task_name": taskName.trim(),
        }
      };

      await _uploadTaskDetails(tempTaskMap);
    }
  }

  _uploadTaskDetails(taskObject) async {
    DocumentReference sectionRef = widget.pageRef
        .document(selectedPageIdToAddTask)
        .collection("Sections")
        .document("not_sectioned");

    await sectionRef.setData(taskObject, merge: true);

//    await sectionRef
//        .collection("DueDates")
//        .document(taskObject.keys.first)
//        .setData(
//      {
//        "due_date": selectedDate ?? null,
//      },
//    );

    if (selectedDate != null) {
      if (selectedDate.hour != 0 || selectedDate.minute != 0) {
        await CustomNotificationHandler.scheduleNotification(
            selectedDate, taskName.trim(), taskNote);
      } else {
        DateTime dateWithDefaultTime = new DateTime(
            selectedDate.year, selectedDate.month, selectedDate.day, 8);
        await CustomNotificationHandler.scheduleNotification(
            dateWithDefaultTime, taskName.trim(), taskNote);
      }
    }

    if (closeSheetAfterCreatingTask) {
      try {
        Navigator.pop(context);
      } catch (e) {
        print(e.toString());
      }
    } else {
      taskNameController.clear();
      taskNoteController.clear();

      setState(() {
        taskName = null;
        dueDate = null;
        selectedDate = null;
        isTaskValid = false;
        taskPriority = 0;
        taskNote = "";
        taskTagChips = [];
      });
    }
  }

  _deleteTask() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete task?",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "You cannot recover this task once deleted.",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline2.color,
              ),
            ),
            actions: [
              // # Cancel button
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: semiDarkColor,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // # Delete button
              FlatButton(
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: warningColor,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () async {
                  try {
                    Map<String, dynamic> map = {
                      widget.taskId: FieldValue.delete()
                    };

                    widget.pageRef
                        .document(widget.selectedPage)
                        .collection("Sections")
                        .document("not_sectioned")
                        .updateData(map);

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("ERROR while updating task: " + e.toString());
                  }
                },
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          );
        });
  }

  _formatFullDate(datex) {
    if (datex != null && datex != "") {
      DateTime xdate = datex.toDate();

      String day = xdate.day.toString();
      String month = monthsArr[xdate.month];
      String year = xdate.year.toString();
      String hour = (xdate.hour % 12).toString();
      String minutes = xdate.minute.toString();
      String seconds = xdate.second.toString();
      String meridiem = xdate.hour > 12 ? "PM" : "AM";

      final String formattedFullDate = day +
          " " +
          month +
          ", " +
          year +
          "  •  " +
          hour +
          ":" +
          minutes +
          ":" +
          seconds +
          meridiem;

      return formattedFullDate;
    } else {
      return "Not available";
    }
  }

  _addTagsList() {
    List<Widget> tagsRowWithAddBtn = [];

    tagsRowWithAddBtn = _getTagChipsList();

    tagsRowWithAddBtn.add(
      DottedBorder(
        borderType: BorderType.RRect,
        strokeWidth: 0.5,
        dashPattern: [3, 2],
        color: lightDarkColor,
        radius: Radius.circular(7),
        child: Container(
          height: taskSheetButtonHeight - 6,
          child: ButtonTheme(
            minWidth: 0,
            height: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 13),
              onPressed: _openAddTagsSheet,
              child: Text(
                "Edit tags",
                style: TextStyle(
                  color: lightDarkColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return tagsRowWithAddBtn;
  }

  _updateTagChips(newTagIdsList) {
    List tempArr = [];

    newTagIdsList.forEach((selectedTag) {
      tempArr.add(selectedTag);
    });

    setState(() {
      taskTagChips = tempArr;
    });
  }

  _getTagChipsList() {
    // final themeNotifier = Provider.of<ThemeNotifier>(context);
    // final isDarkThemeEnabled = themeNotifier.getTheme() == darkTheme;

    List<Widget> tagChipsList = [];
    List fetchedTagsArr = taskTagChips;
    if (fetchedTagsArr.length != 0) {
      fetchedTagsArr.forEach(
        (tag) {
          tagChipsList.add(
            Container(
              height: taskSheetButtonHeight,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 13),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.5,
                ),
                color: tagsColorArr[widget.allTags[tag]["color"]].withAlpha(40),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                widget.allTags[tag]["tag_name"],
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: tagsColorArr[widget.allTags[tag]["color"]],
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      );
    }

    return tagChipsList;
  }

  _openAddTagsSheet() {
    FocusScope.of(context).requestFocus(new FocusNode());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(20),
      builder: (_) {
        return AddTagsSheet(
          widget.task,
          widget.allTags,
          widget.pageRef,
          widget.selectedPage,
          widget.taskId,
          _updateTagChips,
          taskTagChips,
        );
      },
    );
  }

  fetchBooks() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    CollectionReference todoCollectionRef = Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('Todo');

    booksSnapshot = todoCollectionRef
        .orderBy("creation_date", descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        books = data.documents;
      });
    });
  }
}
