import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/settingsSheet.dart';
import 'package:jots_mobile/screens/home/drawerUserDetails.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  final void Function(dynamic) updateSelectedBook;
  final void Function(String) updateHomeBookId;
  final void Function(bool) toggleDrawer;

  CustomDrawer(
      this.updateSelectedBook, this.updateHomeBookId, this.toggleDrawer);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  StreamSubscription<QuerySnapshot> booksSnapshot;
  CollectionReference todoCollectionRef;
  StreamSubscription<DocumentSnapshot> userDetailsSnapshot;
  DocumentReference userDetailsRef;
  FocusNode newBookNameFocusNode = FocusNode();

  final AuthService _auth = AuthService();

  List books = [];
  String selectedBookId = "";
  String homeBookId = "";
  bool isAddingBook = false;
  String addBookNameText;

  bool _darkTheme = true;

  @override
  void initState() {
    super.initState();

    newBookNameFocusNode.addListener(handleNewBookNameFocusNode);
    fetchHomeBook();
    fetchBooks();
  }

  @override
  void dispose() {
    super.dispose();

    booksSnapshot.cancel();
    userDetailsSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);

    final themex = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(top: 40),
        padding: EdgeInsets.only(
          left: 20,
          top: 10,
          right: 20,
          bottom: 10,
        ),
        child: Stack(
          children: <Widget>[
            // Books container
            Container(
              width: 205,
              alignment: Alignment.topLeft,
              transform: Matrix4.translationValues(0, 140, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Books decorated title
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: SvgPicture.asset(
                      "assets/vectors/BooksTitle.svg",
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parseBooks(),
                  )
                ],
              ),
            ),
            // DrawerUserDetails & Logout button
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // # User DP, Name, email & Edit button
                DrawerUserDetails(),
                // # log out & settings button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // # Log out button
                    FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      onPressed: askLogout,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SvgPicture.asset(
                            "assets/vectors/LogOutIcon.svg",
                            width: 20,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              "LOG OUT",
                              style: TextStyle(
                                color: warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // # Settings button
                    FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      onPressed: openSettings,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.settings,
                            color: themex.textTheme.bodyText2.color,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              "SETTINGS",
                              style: TextStyle(
                                color: themex.textTheme.bodyText2.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(50),
      builder: (context) {
        return SettingsSheet(_darkTheme);
      },
    );
  }

  askLogout() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Log out",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "Are you sure?",
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
                  "Log out",
                  style: TextStyle(
                    color: warningColor,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _auth.signOut();
                },
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          );
        });
  }

  fetchHomeBook() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    userDetailsRef = Firestore.instance.collection('Users').document(user.uid);

    userDetailsSnapshot = userDetailsRef.snapshots().listen((doc) {
      setState(() {
        homeBookId = doc.data["homeBook"];
      });

      widget.updateHomeBookId(homeBookId);
    });
  }

  fetchBooks() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    todoCollectionRef = Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('Todo');

    booksSnapshot = todoCollectionRef
        .orderBy("creation_date", descending: true)
        .snapshots()
        .listen((data) {
      bool selectedBookStillExists = false;

      data.documents.forEach((doc) {
        if (homeBookId == doc.documentID && selectedBookId == "") {
          setState(() => selectedBookId = doc.documentID);
          widget.updateSelectedBook(doc);
        }
        if (selectedBookId == doc.documentID) {
          selectedBookStillExists = true;
        }
      });

      if ((data.documents.length != 0 && selectedBookId == "") ||
          !selectedBookStillExists) {
        setState(() => selectedBookId = data.documents[0].documentID);
        widget.updateSelectedBook(data.documents[0]);
      }

      data.documents.forEach((doc) {
        if (selectedBookId == doc.documentID) {
          widget.updateSelectedBook(doc);
        }
      });

      setState(() {
        books = data.documents;
      });
    });
  }

  // this will set the 'selectedBook'
  parseBooks() {
    final themex = Theme.of(context);

    List<Widget> bookWidgets = [];

    bookWidgets.add(
      isAddingBook
          ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180),
              child: Container(
                margin: EdgeInsets.only(bottom: 5),
                child: TextFormField(
                  focusNode: newBookNameFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) {
                    setState(() {
                      addBookNameText = text;
                    });
                  },
                  style: TextStyle(
                    color: themex.textTheme.bodyText2.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: "Book name...",
                    hintStyle: TextStyle(
                      color: lightDarkColor,
                    ),
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10, top: 5),
                  ),
                ),
              ),
            )
          : Container(),
    );

    books.forEach((book) {
      bookWidgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: ButtonTheme(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: 0,
            height: 20,
            child: FlatButton(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () {
                setState(() => selectedBookId = book.documentID);
                widget.updateSelectedBook(book);
                widget.toggleDrawer(false);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 180,
                    ),
                    child: Text(
                      book.data["book_name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: themex.textTheme.headline1.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  book.documentID == selectedBookId
                      ? Container(
                          margin: EdgeInsets.only(left: 7),
                          child: SvgPicture.asset(
                            "assets/vectors/RightSideStrokedArrowIcon.svg",
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      );
    });

    bookWidgets.add(
      Container(
        width: 80,
        height: 35,
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isAddingBook ? themeblue : themex.textTheme.headline1.color,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: FlatButton(
          padding: EdgeInsets.all(4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            setState(() => isAddingBook = true);
            newBookNameFocusNode.requestFocus();
          },
          child: Text(
            "+ Book",
            style: TextStyle(
              fontSize: 15,
              color: themex.textTheme.headline1.color,
            ),
          ),
        ),
      ),
    );

    return bookWidgets;
  }

  addNewBook() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    try {
      todoCollectionRef = Firestore.instance
          .collection('Users')
          .document(user.uid)
          .collection('Todo');

      todoCollectionRef.add({
        "book_name": addBookNameText,
        "creation_date": new DateTime.now(),
      }).then((bookRef) => bookRef.collection("Pages").add({
            "page_name": "General",
            "creation_date": new DateTime.now(),
          }).then((pageRef) {
            pageRef
                .collection("Sections")
                .document("not_sectioned")
                .setData({});
          }));
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }

  handleNewBookNameFocusNode() async {
    if (!newBookNameFocusNode.hasFocus) {
      if (addBookNameText != null) {
        if (addBookNameText != "") {
          addNewBook();
        } else {
          Scaffold.of(context).showSnackBar(
            new SnackBar(
              content: new Text(
                "Book name cannot be empty!",
              ),
            ),
          );
          newBookNameFocusNode.requestFocus();
          setState(() => isAddingBook = true);
        }
      }
      setState(() => isAddingBook = false);
    }
  }
}
