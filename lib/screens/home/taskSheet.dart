import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jots_mobile/handyArr.dart';

class TaskSheet extends StatefulWidget {
  final pages;
  final pageRef;
  final selectedPage;
  final taskId;
  final task;

  TaskSheet(
    this.pages,
    this.pageRef,
    this.selectedPage,
    this.taskId,
    this.task,
  );

  @override
  _TaskSheetState createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  String selectedPageIdToAddTask;
  String taskName;
  bool isTaskChanged = false;
  Color deleteTaskButtonColor = semiDarkColor;
  DateTime dueDate;
  DateTime selectedDate;
  bool isTaskValid = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedPageIdToAddTask = widget.selectedPage;
      selectedDate = widget.taskId != null
          ? widget.task["due_date"] == ""
              ? null
              : widget.task["due_date"].toDate()
          : null;
      taskName = widget.taskId != null ? widget.task["task_name"] : null;
      isTaskValid = widget.taskId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isNewTask = widget.taskId == null;
    Color saveChangesButtonColor =
        isTaskChanged && isTaskValid ? themeblue : disabledButtonColor;
    final formattedDueDate = selectedDate != null
        ? _formatDueDate(selectedDate)
        : {"date_time": null, "date": null, "time": null, "color": null};
    bool isTimeNotAval = formattedDueDate["time"] == "" ||
        formattedDueDate["time"] == ", " ||
        formattedDueDate["time"] == null;

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
                width: 30,
                height: 3,
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
              margin: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: TextFormField(
                autofocus: isNewTask,
                initialValue: !isNewTask ? widget.task["task_name"] : "",
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    taskName = text;
                    isTaskChanged =
                        !isNewTask && widget.task["task_name"] != text;
                    isTaskValid = text.length > 0;
                  });
                },
                maxLength: 100,
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
                          color:
                              formattedDueDate["color"] ?? Colors.transparent,
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
                              : veryLightColor,
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
                            padding: EdgeInsets.symmetric(horizontal: 30),
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
                                border: Border.all(color: Colors.transparent),
                                color: isTimeNotAval
                                    ? Colors.transparent
                                    : veryLightColor,
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
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    isTimeNotAval
                                        ? "Select Time"
                                        : formattedDueDate["time"].substring(2),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
            // # Action buttons
            !isNewTask
                ? Row(
                    children: <Widget>[
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 20, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: deleteTaskButtonColor,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: FlatButton(
                          onPressed: _deleteTask,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                  "assets/vectors/DeleteIcon.svg",
                                  width: 16,
                                  color: deleteTaskButtonColor,
                                ),
                              ),
                              Text(
                                "Delete",
                                style: TextStyle(
                                  color: deleteTaskButtonColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // # save changes button
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 20, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: saveChangesButtonColor,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: FlatButton(
                          onPressed:
                              isTaskChanged ? _makeChangesInOldTask : null,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.check,
                                  color: saveChangesButtonColor,
                                  size: 20,
                                ),
                              ),
                              Text(
                                "Save changes",
                                style: TextStyle(
                                  color: saveChangesButtonColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: lightColor),
                      ),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        if (isTaskValid) {
                          addNewTask();
                        }
                      },
                      child: Text(
                        "CREATE",
                        style: TextStyle(
                          color: isTaskValid ? themeblue : semiLightColor,
                          letterSpacing: 1,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _removeDueDate() {
    setState(() {
      selectedDate = null;
      isTaskChanged = true;
    });
  }

  _selectDate() async {
    final initiallySelectedDate = selectedDate ?? DateTime.now();

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: initiallySelectedDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1));

    setState(() {
      selectedDate = pickedDate ?? selectedDate;

      isTaskChanged = widget.taskId != null
          ? widget.task["due_date"] != ""
              ? !selectedDate.isAtSameMomentAs(widget.task["due_date"].toDate())
              : true
          : true;
    });
  }

  _selectTime() async {
    final initiallySelectedTime =
        TimeOfDay.fromDateTime(selectedDate) ?? TimeOfDay.now();

    final TimeOfDay pickedTime = await showTimePicker(
        context: context, initialTime: initiallySelectedTime);

    final tempTime = pickedTime ?? TimeOfDay.fromDateTime(selectedDate);

    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, tempTime.hour, tempTime.minute);
      isTaskChanged = widget.taskId != null
          ? widget.task["due_date"] != ""
              ? !selectedDate.isAtSameMomentAs(widget.task["due_date"].toDate())
              : true
          : true;
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

  addNewTask() async {
    if (widget.pages.length == 1) {
      setState(() => selectedPageIdToAddTask = widget.pages[0].documentID);
    }

    if (taskName != null && taskName != "" && widget.taskId == null) {
      _createNewTask();
    }
  }

  _makeChangesInOldTask() {
    var randomTaskId = widget.taskId;

    Map<String, dynamic> tempTaskMap = {
      randomTaskId: {
        "completion_date": "",
        "due_date": selectedDate ?? "",
        "note": "",
        "priority": 0,
        "tag_ids": [],
        "task_name": taskName,
      }
    };

    _uploadTaskDetails(tempTaskMap);
  }

  _createNewTask() {
    var bytes = utf8.encode(hashCode.toString());
    var randomTaskId = base64.encode(bytes);

    _uploadTaskDetails({
      randomTaskId: {
        "completion_date": "",
        "creation_date": DateTime.now(),
        "due_date": selectedDate ?? "",
        "is_checked": false,
        "note": "",
        "priority": 0,
        "tag_ids": [],
        "task_name": taskName,
      }
    });
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
    Map<String, dynamic> map = {widget.taskId: FieldValue.delete()};

    widget.pageRef
        .document(widget.selectedPage)
        .collection("Sections")
        .document("not_sectioned")
        .updateData(map);

    Navigator.of(context).pop();
  }
}
