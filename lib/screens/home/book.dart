import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/addTask.dart';
import 'package:jots_mobile/screens/home/pageItem.dart';
import 'package:jots_mobile/theme.dart';
import 'editPageSheet.dart';

final double maxDrawerDragStartXOffset = 40;
final double maxDrawerXOffset = 250;
final double maxDrawerYOffset = 185;
final double drawerToggleThreshold = 100;
final List filterOptionArr = [
  "Incomplete tasks",
  "Complete tasks",
  "All tasks"
];

class Book extends StatefulWidget {
  final List pages;
  final CollectionReference pageRef;
  final bool isRefreshingBook;
  final dynamic selectedBook;
  final void Function(bool) toggleDrawer;
  final String homeBookId;
  final void Function() startEditingBookName;
  final bool isDrawerOpen;
  final void Function() refreshBook;
  final dynamic allTags;

  Book(
      this.pages,
      this.pageRef,
      this.isRefreshingBook,
      this.isDrawerOpen,
      this.selectedBook,
      this.homeBookId,
      this.toggleDrawer,
      this.startEditingBookName,
      this.refreshBook,
      this.allTags);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with TickerProviderStateMixin {
  DocumentReference userDetailsRef;
  StreamSubscription<DocumentSnapshot> userDetailsSnapshot;
  AnimationController _drawerAnimationController;
  AnimationController _bookOptionsAC;

  String homeBookId = "";
  bool canSlideOpenDrawer = false;
  int filterSelected = 0;

  @override
  void initState() {
    super.initState();

    fetchHomeBook();

    _initializeDrawerAnimationController();
    _bookOptionsAC = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.0,
    );
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
        onTap: () {
          widget.toggleDrawer(false);
          _bookOptionsAC.reverse();

          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: AnimatedBuilder(
            animation: _drawerAnimationController,
            builder: (context, builderWidget) {
              double slideX =
                  maxDrawerXOffset * _drawerAnimationController.value;
              double slideY =
                  maxDrawerYOffset * _drawerAnimationController.value;
              double borderRadius = 20 * _drawerAnimationController.value;
              double scale = 1 - (_drawerAnimationController.value * 0.35);

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
                      // # Book
                      Column(
                        children: <Widget>[
                          // # Book head
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(
                                top:
                                    33 * (1 - _drawerAnimationController.value),
                                bottom: 15),
                            padding: EdgeInsets.only(left: 15, right: 10),
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
                                Align(
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
                                        _bookOptionsAC.reverse();
                                      },
                                      child: Container(
                                        child: SvgPicture.asset(
                                          "assets/vectors/DrawerIcon.svg",
                                          width: 20,
                                          color: semiDarkColor,
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
                                          splashColor: Colors.transparent,
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
                                          onPressed: () {
                                            _bookOptionsAC.forward();
                                          },
                                          child: SvgPicture.asset(
                                            "assets/vectors/KebabPlateIcon.svg",
                                            width: 22,
                                            color: filterSelected == 0
                                                ? darkTextColor
                                                : themeblue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // # Book body
                          widget.isRefreshingBook
                              ? Container(
                                  color: Colors.white,
                                )
                              : Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 15),
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        itemCount: widget.pages.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: <Widget>[
                                              PageItem(
                                                  widget.pages[index]
                                                      .data["page_name"],
                                                  widget
                                                      .pages[index].documentID,
                                                  widget.pageRef,
                                                  filterSelected,
                                                  widget.selectedBook,
                                                  widget.allTags),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      // # Book options dropdown
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(top: 45, right: 15),
                          child: ScaleTransition(
                            alignment: Alignment.topRight,
                            scale: CurvedAnimation(
                              parent: _bookOptionsAC,
                              curve: Curves.easeIn,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // # Filter Button
                                  FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        if (filterSelected ==
                                            filterOptionArr.length - 1)
                                          filterSelected = 0;
                                        else
                                          filterSelected = filterSelected + 1;
                                      });
                                      widget.refreshBook();
                                    },
                                    padding: EdgeInsets.all(0),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                            right: 17,
                                          ),
                                          child: SvgPicture.asset(
                                            "assets/vectors/FilterIcon.svg",
                                            width: 13,
                                            color: lightDarkColor,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Filter",
                                              style: TextStyle(
                                                letterSpacing: 1,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                            Text(
                                              filterOptionArr[filterSelected],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: themeblue,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // # Add Page Button
                                  FlatButton(
                                    onPressed: openCreatePageSheet,
                                    padding: EdgeInsets.only(top: 5),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                            right: 17,
                                          ),
                                          child: SvgPicture.asset(
                                            "assets/vectors/PageIcon.svg",
                                            width: 14,
                                            color: lightDarkColor,
                                          ),
                                        ),
                                        Text(
                                          "Add page",
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // # Delete Button
                                  FlatButton(
                                    onPressed: () {
                                      _bookOptionsAC.reverse();
                                      _deleteBook();
                                    },
                                    padding: EdgeInsets.only(top: 5),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                            right: 15,
                                          ),
                                          child: SvgPicture.asset(
                                            "assets/vectors/DeleteIcon.svg",
                                            width: 15,
                                            color: lightDarkColor,
                                          ),
                                        ),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // # Add task container
                      AddTask(widget.pages, widget.pageRef),
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
    _bookOptionsAC.reverse();
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

  _deleteBook() async {
    // show the dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Delete \"" + widget.selectedBook.data["book_name"] + "\"?"),
            content: Text("You cannot recover this book once deleted."),
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
                        .delete();

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

  openCreatePageSheet() {
    _bookOptionsAC.reverse();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(50),
      builder: (context) {
        return EditPageSheet(widget.selectedBook, null, null);
      },
    );
  }
}
