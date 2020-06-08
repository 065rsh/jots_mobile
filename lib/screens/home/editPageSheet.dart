import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/taskSheet.dart';
import 'package:jots_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPageSheet extends StatefulWidget {
  final dynamic selectedBook;
  final String initialPageName;
  final String pageId;
  final pages;
  final pageRef;

  EditPageSheet(this.selectedBook, this.initialPageName, this.pageId,
      this.pages, this.pageRef);

  @override
  _EditPageSheetState createState() => _EditPageSheetState();
}

class _EditPageSheetState extends State<EditPageSheet> {
  String newPageName;
  FocusNode addNewPageFocusNode = FocusNode();
  FirebaseUser user;
  CollectionReference pageColRef;
  bool isCollapsePageByDefault = true;

  @override
  void initState() {
    super.initState();

    _setPageCollapseValue();
    initFirestore();
    addNewPageFocusNode.addListener(handleAddNewPageFocusNode);
  }

  _setPageCollapseValue() async {
    try {
      SharedPreferences tempPref = await SharedPreferences.getInstance();

      setState(() {
        isCollapsePageByDefault =
            tempPref.getBool(widget.pageId + "_is_collapsed") ?? true;
      });
    } catch (e) {
      print(e);
    }
  }

  handleAddNewPageFocusNode() async {
    try {
      SharedPreferences tempPref = await SharedPreferences.getInstance();
      tempPref.setBool(
          widget.pageId + "_is_collapsed", isCollapsePageByDefault);
      print(tempPref.getBool(widget.pageId + "_is_collapsed"));
    } catch (e) {
      print(e);
    }

    if (!addNewPageFocusNode.hasFocus &&
        newPageName != null &&
        newPageName != "") {
      if (widget.initialPageName != null) {
        // editing page_name
        editPageName();
      } else {
        addNewPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themex.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(15),
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
            // # Drag line icon
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
            // # Text form field
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 15, right: 20, top: 15),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Color(0x11000000),
                borderRadius: BorderRadius.circular(7),
              ),
              child: TextFormField(
                autofocus: true,
                initialValue: widget.initialPageName != null
                    ? widget.initialPageName
                    : null,
                focusNode: addNewPageFocusNode,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    newPageName = text;
                  });
                },
                style: TextStyle(
                  color: themex.textTheme.headline1.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Page name...",
                  contentPadding: EdgeInsets.only(left: 15),
                  hintStyle: TextStyle(
                    color: lightDarkColor,
                  ),
                  isDense: true,
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
            // # Keep page expanded
            Container(
              margin: EdgeInsets.only(bottom: 20, left: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    child: FlatButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          isCollapsePageByDefault = !isCollapsePageByDefault;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: lightDarkColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: isCollapsePageByDefault
                                ? lightDarkColor
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 13.0,
                            color: isCollapsePageByDefault
                                ? Colors.white
                                : lightDarkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text("Close page by default"),
                  )
                ],
              ),
            ),
            // # Page action buttons
            widget.initialPageName != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // # Delete page button
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 20, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: warningColor,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            deletePage();
                          },
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                  "assets/vectors/DeleteIcon.svg",
                                  width: 16,
                                  color: warningColor,
                                ),
                              ),
                              Text(
                                "Delete",
                                style: TextStyle(
                                  color: warningColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // # Add Task in page button
                      Container(
                        width: 120,
                        height: 40,
                        margin: EdgeInsets.only(left: 20, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: themex.textTheme.headline1.color,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: FlatButton(
                          onPressed: showAddTaskSheet,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  "+",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: themex.textTheme.headline1.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                "New Task",
                                style: TextStyle(
                                  color: themex.textTheme.headline1.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  showAddTaskSheet() {
    Navigator.of(context).pop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(50),
      builder: (context) {
        return TaskSheet(
          widget.pages,
          widget.pageRef,
          widget.pageId,
          null,
          null,
          null,
        );
      },
    );
  }

  initFirestore() async {
    user = await FirebaseAuth.instance.currentUser();

    pageColRef = Firestore.instance
        .collection("Users")
        .document(user.uid)
        .collection("Todo")
        .document(widget.selectedBook.documentID)
        .collection("Pages");
  }

  addNewPage() async {
    await pageColRef.add({
      "page_name": newPageName,
      "creation_date": DateTime.now(),
    }).then((pageRef) =>
        pageRef.collection("Sections").document("not_sectioned").setData({}));

    hideModalBottomSheet();
  }

  editPageName() async {
    await pageColRef
        .document(widget.pageId)
        .setData({"page_name": newPageName}, merge: true);

    hideModalBottomSheet();
  }

  hideModalBottomSheet() {
    try {
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  deletePage() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete \"" + widget.initialPageName + "\"?",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "You cannot recover this page once deleted.",
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

                    await Firestore.instance
                        .collection('Users')
                        .document(user.uid)
                        .collection("Todo")
                        .document(widget.selectedBook.documentID)
                        .collection("Pages")
                        .document(widget.pageId)
                        .delete();

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
