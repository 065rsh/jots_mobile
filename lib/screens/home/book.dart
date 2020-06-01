import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';

class Book extends StatefulWidget {
  final dynamic selectedBook;
  final void Function(dynamic) notifyParent;
  final String homeBookId;
  final void Function() startEditingBookName;

  Book(this.selectedBook, this.homeBookId, this.notifyParent,
      this.startEditingBookName);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  DocumentReference userDetailsRef;
  StreamSubscription<DocumentSnapshot> userDetailsSnapshot;

  bool isDrawerOpen = false;
  String homeBookId = "";

  @override
  void initState() {
    super.initState();

    fetchHomeBook();
  }

  @override
  void dispose() {
    super.dispose();

    userDetailsSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedBook != null) {
      return AnimatedContainer(
        transform: Matrix4.translationValues(
            isDrawerOpen ? 250.0 : 0.0, isDrawerOpen ? 150.0 : 0.0, 0)
          ..scale(isDrawerOpen ? 0.6 : 1.0),
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: Offset(3, 7),
            ),
          ],
          borderRadius: BorderRadius.circular(isDrawerOpen ? 20 : 0),
          color: Colors.white,
        ),
        child: Stack(
          children: <Widget>[
            // Complete book except FAB
            Container(
              padding: EdgeInsets.only(left: 15, right: 10),
              child: Column(
                children: <Widget>[
                  // Book header
                  Container(
                    height: 50,
                    child: Stack(
                      children: <Widget>[
                        // # Small hamburger icon
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 30,
                              height: 30,
                              child: FlatButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  setState(() {
                                    isDrawerOpen = true;
                                  });
                                  widget.notifyParent(isDrawerOpen);
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    "assets/vectors/SmallHamburgerIcon.svg",
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // # Book title
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: ButtonTheme(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              minWidth: 0,
                              height: 0,
                              child: FlatButton(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                onPressed: () {
                                  widget.startEditingBookName();
                                },
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: Text(
                                    widget.selectedBook != null
                                        ? widget.selectedBook.data["book_name"]
                                        : "NaN",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: darkTextColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // # Action buttons // Home & Kebab plate button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // # Home button
                              Container(
                                width: 40,
                                height: 40,
                                child: FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.all(0),
                                  onPressed: toggleHomeBook,
                                  child: SvgPicture.asset(
                                    "assets/vectors/Home" +
                                        (homeBookId ==
                                                widget.selectedBook.documentID
                                            ? "Filled"
                                            : "Stroked") +
                                        "Icon.svg",
                                    width: 22,
                                  ),
                                ),
                              ),
                              // # Kebab plate button
                              Container(
                                width: 40,
                                height: 40,
                                child: FlatButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {},
                                  child: SvgPicture.asset(
                                    "assets/vectors/KebabPlateIcon.svg",
                                    width: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // close drawer overlay
            isDrawerOpen
                ? GestureDetector(onTap: () {
                    setState(() {
                      isDrawerOpen = false;
                    });
                    widget.notifyParent(isDrawerOpen);

                    FocusScope.of(context).requestFocus(new FocusNode());
                  })
                : Container(),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
      );
    }
  }

  fetchHomeBook() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    userDetailsRef = Firestore.instance.collection('Users').document(user.uid);

    userDetailsSnapshot = userDetailsRef.snapshots().listen((doc) {
      setState(() {
        homeBookId = doc.data["homeBook"];
      });
    });
  }

  toggleHomeBook() async {
    setState(() {
      homeBookId = homeBookId == widget.selectedBook.documentID
          ? ""
          : widget.selectedBook.documentID;
    });

    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    userDetailsRef = Firestore.instance.collection('Users').document(user.uid);

    Map<String, dynamic> map = {"homeBook": homeBookId};

    try {
      await userDetailsRef.updateData(map);
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }
}
