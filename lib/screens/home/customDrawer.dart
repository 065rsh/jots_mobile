import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/drawerUserDetails.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart' as Theme;

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

  final AuthService _auth = AuthService();

  List books = [];
  String selectedBookId = "";
  String homeBookId = "";

  @override
  void initState() {
    super.initState();

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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        color: Colors.transparent,
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
              transform: Matrix4.translationValues(0, 150, 0),
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
                // User DP, Name, email & Edit button
                DrawerUserDetails(),
                // log out button
                FlatButton(
                  padding: EdgeInsets.all(5),
                  onPressed: () {
                    _auth.signOut();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/LogOutIcon.png",
                        width: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "LOG OUT",
                          style: TextStyle(
                            color: Theme.warningColor,
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
      ),
    );
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
      data.documents.forEach((doc) {
        if (homeBookId == doc.documentID && selectedBookId == "") {
          setState(() => selectedBookId = doc.documentID);
          widget.updateSelectedBook(doc);
        }
      });

      if (data.documents.length != 0 && selectedBookId == "") {
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
    List<Widget> bookWidgets = [];

    books.forEach((book) {
      bookWidgets.add(
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
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
                        color: Theme.darkTextColor,
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

    return bookWidgets;
  }
}
