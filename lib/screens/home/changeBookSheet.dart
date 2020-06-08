import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/theme.dart';

class ChangeBookSheet extends StatefulWidget {
  final selectedBook;
  final selectedBookColor;
  final bool deleteCurrentTask;
  final task;
  final taskId;
  final String currentPageId;

  ChangeBookSheet(
    this.selectedBook,
    this.selectedBookColor,
    this.deleteCurrentTask,
    this.task,
    this.taskId,
    this.currentPageId,
  );

  @override
  _ChangeBookSheetState createState() => _ChangeBookSheetState();
}

class _ChangeBookSheetState extends State<ChangeBookSheet> {
  StreamSubscription<QuerySnapshot> booksSnapshot;
  List books = [];
  String newBookId;
  bool isSavedToOtherBook = false;

  @override
  void initState() {
    super.initState();

    fetchBooks();
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
        width: 300,
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
                right: 50,
                bottom: 10,
                left: 50,
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
                  Text(
                    widget.deleteCurrentTask
                        ? (isSavedToOtherBook ? "Moved" : "Move")
                        : (isSavedToOtherBook ? "Copied" : "Copy"),
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: widget.selectedBookColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    " to other book",
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
              width: 300,
              height: 0.5,
              margin: EdgeInsets.only(bottom: 20),
            ),
            Container(
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
                  Opacity(
                    opacity: isBookChanged ? 1 : 0.5,
                    child: FlatButton(
                      onPressed: _changeTaskBook,
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: isBookChanged
                              ? widget.selectedBookColor
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
    );
  }

  fetchBooks() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    CollectionReference todoCollectionRef = Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('Todo');

    booksSnapshot = todoCollectionRef
        .orderBy("creation_date", descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        books = data.documents;
      });
    });
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
                  ? widget.selectedBookColor.withAlpha(20)
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
                      ? widget.selectedBookColor
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

          if (widget.deleteCurrentTask) {
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
