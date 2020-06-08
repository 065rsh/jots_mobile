import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jots_mobile/handyArr.dart';
import 'changeBookSheet.dart';

class TaskSheet extends StatefulWidget {
  final pages;
  final pageRef;
  final selectedPage;
  final taskId;
  final task;
  final selectedBook;

  TaskSheet(
    this.pages,
    this.pageRef,
    this.selectedPage,
    this.taskId,
    this.task,
    this.selectedBook,
  );

  @override
  _TaskSheetState createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> with TickerProviderStateMixin {
  AnimationController _taskAboutAC;

  String selectedPageIdToAddTask;
  String taskName;
  DateTime dueDate;
  DateTime selectedDate;
  bool isTaskValid = false;
  int taskPriority = 0;
  String taskNote;

  @override
  void initState() {
    super.initState();

    _taskAboutAC = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.0,
    );

    setState(() {
      selectedPageIdToAddTask = widget.selectedPage;
      selectedDate = widget.taskId != null
          ? widget.task["due_date"] == ""
              ? null
              : widget.task["due_date"].toDate()
          : null;
      taskName = widget.taskId != null ? widget.task["task_name"] : null;
      isTaskValid = widget.taskId != null;
      taskPriority = widget.taskId != null ? widget.task["priority"] : 0;
      taskNote = widget.taskId != null ? widget.task["note"] : "";
    });
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
    final themex = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: themex.dialogBackgroundColor,
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
                    // # Drag logo
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 30,
                        height: 3,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: themex.hintColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // # Add to page row
                    widget.pages.length == 1
                        ? Container()
                        : Container(
                            width: double.infinity,
                            margin:
                                EdgeInsets.only(left: 20, top: 15, right: 20),
                            padding: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: themex.dividerColor,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: parsePageButtons(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    // # Text form field
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 20, left: 20),
                      child: TextFormField(
                        autofocus: isNewTask,
                        initialValue:
                            !isNewTask ? widget.task["task_name"] : "",
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
                          color: themex.textTheme.headline3.color,
                          fontSize: 18,
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
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 7, right: 20),
                      child: Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/vectors/NotesIcon.svg",
                              width: 17,
                              color: lightDarkColor.withAlpha(900),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextFormField(
                                  initialValue: taskNote,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  onChanged: (value) =>
                                      setState(() => taskNote = value),
                                  style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    color: themex.textTheme.headline3.color
                                        .withAlpha(950),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Add a note...",
                                    hintStyle: TextStyle(color: lightDarkColor),
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: EdgeInsets.only(left: 5),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // # Due Date Container
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 20, bottom: 20),
                      child: Column(
                        children: <Widget>[
                          // # Due date head
                          Row(
                            children: <Widget>[
                              Text(
                                "Due date" +
                                    (formattedDueDate["date_time"] == null
                                        ? ""
                                        : "  •  "),
                                style: TextStyle(color: lightDarkColor),
                              ),
                              Text(
                                formattedDueDate["date_time"] ?? "",
                                style: TextStyle(
                                  color: formattedDueDate["color"] ??
                                      Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                          // # Due date action buttons
                          Row(
                            children: <Widget>[
                              Container(
                                height: 40,
                                margin: EdgeInsets.only(top: 8, right: 20),
                                decoration: BoxDecoration(
                                  color: formattedDueDate["date"] == null
                                      ? Colors.transparent
                                      : Color(0x11000000),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  strokeWidth: 0.5,
                                  dashPattern: [3, 2],
                                  color: formattedDueDate["date"] == null
                                      ? lightDarkColor
                                      : Colors.transparent,
                                  radius: Radius.circular(7),
                                  child: FlatButton(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30),
                                    onPressed: _selectDate,
                                    child: Text(
                                      formattedDueDate["date"] ?? "Select Date",
                                      style: TextStyle(
                                        color: formattedDueDate["date"] == null
                                            ? lightDarkColor
                                            : semiDarkColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              formattedDueDate["date"] != null
                                  ? Container(
                                      height: 40,
                                      margin: EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.transparent),
                                        color: isTimeNotAval
                                            ? Colors.transparent
                                            : Color(0x11000000),
                                        borderRadius: BorderRadius.circular(7),
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
                                              horizontal: 30),
                                          child: Text(
                                            isTimeNotAval
                                                ? "Select Time"
                                                : formattedDueDate["time"]
                                                    .substring(2),
                                            style: TextStyle(
                                              color: isTimeNotAval
                                                  ? lightDarkColor
                                                  : semiDarkColor,
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
                                      width: 30,
                                      height: 30,
                                      margin: EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                        color: themex.dialogBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
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
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // # Priority Container
                    // priority title text
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        "Priority",
                        style: TextStyle(color: lightDarkColor),
                      ),
                    ),
                    // priority button
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 20, top: 8, bottom: 20),
                      decoration: BoxDecoration(
                        color: taskPriority == 0
                            ? Colors.transparent
                            : Color(0x11000000),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        strokeWidth: 0.5,
                        dashPattern: [3, 2],
                        color: taskPriority == 0
                            ? lightDarkColor
                            : Colors.transparent,
                        radius: Radius.circular(7),
                        child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              taskPriority =
                                  taskPriority == priorityArr.length - 1
                                      ? 0
                                      : taskPriority + 1;
                            });
                          },
                          child: Text(
                            priorityArr[taskPriority].toUpperCase(),
                            style: TextStyle(
                              color: taskPriority == 0
                                  ? lightDarkColor
                                  : taskPriority == 1
                                      ? lowPriorityColor
                                      : taskPriority == 2
                                          ? mediumPriorityColor
                                          : highPriorityColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              letterSpacing: taskPriority == 0 ? 0 : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // # Copy task container
                    isNewTask
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(bottom: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(bottom: 7, left: 20),
                                  child: Text(
                                    "Add to other book",
                                    style: TextStyle(color: lightDarkColor),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      margin:
                                          EdgeInsets.only(right: 20, left: 20),
                                      decoration: BoxDecoration(
                                        color: themeblue.withAlpha(20),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FlatButton(
                                        onPressed: () {
                                          _openChangeBookSheet(
                                              themeblue, false);
                                        },
                                        child: Text(
                                          "COPY",
                                          style: TextStyle(
                                            color: themeblue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: warningColor.withAlpha(20),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: FlatButton(
                                        onPressed: () {
                                          _openChangeBookSheet(
                                              warningColor, true);
                                        },
                                        child: Text(
                                          "MOVE",
                                          style: TextStyle(color: warningColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    // # Action buttons
                    isNewTask
                        ? Opacity(
                            opacity: isTaskValid ? 1 : 0.5,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: themex.dividerColor),
                                ),
                              ),
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
                                        : lightDarkColor,
                                    letterSpacing: 1,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 20, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              themex.textTheme.headline1.color,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: FlatButton(
                                        onPressed: _deleteTask,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: SvgPicture.asset(
                                                "assets/vectors/DeleteIcon.svg",
                                                width: 16,
                                                color: themex
                                                    .textTheme.headline1.color,
                                              ),
                                            ),
                                            Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: themex
                                                    .textTheme.headline1.color,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // # save changes button
                                    Opacity(
                                      opacity:
                                          isTaskChangedAndIsValid ? 1 : 0.5,
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(left: 20),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isTaskChangedAndIsValid
                                                ? themeblue
                                                : lightDarkColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: FlatButton(
                                          onPressed: _checkTaskChange()
                                              ? _makeChangesInOldTask
                                              : null,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                child: Icon(
                                                  Icons.check,
                                                  color: isTaskChangedAndIsValid
                                                      ? themeblue
                                                      : lightDarkColor,
                                                  size: 20,
                                                ),
                                              ),
                                              Text(
                                                "Save changes",
                                                style: TextStyle(
                                                  color: isTaskChangedAndIsValid
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
                                  ],
                                ),
                                Container(
                                  child: FlatButton(
                                    onPressed: () => _taskAboutAC.forward(),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: Icon(
                                      Icons.info_outline,
                                      color: themex.textTheme.headline1.color
                                          .withAlpha(900),
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),

                // # About button
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
                                width: 200,
                                height: 130,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: themex.backgroundColor,
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
                                        color: themex.textTheme.headline1.color,
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
                                        color: themex.textTheme.headline1.color,
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

  _openChangeBookSheet(selectedBookColor, deleteCurrentTask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: selectedBookColor.withAlpha(20),
      builder: (context) {
        return ChangeBookSheet(widget.selectedBook, selectedBookColor,
            deleteCurrentTask, widget.task, widget.taskId, widget.selectedPage);
      },
    );
  }

  _checkTaskChange() {
    if (widget.taskId != null) {
      bool isTaskNameChanged = widget.task["task_name"] != taskName;

      bool isDueDateChanged = widget.task["due_date"] != ""
          ? selectedDate != null
              ? !selectedDate.isAtSameMomentAs(widget.task["due_date"].toDate())
              : true
          : selectedDate != null ? true : false;

      bool isPriorityChanged = widget.task["priority"] != taskPriority;

      bool isTaskNoteChanged = widget.task["note"] != taskNote;

      bool isTaskAddPageChanged =
          widget.selectedPage != selectedPageIdToAddTask;

      return isTaskNameChanged ||
          isDueDateChanged ||
          isPriorityChanged ||
          isTaskNoteChanged ||
          isTaskAddPageChanged;
    } else
      return false;
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
    final themex = Theme.of(context);
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
                  color: isSelectedPage
                      ? themex.textTheme.headline1.color
                      : themex.hintColor,
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
          "completion_date": "",
          "creation_date": DateTime.now(),
          "due_date": selectedDate ?? "",
          "is_checked": false,
          "note": taskNote,
          "priority": taskPriority,
          "tag_ids": [],
          "task_name": taskName,
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
          "tag_ids": [],
          "task_name": taskName,
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
      var bytes = utf8.encode(hashCode.toString());
      var randomTaskId = base64.encode(bytes);

      await _uploadTaskDetails({
        randomTaskId: {
          "completion_date": "",
          "creation_date": DateTime.now(),
          "due_date": selectedDate ?? "",
          "is_checked": false,
          "note": taskNote,
          "priority": taskPriority,
          "tag_ids": [],
          "task_name": taskName,
        }
      });
    }
  }

  _uploadTaskDetails(taskObject) async {
    DocumentReference sectionRef = widget.pageRef
        .document(selectedPageIdToAddTask)
        .collection("Sections")
        .document("not_sectioned");

    await sectionRef.setData(taskObject, merge: true);

    try {
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
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
}
