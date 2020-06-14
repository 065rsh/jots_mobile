import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/theme.dart';

class ChangeBookSheet extends StatefulWidget {
  final selectedBook;
  final task;
  final taskId;
  final String currentPageId;
  final books;

  ChangeBookSheet(
    this.selectedBook,
    this.task,
    this.taskId,
    this.currentPageId,
    this.books,
  );

  @override
  _ChangeBookSheetState createState() => _ChangeBookSheetState();
}

class _ChangeBookSheetState extends State<ChangeBookSheet> {
  StreamSubscription<QuerySnapshot> booksSnapshot;
  List books = [];
  String newBookId;
  bool isSavedToOtherBook = false;
  bool shouldDeleteTaskAfterCopy = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      books = widget.books;
      newBookId = widget.selectedBook.documentID;
    });
  }

  @override
  void dispose() {
    super.dispose();

    booksSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);
    bool isBookChanged = newBookId != widget.selectedBook.documentID;

    return Center(
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
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: themex.dialogBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 0,
                        child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              shouldDeleteTaskAfterCopy = false;
                            });
                          },
                          child: Text(
                            isSavedToOtherBook && !shouldDeleteTaskAfterCopy
                                ? "Copied"
                                : "Copy",
                            style: TextStyle(
                              decoration: shouldDeleteTaskAfterCopy
                                  ? TextDecoration.none
                                  : TextDecoration.underline,
                              color: shouldDeleteTaskAfterCopy
                                  ? lightDarkColor.withAlpha(80)
                                  : themeblue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "  or  ",
                        style: TextStyle(
                          color: themex.textTheme.headline1.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 0,
                        child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              shouldDeleteTaskAfterCopy = true;
                            });
                          },
                          child: Text(
                            isSavedToOtherBook && shouldDeleteTaskAfterCopy
                                ? "Moved"
                                : "Move",
                            style: TextStyle(
                              decoration: shouldDeleteTaskAfterCopy
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              color: shouldDeleteTaskAfterCopy
                                  ? warningColor
                                  : lightDarkColor.withAlpha(80),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "  to other book",
                    style: TextStyle(
                      color: themex.textTheme.headline1.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: themex.dividerColor,
              width: 350,
              height: 0.5,
              margin: EdgeInsets.only(bottom: 20),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                runSpacing: 15,
                children: _parseBookNames(),
              ),
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
                    onPressed: _changeTaskBook,
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: isBookChanged
                            ? (shouldDeleteTaskAfterCopy
                                ? warningColor
                                : themeblue)
                            : lightDarkColor.withAlpha(50),
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

  _parseBookNames() {
    final themex = Theme.of(context);
    List<Widget> bookNames = [];
    books.forEach(
      (book) {
        final bool isInitialBook =
            book.documentID == widget.selectedBook.documentID;

        final bool isCurrentlySelectedBook =
            book.documentID == (newBookId ?? widget.selectedBook.documentID);

        bookNames.add(
          Container(
            height: 40,
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: isCurrentlySelectedBook
                  ? (shouldDeleteTaskAfterCopy
                      ? warningColor.withAlpha(20)
                      : themeblue.withAlpha(20))
                  : themex.textTheme.headline2.color.withAlpha(20),
              borderRadius: BorderRadius.circular(7),
            ),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  newBookId = book.documentID;
                });
              },
              child: Text(
                book.data["book_name"],
                style: TextStyle(
                  color: isCurrentlySelectedBook
                      ? (shouldDeleteTaskAfterCopy ? warningColor : themeblue)
                      : themex.textTheme.headline2.color,
                  decoration: isInitialBook
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight:
                      isInitialBook ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );

    return bookNames;
  }

  _changeTaskBook() async {
    if (newBookId != widget.selectedBook.documentID) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      Firestore.instance
          .collection("Users")
          .document(user.uid)
          .collection("Todo")
          .document(newBookId)
          .collection("Pages")
          .where("page_name", isEqualTo: "General")
          .getDocuments()
          .then((event) async {
        if (event.documents.isNotEmpty) {
          final String pageId = event.documents.single.documentID;

          await Firestore.instance
              .collection("Users")
              .document(user.uid)
              .collection("Todo")
              .document(newBookId)
              .collection("Pages")
              .document(pageId)
              .collection("Sections")
              .document("not_sectioned")
              .setData({widget.taskId: widget.task}, merge: true);

          if (shouldDeleteTaskAfterCopy) {
            await Firestore.instance
                .collection("Users")
                .document(user.uid)
                .collection("Todo")
                .document(widget.selectedBook.documentID)
                .collection("Pages")
                .document(widget.currentPageId)
                .collection("Sections")
                .document("not_sectioned")
                .updateData({widget.taskId: FieldValue.delete()});
          }

          setState(() {
            isSavedToOtherBook = true;
          });

          Future.delayed(Duration(seconds: 1), () {
            try {
              Navigator.of(context).pop();
            } catch (e) {
              print(e);
            }
          });
        }
      });
    }
  }
}
