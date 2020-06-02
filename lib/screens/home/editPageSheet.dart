import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';

class EditPageSheet extends StatefulWidget {
  final dynamic selectedBook;
  final String initialPageName;
  final String pageId;

  EditPageSheet(this.selectedBook, this.initialPageName, this.pageId);

  @override
  _EditPageSheetState createState() => _EditPageSheetState();
}

class _EditPageSheetState extends State<EditPageSheet> {
  String newPageName;
  FocusNode addNewPageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    addNewPageFocusNode.addListener(handleAddNewPageFocusNode);
  }

  handleAddNewPageFocusNode() async {
    print(newPageName);
    if (!addNewPageFocusNode.hasFocus &&
        newPageName != null &&
        newPageName != "") {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      CollectionReference bookRef = Firestore.instance
          .collection("Users")
          .document(user.uid)
          .collection("Todo")
          .document(widget.selectedBook.documentID)
          .collection("Pages");

      await bookRef.add({
        "page_name": newPageName,
        "creation_date": DateTime.now(),
      }).then((pageRef) =>
          pageRef.collection("Sections").document("not_sectioned").setData({}));

      try {
        Navigator.pop(context);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
                width: 40,
                height: 5,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: semiLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // # Text form field
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 25, right: 20, top: 15),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: lightColor,
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
                  color: darkTextColor,
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
                          onPressed: deletePage,
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
                            color: semiDarkColor,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: FlatButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  "+",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: darkTextColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                "New Task",
                                style: TextStyle(
                                  color: darkTextColor,
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

  deletePage() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete \"" + widget.initialPageName + "\"?"),
            content: Text("You cannot recover this page once deleted."),
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
