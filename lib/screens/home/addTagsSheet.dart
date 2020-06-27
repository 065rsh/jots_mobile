import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';
import 'addNewTagSheet.dart';

class AddTagsSheet extends StatefulWidget {
  final task;
  final allTags;
  final pageRef;
  final selectedPageId;
  final taskId;
  final Function(List) updateTagsList;
  final taskTagChipsFromSheet;

  AddTagsSheet(
    this.task,
    this.allTags,
    this.pageRef,
    this.selectedPageId,
    this.taskId,
    this.updateTagsList,
    this.taskTagChipsFromSheet,
  );

  @override
  _AddTagsSheetState createState() => _AddTagsSheetState();
}

class _AddTagsSheetState extends State<AddTagsSheet> {
  FocusNode addNewTagFN = FocusNode();

  bool isTagsSelectionChanged = false;
  List _selectedTagsList;
  bool isAddingTags = false;
  int selectedColor = 0;
  bool isEditingTags = false;

  @override
  void initState() {
    super.initState();

    addNewTagFN.addListener(_handleAddNewTagFN);

    setState(() {
      _selectedTagsList = widget.taskTagChipsFromSheet;
    });
  }

  _handleAddNewTagFN() {
    setState(() {
      isAddingTags = addNewTagFN.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: themex.dialogBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(2, 4),
                )
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // # Title
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 15,
                    right: 25,
                    bottom: 15,
                    left: 25,
                  ),
                  decoration: BoxDecoration(
                    color: themex.dialogBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    // $ Adding border gives some unknown error
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Edit tags",
                        style: TextStyle(
                          color: themex.textTheme.headline1.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          // # Add new tag
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              strokeWidth: 0.5,
                              dashPattern: [3, 2],
                              color: lightDarkColor,
                              radius: Radius.circular(30),
                              child: ButtonTheme(
                                minWidth: 0,
                                height: 30,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                child: FlatButton(
                                  onPressed: () =>
                                      _openAddNewTagSheet(null, null),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: Text(
                                    "+  Tag",
                                    style: TextStyle(
                                      color: lightDarkColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // # Edit tags
                          Opacity(
                            opacity: widget.allTags.length == 0 ? 0.5 : 1,
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              strokeWidth: 0.5,
                              dashPattern: [3, 2],
                              color: lightDarkColor,
                              radius: Radius.circular(30),
                              child: ButtonTheme(
                                minWidth: 30,
                                height: 30,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 5),
                                child: FlatButton(
                                  onPressed: () {
                                    if (widget.allTags.length != 0) {
                                      setState(() {
                                        isEditingTags = !isEditingTags;
                                      });
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: SvgPicture.asset(
                                    "assets/vectors/EditIcon.svg",
                                    color: isEditingTags
                                        ? themeblue
                                        : lightDarkColor,
                                    width: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // # Divider
                Container(
                  color: themex.dividerColor,
                  width: 350,
                  height: 0.5,
                  margin: EdgeInsets.only(bottom: 20),
                ),
                // # Editing tags text
                isEditingTags
                    ? Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Tap on tag to edit!",
                          style: TextStyle(
                            color: themeblue,
                          ),
                        ),
                      )
                    : Container(),
                // # Tags wrapped row
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    runSpacing: 20,
                    children: _allTagRow(),
                  ),
                ),
                // # Maximum limit text
                _selectedTagsList.length < 4
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          "Reached Maximum limit",
                          style: TextStyle(color: warningColor),
                        ),
                      ),
                // # Cancel and save buttons
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 20,
                    right: 50,
                    bottom: 20,
                    left: 50,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: lightDarkColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: isTagsSelectionChanged ? 1 : 0.5,
                        child: FlatButton(
                          onPressed: () {
                            if (isTagsSelectionChanged) {
                              _saveNewTagsList();
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: isTagsSelectionChanged
                                  ? themeblue
                                  : lightDarkColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _allTagRow() {
    final themex = Theme.of(context);

    List<Widget> allTagsList = [];

    final allTagsKeys = widget.allTags.keys;

    if (allTagsKeys.length != 0) {
      allTagsKeys.forEach((tagId) {
        bool isThisTagSelected = _selectedTagsList.contains(tagId);

        allTagsList.add(
          ButtonTheme(
            minWidth: 0,
            height: 0,
            child: FlatButton(
              onPressed: () {
                if (isEditingTags) {
                  _openAddNewTagSheet(widget.allTags[tagId], tagId);
                } else {
                  List tempArr = [];

                  _selectedTagsList.forEach((selectedTag) {
                    tempArr.add(selectedTag);
                  });

                  if (isThisTagSelected) {
                    tempArr.remove(tagId);
                  } else if (_selectedTagsList.length < 4) {
                    tempArr.add(tagId);
                  }

                  setState(() {
                    _selectedTagsList = tempArr;
                    isTagsSelectionChanged = widget.taskId != null
                        ? !areListsEqual(tempArr, widget.taskTagChipsFromSheet)
                        : true;
                  });
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.all(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 13),
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0.5,
                  ),
                  color: isThisTagSelected
                      ? tagsColorArr[widget.allTags[tagId]["color"]]
                          .withAlpha(30)
                      : themex.hintColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.allTags[tagId]["tag_name"],
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: isThisTagSelected
                        ? tagsColorArr[widget.allTags[tagId]["color"]]
                        : lightDarkColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      });
    } else {
      allTagsList.add(Container(
        child: Text(
          "Tap on \"+ tag\" to create new tag",
          style: TextStyle(
            color: lightDarkColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ));
    }

    return allTagsList;
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

  _saveNewTagsList() async {
    widget.updateTagsList(_selectedTagsList);

    try {
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }

  _openAddNewTagSheet(tag, tagId) {
    try {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(20),
      builder: (_) {
        return AddNewTagSheet(tag, tagId);
      },
    );
  }
}
