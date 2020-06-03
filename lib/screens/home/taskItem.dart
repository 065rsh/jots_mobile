import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';

final priorityArr = ["", "Low", "Medium", "High"];
final maxTaskXOffset = -60;

class TaskItem extends StatefulWidget {
  final taskId;
  final task;
  final sectionRef;
  final allTags;

  TaskItem(this.taskId, this.task, this.sectionRef, this.allTags);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with TickerProviderStateMixin {
  bool isTaskChecked = false;
  dynamic allTags;
  AnimationController taskAnimationController;

  @override
  void initState() {
    super.initState();

    taskAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    setState(() {
      isTaskChecked = widget.task["is_checked"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 7),
      child: Stack(
        children: <Widget>[
          // # Complete task
          GestureDetector(
            onHorizontalDragUpdate: (details) => _onTaskLeftDragUpdate(details),
            onHorizontalDragEnd: (details) => _onTaskDragEnd(details),
            child: Container(
              padding: EdgeInsets.only(right: 10),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  // # task checkbox
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.only(right: 5),
                    child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.all(0),
                      onPressed: () => _toggleTaskCheck(),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isTaskChecked ? themeblue : lightDarkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: isTaskChecked ? themeblue : Colors.white,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 13.0,
                            color:
                                isTaskChecked ? Colors.white : lightDarkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // # task gesture container
                  Expanded(
                    child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      onPressed: () {},
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // # Task name
                            Text(
                              widget.task["task_name"],
                              style: TextStyle(
                                color: darkTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // # due date and priority
                            widget.task["due_date"] != "" ||
                                    widget.task["priority"] != 0
                                ? Container(
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        // # formatted due date
                                        widget.task["due_date"] != ""
                                            ? Text(
                                                _formatDueDate()["date"],
                                                style: TextStyle(
                                                  color:
                                                      _formatDueDate()["color"],
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              )
                                            : Container(),
                                        // # bullet between due date and priority
                                        widget.task["due_date"] != "" &&
                                                widget.task["priority"] != 0
                                            ? Text(
                                                "  •  ",
                                                style: TextStyle(
                                                    color: lightDarkColor),
                                              )
                                            : Container(),
                                        // # priority
                                        widget.task["priority"] != 0
                                            ? Text(
                                                priorityArr[
                                                    widget.task["priority"]],
                                                style: TextStyle(
                                                  color: widget.task[
                                                              "priority"] ==
                                                          1
                                                      ? lowPriorityColor
                                                      : widget.task[
                                                                  "priority"] ==
                                                              2
                                                          ? mediumPriorityColor
                                                          : highPriorityColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  )
                                : Container(),
                            // # Tags chips
                            Wrap(
                              runSpacing: 5,
                              children: _getTagChipsList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
              animation: taskAnimationController,
              builder: (context, builderWidget) {
                double slideX = maxTaskXOffset * taskAnimationController.value;

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: warningColor,
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width - 10 + slideX,
                    right: 10,
                  ),
                  child: FlatButton(
                    onPressed: _deleteTask,
                    splashColor: Colors.transparent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(0),
                    child: SvgPicture.asset(
                      "assets/vectors/DeleteIcon.svg",
                      width: 17,
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  _deleteTask() {
    Map<String, dynamic> map = {widget.taskId: FieldValue.delete()};

    taskAnimationController.fling(velocity: -10);
    widget.sectionRef.updateData(map);
  }

  _onTaskLeftDragUpdate(details) {
    double delta = details.primaryDelta / maxTaskXOffset;
    taskAnimationController.value += delta;
  }

  _onTaskDragEnd(details) {
    if (taskAnimationController.value > 0.5)
      taskAnimationController.fling(velocity: 10);
    else
      taskAnimationController.fling(velocity: -10);
  }

  _toggleTaskCheck() async {
    setState(() => isTaskChecked = !isTaskChecked);

    dynamic taskValues = await widget.task;

    taskValues["is_checked"] = isTaskChecked;

    Map<String, dynamic> map = {widget.taskId: taskValues};

    try {
      await widget.sectionRef.updateData(map);
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }

  _formatDueDate() {
    if (widget.task["due_date"] != "") {
      final monthArr = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      var timestamp = widget.task["due_date"] as Timestamp;
      final duedate = timestamp.toDate();

      final hour = (duedate.hour % 12).toString();
      final minutes = duedate.minute != 0
          ? ":" + (duedate.minute).toString().padLeft(2, '0')
          : "";
      final meridiem = duedate.hour < 12 ? "AM" : "PM";

      final dueTime =
          (hour + minutes != "0") ? ", " + hour + minutes + meridiem : "";

      print(dueTime);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      final aDate = DateTime(duedate.year, duedate.month, duedate.day);

      if (aDate == today) {
        return {
          "date": "Today" + dueTime,
          "color": dueTime != "" && duedate.isBefore(now)
              ? pastDueDateColor
              : nearDueDateColor
        };
      } else if (aDate == yesterday) {
        return {"date": "Yesterday" + dueTime, "color": pastDueDateColor};
      } else if (aDate == tomorrow) {
        return {"date": "Tomorrow" + dueTime, "color": nearDueDateColor};
      }

      final day = duedate.day.toString().padLeft(2, '0');
      final month = monthArr[duedate.month];

      final tempFormattedDate = day + " " + month;

      final formattedColor =
          duedate.isBefore(now) ? pastDueDateColor : futureDueDateColor;

      return {"date": tempFormattedDate + dueTime, "color": formattedColor};
    }
  }

  _getTagChipsList() {
    List<Widget> tagChipsList = [];
    List fetchedTagsArr = widget.task["tag_ids"];
    if (fetchedTagsArr.length != 0) {
      fetchedTagsArr.forEach((tag) {
        tagChipsList.add(
          Container(
            padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
            margin: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: tagsColorArr[widget.allTags[tag]["color"]],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.allTags[tag]["tag_name"],
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        );
      });
    }

    return tagChipsList;
  }
}
