import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';

class AddNewTagSheet extends StatefulWidget {
  final tag;
  final tagId;

  AddNewTagSheet(this.tag, this.tagId);

  @override
  _AddNewTagSheetState createState() => _AddNewTagSheetState();
}

class _AddNewTagSheetState extends State<AddNewTagSheet> {
  bool isTagNameValid = false;
  int selectedColor = 0;
  String tagId;
  String newTagName;

  @override
  void initState() {
    super.initState();

    var bytes = utf8.encode(UniqueKey().toString());
    var randomTaskId = base64.encode(bytes);
    randomTaskId = randomTaskId.substring(0, randomTaskId.length - 1);

    setState(() {
      newTagName = widget.tagId != null ? widget.tag["tag_name"] : "";
      selectedColor = widget.tagId != null ? widget.tag["color"] : 0;
      tagId = widget.tagId != null ? widget.tagId : randomTaskId;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: themex.dialogBackgroundColor,
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
        child: Column(
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
            Container(
              margin: EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Create new tag",
                    style: TextStyle(
                      color: themex.textTheme.headline1.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    child: FlatButton(
                        onPressed: deleteTag,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0),
                        child: SvgPicture.asset(
                          "assets/vectors/DeleteIcon.svg",
                          width: 17,
                        )),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: themex.hintColor.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                // focusNode: addNewTagFN,
                onChanged: (value) => setState(() {
                  newTagName = value;
                  isTagNameValid = newTagName.length > 0;
                }),
                initialValue: newTagName,
                style: TextStyle(
                  color: themex.textTheme.headline1.color,
                ),
                decoration: InputDecoration(
                  hintText: "tag name...",
                  border: InputBorder.none,
                ),
              ),
            ),
            Wrap(
              runSpacing: 10,
              children: parseColorsRow(),
            ),
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
                  FlatButton(
                    onPressed: () {
                      if (isTagNameValid) {
                        createNewTag();
                      }
                    },
                    child: Text(
                      widget.tagId != null ? "Edit" : "Create",
                      style: TextStyle(
                        color: widget.tagId == null
                            ? (isTagNameValid
                                ? themeblue
                                : lightDarkColor.withAlpha(80))
                            : (checkIfTagChanged()
                                ? themeblue
                                : lightDarkColor.withAlpha(80)),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  parseColorsRow() {
    List<Widget> allColorButtons = [];

    for (int i = 0; i < tagsColorArr.length; i++) {
      bool isSelectedColor = selectedColor == i;

      allColorButtons.add(
        FlatButton(
          onPressed: () {
            setState(() {
              selectedColor = i;
            });
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: isSelectedColor
                  ? tagsColorArr[i].withAlpha(20)
                  : tagsColorArr[i],
              borderRadius: BorderRadius.circular(5),
            ),
            child: isSelectedColor
                ? Icon(
                    Icons.check,
                    color: tagsColorArr[i],
                  )
                : Container(),
          ),
        ),
      );
    }
    return allColorButtons;
  }

  bool checkIfTagChanged() {
    bool isTagNameChanged = newTagName != widget.tag["tag_name"];

    bool isTagColorChanged = selectedColor != widget.tag["color"];

    return isTagNameChanged || isTagColorChanged;
  }

  createNewTag() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    await Firestore.instance.collection("Users").document(user.uid).setData({
      "tags": {
        "todo": {
          tagId: {
            "tag_name": newTagName,
            "color": selectedColor,
            "creation_date": widget.tagId != null
                ? widget.tag["creation_date"]
                : DateTime.now(),
          }
        }
      }
    }, merge: true);

    try {
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
  }

  deleteTag() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete \"" + newTagName + "\" tag?",
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
}
