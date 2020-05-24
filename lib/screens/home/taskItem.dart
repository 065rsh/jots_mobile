import 'package:flutter/material.dart';
import 'package:jots_mobile/theme.dart' as Theme;

class TaskItem extends StatefulWidget {
  final taskId;
  final task;
  final sectionRef;
  TaskItem(this.taskId, this.task, this.sectionRef);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isTaskChecked = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isTaskChecked = widget.task["is_checked"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          // checkbox
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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isTaskChecked ? Theme.themeblue : Color(0xFFBBBBBB),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: isTaskChecked ? Theme.themeblue : Colors.white,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14.0,
                    color: isTaskChecked ? Colors.white : Theme.darkLightColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.task["task_name"],
              style: TextStyle(
                color: Theme.darkTextColor,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
}
