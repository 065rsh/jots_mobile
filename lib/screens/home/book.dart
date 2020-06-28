import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/handyArr.dart';
import 'package:jots_mobile/screens/home/addNewTagSheet.dart';
import 'package:jots_mobile/screens/home/addTask.dart';
import 'package:jots_mobile/screens/home/pageItem.dart';
import 'package:jots_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editPageSheet.dart';

final double maxDrawerDragStartXOffset = 50;
final double maxDrawerXOffset = 250;
final double maxDrawerYOffset = 185;
final double drawerToggleThreshold = 100;

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
    this.allTags,
  );

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
  int defaultFilterInt = 0;
  int sortBySelected = 0;
  int defaultSortByInt = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchHomeBook();

    _setLocalDefaultFilter();
    _setLocalDefaultSortBy();

    _initializeDrawerAnimationController();
    _bookOptionsAC = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.0,
    );
  }

  @override
  void dispose() {
    super.dispose();

    userDetailsSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeX = Theme.of(context);

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
          _bookOptionsAC.reverse();

          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: AnimatedBuilder(
          animation: _drawerAnimationController,
          builder: (context, builderWidget) {
            double slideX = maxDrawerXOffset * _drawerAnimationController.value;
            double slideY = maxDrawerYOffset * _drawerAnimationController.value;
            double borderRadius = 20 * _drawerAnimationController.value;
            double scale = 1 - (_drawerAnimationController.value * 0.35);

            return Transform(
              transform: Matrix4.identity()
                ..translate(slideX, slideY)
                ..scale(scale),
              child: Container(
                decoration: BoxDecoration(
                  color: themeX.primaryColor,
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
                            top: 33 * (1 - _drawerAnimationController.value),
                          ),
                          padding: EdgeInsets.only(left: 15, right: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: themeX.dividerColor,
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
                                        color: themeX.textTheme.headline2.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // # Book title
                              Align(
                                alignment: Alignment.center,
                                child: ButtonTheme(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minWidth: 0,
                                  height: 0,
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: FlatButton(
                                    onPressed: () {
                                      widget.startEditingBookName();
                                    },
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Text(
                                        widget.selectedBook != null
                                            ? widget
                                                .selectedBook.data["book_name"]
                                            : "NaN",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              themeX.textTheme.headline1.color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
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
                                          color:
                                              filterSelected != defaultFilterInt
                                                  ? themeblue
                                                  : themeX.textTheme.headline2
                                                      .color,
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
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      itemCount: widget.pages.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return PageItem(
                                          index,
                                          filterSelected,
                                          sortBySelected,
                                          widget.selectedBook,
                                          widget.allTags,
                                          widget.pages,
                                          widget.pageRef,
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
                            padding: EdgeInsets.only(
                                top: 10, right: 10, bottom: 20, left: 10),
                            width: 210,
                            decoration: BoxDecoration(
                              color: themeX.dialogBackgroundColor,
                              borderRadius: BorderRadius.circular(3),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
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
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  "Filter",
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: themeX.textTheme
                                                        .headline1.color,
                                                  ),
                                                ),
                                                Text(
                                                  filterOptionArr[
                                                      filterSelected],
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
                                      Container(
                                        width: 30,
                                        height: 30,
                                        child: FlatButton(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.all(0),
                                          onPressed: () async {
                                            setState(() {
                                              defaultFilterInt = filterSelected;
                                            });

                                            try {
                                              SharedPreferences tempPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              tempPref.setInt("default_filter",
                                                  filterSelected);
                                            } catch (e) {
                                              print(e);
                                            }
                                          },
                                          child: Icon(
                                            defaultFilterInt == filterSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                            size: 20,
                                            color: defaultFilterInt ==
                                                    filterSelected
                                                ? themeblue
                                                : lightDarkColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // # Sort Button
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: themeX.dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        if (sortBySelected ==
                                            sortByArr.length - 1)
                                          sortBySelected = 0;
                                        else
                                          sortBySelected = sortBySelected + 1;
                                      });
                                      widget.refreshBook();
                                    },
                                    padding: EdgeInsets.all(0),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 10,
                                                  right: 13,
                                                ),
                                                child: Icon(
                                                  Icons.sort,
                                                  size: 17,
                                                  color: lightDarkColor,
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    "Sort by",
                                                    style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: themeX.textTheme
                                                          .headline1.color,
                                                    ),
                                                  ),
                                                  Text(
                                                    sortByArr[sortBySelected],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: themeblue,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          child: FlatButton(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            padding: EdgeInsets.all(0),
                                            onPressed: () async {
                                              setState(() {
                                                defaultSortByInt =
                                                    sortBySelected;
                                              });

                                              try {
                                                SharedPreferences tempPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                tempPref.setInt(
                                                    "default_sort_by",
                                                    sortBySelected);
                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                            child: Icon(
                                              defaultSortByInt == sortBySelected
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                      .radio_button_unchecked,
                                              size: 20,
                                              color: defaultSortByInt ==
                                                      sortBySelected
                                                  ? themeblue
                                                  : lightDarkColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // # Add Page Button
                                FlatButton(
                                  onPressed: openCreatePageSheet,
                                  padding: EdgeInsets.only(top: 20),
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
                                          color:
                                              themeX.textTheme.headline1.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // # Edit tags Button
                                FlatButton(
                                  onPressed: () {
                                    _bookOptionsAC.reverse();
                                    _openAddNewTagSheet(null, null);
                                  },
                                  padding: EdgeInsets.only(top: 25),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 8,
                                          right: 15,
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/vectors/TagIcon.svg",
                                          width: 18,
                                          color: lightDarkColor,
                                        ),
                                      ),
                                      Text(
                                        "Edit tags",
                                        style: TextStyle(
                                          letterSpacing: 1,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              themeX.textTheme.headline1.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // # Clear completed Button
                                FlatButton(
                                  onPressed: () {
                                    _bookOptionsAC.reverse();
                                    _clearCompletedTasks();
                                  },
                                  padding: EdgeInsets.only(top: 25),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: lightDarkColor,
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                          left: 8,
                                          right: 14,
                                        ),
                                        child: Icon(
                                          Icons.clear,
                                          color: lightDarkColor,
                                          size: 15,
                                        ),
                                      ),
                                      Text(
                                        "Clear completed",
                                        style: TextStyle(
                                          letterSpacing: 1,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              themeX.textTheme.headline1.color,
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
                                  padding: EdgeInsets.only(top: 25),
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
                                          color:
                                              themeX.textTheme.headline1.color,
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
                    AddTask(
                      widget.pages,
                      widget.pageRef,
                      widget.allTags,
                      borderRadius,
                    ),
                    // # close drawer overlay
                    widget.isDrawerOpen
                        ? GestureDetector(
                            onHorizontalDragStart: (details) =>
                                _onDrawerDragStart(details),
                            onHorizontalDragUpdate: (details) =>
                                _onDrawerDragUpdate(details),
                            onHorizontalDragEnd: (details) =>
                                _onDrawerDragEnd(details),
                            onTap: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              widget.toggleDrawer(false);
                            })
                        : Container(),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        color: Colors.white,
      );
    }
  }

  _initializeDrawerAnimationController() {
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  _setLocalDefaultFilter() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        defaultFilterInt = prefs.getInt('default_filter') ?? 0;
        filterSelected = prefs.getInt('default_filter') ?? 0;
      });
    } catch (e) {
      print(e);
    }
  }

  _setLocalDefaultSortBy() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        defaultSortByInt = prefs.getInt('default_sort_by') ?? 0;
        sortBySelected = prefs.getInt('default_sort_by') ?? 0;
      });
    } catch (e) {
      print(e);
    }
  }

  _clearCompletedTasks() {
    // show the dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete completed tasks?",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "You cannot recover these tasks once deleted.",
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
                    widget.pageRef.getDocuments().then((value) {
                      value.documents.forEach((page) {
                        widget.pageRef
                            .document(page.documentID)
                            .collection("Sections")
                            .document("not_sectioned")
                            .get()
                            .then((value) {
                          final taskIds = value.data.keys;
                          taskIds.forEach((taskId) {
                            if (value[taskId]["is_checked"]) {
                              widget.pageRef
                                  .document(page.documentID)
                                  .collection("Sections")
                                  .document("not_sectioned")
                                  .updateData({taskId: FieldValue.delete()});
                            }
                          });
                        });
                      });
                    });

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

  _onDrawerDragStart(onHorizontalDragStartDetails) {
    if (onHorizontalDragStartDetails.globalPosition.dx <
        maxDrawerDragStartXOffset) {
      canSlideOpenDrawer = true;
    }
    _bookOptionsAC.reverse();
  }

  _onDrawerDragUpdate(details) {
    if (canSlideOpenDrawer || widget.isDrawerOpen) {
      double delta = details.primaryDelta / maxDrawerXOffset;
      _drawerAnimationController.value += delta;
    }
  }

  _onDrawerDragEnd(details) {
    FocusScope.of(context).requestFocus(new FocusNode());

    double dragVelocity = details.velocity.pixelsPerSecond.dx;

    if (dragVelocity.abs() >= 365.0 &&
        (canSlideOpenDrawer || widget.isDrawerOpen)) {
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
              "Delete \"" + widget.selectedBook.data["book_name"] + "\"?",
              style: TextStyle(
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            content: Text(
              "You cannot recover this book once deleted.",
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
        return EditPageSheet(
          widget.selectedBook,
          null,
          null,
          null,
          null,
          widget.allTags,
        );
      },
    );
  }

  _openAddNewTagSheet(tag, tagId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(20),
      builder: (_) {
        return AddNewTagSheet(null, null);
      },
    );
  }
}
