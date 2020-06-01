import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/theme.dart';

final double maxDrawerDragStartXOffset = 40;
final double maxDrawerXOffset = 250;
final double maxDrawerYOffset = 150;
final double drawerToggleThreshold = 100;

class Book extends StatefulWidget {
  final dynamic selectedBook;
  final void Function(bool) toggleDrawer;
  final String homeBookId;
  final void Function() startEditingBookName;
  final bool isDrawerOpen;

  Book(this.isDrawerOpen, this.selectedBook, this.homeBookId, this.toggleDrawer,
      this.startEditingBookName);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with TickerProviderStateMixin {
  DocumentReference userDetailsRef;
  StreamSubscription<DocumentSnapshot> userDetailsSnapshot;
  AnimationController _drawerAnimationController;

  String homeBookId = "";
  bool canSlideOpenDrawer = false;

  @override
  void initState() {
    super.initState();

    fetchHomeBook();
    _initializeDrawerAnimationController();
  }

  _initializeDrawerAnimationController() {
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();

    userDetailsSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDrawerOpen) {
      _drawerAnimationController.fling(velocity: 10.0);
    } else {
      _drawerAnimationController.fling(velocity: -10.0);
    }

    if (widget.selectedBook != null) {
      return GestureDetector(
        onHorizontalDragStart: (details) => _onDrawerDragStart(details),
        onHorizontalDragUpdate: (details) => _onDrawerDragUpdate(details),
        onHorizontalDragEnd: (details) => _onDrawerDragEnd(details),
        child: AnimatedBuilder(
            animation: _drawerAnimationController,
            builder: (context, builderWidget) {
              double slideX =
                  maxDrawerXOffset * _drawerAnimationController.value;
              double slideY =
                  maxDrawerYOffset * _drawerAnimationController.value;
              double borderRadius = 20 * _drawerAnimationController.value;
              double scale = 1 - (_drawerAnimationController.value * 0.3);

              return Transform(
                transform: Matrix4.identity()
                  ..translate(slideX, slideY)
                  ..scale(scale),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: Offset(3, 7),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Stack(
                    children: <Widget>[
                      // # Complete book except FAB
                      Column(
                        children: <Widget>[
                          // # Book header
                          Container(
                            height: 50,
                            padding:
                                EdgeInsets.only(left: 15, right: 10, bottom: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Color(0xFFdddddd),
                                ),
                              ),
                            ),
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
                                          widget.toggleDrawer(true);
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
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        onPressed: () {
                                          widget.startEditingBookName();
                                        },
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Text(
                                            widget.selectedBook != null
                                                ? widget.selectedBook
                                                    .data["book_name"]
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
                                                        widget.selectedBook
                                                            .documentID
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
                      // close drawer overlay
                      widget.isDrawerOpen
                          ? GestureDetector(onTap: () {
                              widget.toggleDrawer(false);

                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            })
                          : Container(),
                    ],
                  ),
                ),
              );
            }),
      );
    } else {
      return Container(
        color: Colors.white,
      );
    }
  }

  _onDrawerDragStart(onHorizontalDragStartDetails) {
    if (onHorizontalDragStartDetails.globalPosition.dx <
        maxDrawerDragStartXOffset) {
      canSlideOpenDrawer = true;
    }
  }

  _onDrawerDragUpdate(details) {
    if (canSlideOpenDrawer) {
      double delta = details.primaryDelta / maxDrawerXOffset;
      _drawerAnimationController.value += delta;
    } else if (widget.isDrawerOpen) {
      double delta = details.primaryDelta / maxDrawerXOffset;
      _drawerAnimationController.value += delta;
    }
  }

  _onDrawerDragEnd(details) {
    double dragVelocity = details.velocity.pixelsPerSecond.dx;
    if (dragVelocity.abs() >= 365.0) {
      double visualVelocity = dragVelocity / MediaQuery.of(context).size.width;
      _drawerAnimationController.fling(velocity: visualVelocity);

      if (dragVelocity > 0) {
        widget.toggleDrawer(true);
      } else {
        widget.toggleDrawer(false);
      }
    } else if (_drawerAnimationController.value > 0.5) {
      widget.toggleDrawer(true);
    } else {
      widget.toggleDrawer(false);
    }
    canSlideOpenDrawer = false;
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
