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
  final allTags;

  EditPageSheet(
    this.selectedBook,
    this.initialPageName,
    this.pageId,
    this.pages,
    this.pageRef,
    this.allTags,
  );

  @override
  _EditPageSheetState createState() => _EditPageSheetState();
}

class _EditPageSheetState extends State<EditPageSheet> {
  bool isCollapsePageByDefault = true;
  bool initialCollapsePageByDefault = true;
  bool isPageNameValid = false;
  CollectionReference pageColRef;
  FocusNode addNewPageFocusNode = FocusNode();
  FirebaseUser user;
  String newPageName;
  String pageId;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    _setPageCollapseValue();
    initFirestore();
  }

  _setPageCollapseValue() async {
    try {
      SharedPreferences tempPref = await SharedPreferences.getInstance();

      setState(() {
        isCollapsePageByDefault =
            tempPref.getBool(widget.pageId ?? "" + "_is_collapsed") ?? true;
        initialCollapsePageByDefault =
            tempPref.getBool(widget.pageId ?? "" + "_is_collapsed") ?? true;
        isPageNameValid = widget.initialPageName != null;
        newPageName = widget.initialPageName ?? "";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);
    bool isCreatingNewPage = widget.initialPageName == null;
    bool canSubmitPageName = isPageNameValid &&
        (newPageName != widget.initialPageName ||
            initialCollapsePageByDefault != isCollapsePageByDefault);

    return AnimatedPadding(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
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
            // # Text form field
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: lightDarkColor.withAlpha(30),
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
                    isPageNameValid = text.length > 0;
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
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: isCreatingNewPage ? 15 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // # Close page by default check button
                  FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        isCollapsePageByDefault = !isCollapsePageByDefault;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10),
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
                        Container(
                          child: Text(
                            "Close page by default",
                            style: TextStyle(
                              color: themex.textTheme.bodyText2.color,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  isCreatingNewPage
                      ? ButtonTheme(
                          minWidth: 0,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: FlatButton(
                            onPressed: () {
                              if (isPageNameValid) {
                                addNewPage();
                              }
                            },
                            child: Text(
                              "CREATE",
                              style: TextStyle(
                                color: isPageNameValid
                                    ? themeblue
                                    : lightDarkColor.withAlpha(80),
                                letterSpacing: 1,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            // # Page action buttons
            !isCreatingNewPage
                ? Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // # Delete page button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: warningColor),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  deletePage();
                                },
                                child: SvgPicture.asset(
                                  "assets/vectors/DeleteIcon.svg",
                                  width: 17,
                                  color: warningColor,
                                ),
                              ),
                            ),
                            // # Add Task in page button
                            Container(
                              height: 40,
                              margin: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: themex.textTheme.headline1.color,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: FlatButton(
                                onPressed: showAddTaskSheet,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          fontSize: 25,
                                          color:
                                              themex.textTheme.headline1.color,
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
                        ),
                        ButtonTheme(
                          minWidth: 0,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: FlatButton(
                            onPressed: () async {
                              if (canSubmitPageName) {
                                await editPageName();
                              }
                            },
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                color: canSubmitPageName
                                    ? themeblue
                                    : lightDarkColor.withAlpha(80),
                                letterSpacing: 1,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
          widget.allTags,
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
    print("newPageName: " + newPageName ?? "IS NULL");

    DocumentReference newPageRef = await pageColRef.add({
      "page_name": newPageName.trim(),
      "creation_date": DateTime.now(),
    });

    await newPageRef
        .collection("Sections")
        .document("not_sectioned")
        .setData({});

    await hideModalBottomSheet(newPageRef.documentID);
  }

  editPageName() async {
    await pageColRef
        .document(widget.pageId)
        .setData({"page_name": newPageName.trim()}, merge: true);

    hideModalBottomSheet(widget.pageId);
  }

  hideModalBottomSheet(pageId) async {
    try {
      SharedPreferences tempPref = await SharedPreferences.getInstance();
      await tempPref.setBool(pageId + "_is_collapsed", isCollapsePageByDefault);
    } catch (e) {
      print(e);
    }

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

                    Navigator.pop(context);
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
