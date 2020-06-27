import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';
import 'package:jots_mobile/models/globals.dart' as globals;

class AddNewTagSheet extends StatefulWidget {
  final tag;
  final tagId;

  AddNewTagSheet(this.tag, this.tagId);

  @override
  _AddNewTagSheetState createState() => _AddNewTagSheetState();
}

class _AddNewTagSheetState extends State<AddNewTagSheet> {
  bool isTagNameValid = false;
  bool isAddingNewTag = false;
  bool tagAlreadyExists = false;
  int selectedColor = 0;
  int initialTagColor = 0;
  String tagId;
  String tagName;
  String initialTagName;
  TextEditingController tagNameTextController;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    String tempTagName = widget.tagId != null ? widget.tag["tag_name"] : "";
    int tempTagColor = widget.tagId != null ? widget.tag["color"] : 0;

    tagNameTextController = new TextEditingController(text: tempTagName);

    var bytes = utf8.encode(UniqueKey().toString());
    var randomTaskId = base64.encode(bytes);
    randomTaskId = randomTaskId.substring(0, randomTaskId.length - 1);

    setState(() {
      tagId = widget.tagId ?? randomTaskId;
      tagName = tempTagName;
      selectedColor = tempTagColor;
      isAddingNewTag = widget.tagId == null;
      initialTagName = tempTagName;
      initialTagColor = tempTagColor;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeX = Theme.of(context);
    bool canSubmitTag = isTagNameValid &&
        (initialTagName != tagName || initialTagColor != selectedColor);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeX.dialogBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: AnimatedPadding(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // # "Create new tag" text
              Row(
                children: <Widget>[
                  Text(
                    "Tags",
                    style: TextStyle(
                      color: themeX.textTheme.headline1.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // # Tag name text field
              Container(
                margin: EdgeInsets.only(top: 15),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: themeX.hintColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        autofocus: true,
                        controller: tagNameTextController,
                        maxLength: 15,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) => setState(() {
                          tagName = value;
                          isTagNameValid = tagName.length > 0;
                        }),
                        style: TextStyle(
                          color: themeX.textTheme.headline1.color,
                        ),
                        decoration: InputDecoration(
                          hintText: "Tag name...",
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    tagName.length < 1
                        ? Container()
                        : ButtonTheme(
                            minWidth: 0,
                            height: 0,
                            padding: EdgeInsets.all(0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            child: FlatButton(
                              onPressed: () {
                                tagNameTextController.text = "";
                                setState(() {
                                  tagName = "";
                                  selectedColor = 0;
                                  isAddingNewTag = true;
                                });
                              },
                              child: Icon(
                                Icons.clear,
                                size: 20,
                                color: lightDarkColor,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              // # All tags scrollable row
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parseAllTagsList(),
                  ),
                ),
              ),
              // # Color selector wrap
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Wrap(
                  runSpacing: 7.5,
                  spacing: 17,
                  children: parseColorsRow(),
                ),
              ),
              // # Delete tag & action buttons
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // # Delete tag button
                    isAddingNewTag
                        ? Container()
                        : Container(
                            width: 30,
                            height: 20,
                            child: FlatButton(
                              onPressed: deleteTag,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(0),
                              child: SvgPicture.asset(
                                "assets/vectors/DeleteIcon.svg",
                                width: 20,
                              ),
                            ),
                          ),
                    // # Action buttons
                    Row(
                      children: <Widget>[
                        // # Cancel button
                        ButtonTheme(
                          height: 0,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.only(left: 15, right: 20),
                          child: FlatButton(
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
                        ),
                        // # Create/Edit button
                        ButtonTheme(
                          minWidth: 0,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: FlatButton(
                            onPressed: () async {
                              if (tagAlreadyExists) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Tag already exists!",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                .color,
                                          ),
                                        ),
                                        content: Text(
                                          "Cannot create multiple tags with similar name.",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline2
                                                .color,
                                          ),
                                        ),
                                        actions: [
                                          // # Delete button
                                          FlatButton(
                                            child: Text(
                                              "Okay",
                                              style: TextStyle(
                                                color: warningColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            onPressed: () {
                                              try {
                                                Navigator.of(context).pop();
                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                          )
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                      );
                                    });
                              } else if (canSubmitTag) {
                                await createNewTag();
                              }
                            },
                            child: Text(
                              isAddingNewTag ? "Create" : "Edit",
                              style: TextStyle(
                                color: widget.tagId == null
                                    ? (canSubmitTag
                                        ? themeblue
                                        : lightDarkColor.withAlpha(80))
                                    : (checkIfTagChanged()
                                        ? themeblue
                                        : lightDarkColor.withAlpha(80)),
                                fontSize: 20,
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
        ),
      ),
    );
  }

  parseColorsRow() {
    List<Widget> allColorButtons = [];

    for (int i = 0; i < tagsColorArr.length; i++) {
      bool isSelectedColor = selectedColor == i;

      allColorButtons.add(
        ButtonTheme(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(0),
          minWidth: 0,
          child: FlatButton(
            onPressed: () {
              setState(() {
                selectedColor = i;
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelectedColor
                    ? tagsColorArr[i].withAlpha(20)
                    : tagsColorArr[i],
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSelectedColor
                  ? Icon(
                      Icons.check,
                      color: tagsColorArr[i],
                    )
                  : Container(),
            ),
          ),
        ),
      );
    }
    return allColorButtons;
  }

  parseAllTagsList() {
    List<Widget> allTagWidgetsArr = [];

    dynamic allTags = globals.allTags;
    tagAlreadyExists = false;

    Color tagColor = tagsColorArr[selectedColor];
    allTagWidgetsArr.add(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: tagColor.withAlpha(30),
          // border: Border.all(color: tagColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          tagName,
          style: TextStyle(color: tagColor),
        ),
      ),
    );

    allTags.keys.forEach((tagId) {
      int tagColorId = allTags[tagId]["color"];
      Color tagColor = tagsColorArr[tagColorId];
      String tagName = allTags[tagId]["tag_name"];

      if (tagName == this.tagName) {
        tagAlreadyExists = true;
      } else if (tagName.toLowerCase().contains(this.tagName.toLowerCase())) {
        allTagWidgetsArr.add(
          ButtonTheme(
            minWidth: 0,
            height: 0,
            padding: EdgeInsets.all(0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: FlatButton(
              onPressed: () {
                tagNameTextController.text = tagName;
                setState(() {
                  this.tagName = tagName;
                  selectedColor = tagColorId;
                  isAddingNewTag = false;
                  this.tagId = tagId;
                  initialTagName = tagName;
                  initialTagColor = tagColorId;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  tagName,
                  style: TextStyle(color: tagColor),
                ),
              ),
            ),
          ),
        );
      }
    });

    return allTagWidgetsArr;
  }

  bool checkIfTagChanged() {
    bool isTagNameChanged = tagName != widget.tag["tag_name"];

    bool isTagColorChanged = selectedColor != widget.tag["color"];

    return isTagNameChanged || isTagColorChanged;
  }

  createNewTag() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    await Firestore.instance.collection("Users").document(user.uid).setData({
      "tags": {
        "todo": {
          tagId: {
            "tag_name": tagName,
            "color": selectedColor,
            "creation_date": isAddingNewTag
                ? DateTime.now()
                : globals.allTags[tagId]["creation_date"],
          }
        }
      }
    }, merge: true).then((value) {
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    });
  }

  deleteTag() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete \"" + tagName + "\" tag?",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "You cannot recover this tag once deleted.",
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
                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();

                    Map<String, dynamic> map = {
                      "tags": {
                        "todo": {
                          tagId: FieldValue.delete(),
                        }
                      }
                    };

                    await Firestore.instance
                        .collection("Users")
                        .document(user.uid)
                        .setData(map, merge: true);

                    Navigator.of(context).pop();
                    Navigator.pop(context);
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
}
