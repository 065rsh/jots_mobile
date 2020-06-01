import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitted_text_field_container/fitted_text_field_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jots_mobile/screens/home/bookItem.dart';
import 'package:jots_mobile/screens/home/profileOptions.dart';
import 'package:jots_mobile/theme.dart' as Theme;
import 'package:scroll_to_index/scroll_to_index.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.brown[50],
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              ProfileOptions(),
              HomePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  PageController _pageController;
  AutoScrollController bookHeadRowController;
  TextEditingController bookNameFieldController;

  FocusNode bookNameFocusNode = new FocusNode();
  StreamSubscription<QuerySnapshot> booksSnapshot;
  CollectionReference todoCollectionRef;
  StreamSubscription<DocumentSnapshot> userDetailsSnapshot;
  DocumentReference userDetailsRef;
  Animation<Offset> _offsetAnimation;

  List books = [];
  String newBookNameText;
  String homeBookId = "";
  int currentBookIndex = 0;
  bool isProfileOptionsClosed = true;
  bool showBookOptions = false;
  bool isHomeBookSelected = false;
  bool isRefreshingBook = false;

  @override
  void initState() {
    super.initState();

    bookNameFocusNode.addListener(handleBookNameFocusNode);
    bookNameFieldController = TextEditingController();

    _fetchBooks();
    _fetchUserDetails();

    _pageController = PageController(initialPage: 0, keepPage: true);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    bookHeadRowController = AutoScrollController(
      axis: Axis.horizontal,
    );
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
    booksSnapshot.cancel();
    userDetailsSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          child: Stack(
            children: <Widget>[
              // main homepage
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(3, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    // book PageView
                    Container(
                      margin: EdgeInsets.only(top: 45),
                      child: Stack(
                        children: <Widget>[
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (bookIndex) {
                              setState(() => currentBookIndex = bookIndex);

                              bookHeadRowController.scrollToIndex(
                                bookIndex,
                                preferPosition: AutoScrollPosition.middle,
                              );
                            },
                            itemCount: books.length,
                            itemBuilder: (context, i) {
                              return BookItem(
                                books[i].documentID,
                                todoCollectionRef,
                              );
                            },
                          ),
                          AnimatedSwitcher(
                            // used AnimatedSwitcher to fade in whities overlay over home page
                            duration: Duration(milliseconds: 200),
                            child: showBookOptions
                                ? GestureDetector(
                                    onTap: () {
                                      _controller.reverse();
                                      setState(() {
                                        showBookOptions = false;
                                      });
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    },
                                    child: Container(
                                      color: Theme.lightTransparentColor,
                                    ),
                                  )
                                : Visibility(
                                    visible: false,
                                    child: Container(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // head of home
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Book names
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: bookHeadRowController,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _getBookButtons(),
                              ),
                            ),
                          ),
                          // Book head right side buttons with divider
                          Opacity(
                            opacity: showBookOptions ? 0.3 : 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // vertical divider
                                Container(
                                  color: Theme.darkLightColor,
                                  height: 35,
                                  width: 0.5,
                                ),
                                // book head buttons
                                Container(
                                  alignment: Alignment.centerRight,
                                  width: 30,
                                  height: 30,
                                  margin: EdgeInsets.only(left: 15, right: 18),
                                  child: FlatButton(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.all(0),
                                    splashColor: showBookOptions
                                        ? Colors.transparent
                                        : Theme.darkLightColor,
                                    onPressed: () {
                                      if (showBookOptions) {
                                        setState(() => showBookOptions = false);
                                      } else {
                                        if (isProfileOptionsClosed) {
                                          _controller.forward();
                                          setState(() =>
                                              isProfileOptionsClosed = false);
                                        } else {
                                          _controller.reverse();
                                          setState(() =>
                                              isProfileOptionsClosed = true);
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      child: SvgPicture.asset(
                                        "assets/vectors/SettingsIcon.svg",
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
                  ],
                ),
              ),
              // home overlay to close profile options
              AnimatedSwitcher(
                // used AnimatedSwitcher to fade in whities overlay over home page
                duration: Duration(milliseconds: 200),
                child: isProfileOptionsClosed
                    ? Visibility(
                        visible: false,
                        child: Container(),
                      )
                    : FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        onPressed: () {
                          _controller.reverse();
                          setState(() => isProfileOptionsClosed = true);
                        },
                        child: Container(
                          color: Theme.lightTransparentColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fetchBooks() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    todoCollectionRef = Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('Todo');

    booksSnapshot =
        todoCollectionRef.orderBy("creation_date").snapshots().listen((data) {
      List fetchedBooks = [];

      data.documents.forEach((doc) {
        fetchedBooks.add(doc);
      });

      setState(() {
        books = fetchedBooks;
        isRefreshingBook = true;
        showBookOptions = false;
        currentBookIndex = 0;
      });

      Future.delayed(Duration(milliseconds: 10), () {
        setState(() => isRefreshingBook = false);
      });
    });
  }

  _getBookButtons() {
    List<Widget> bookWidgets = [];
    if (currentBookIndex != null)
      for (int i = 0; i < books.length; i++) {
        String homeIcon = "assets/vectors/Home" +
            (books[currentBookIndex].documentID == homeBookId
                ? "Filled"
                : "Stroked") +
            "Icon.svg";

        bool isSelected = currentBookIndex == i;
        bool openBookOptions = showBookOptions && isSelected;

        bookNameFieldController.text =
            books[currentBookIndex].data["book_name"];

        bookWidgets.add(
          AutoScrollTag(
            key: ValueKey(i),
            controller: bookHeadRowController,
            index: i,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: AnimatedContainer(
                height: openBookOptions ? 85 : 45,
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  left: i == 0 ? 7 : 0,
                  bottom: 5,
                  right: i == books.length - 1 ? 10 : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color:
                        openBookOptions ? Theme.semiLightColor : Colors.white,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 7, right: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // button
                      ButtonTheme(
                        minWidth: 10,
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            if (isSelected) {
                              setState(() {
                                showBookOptions = true;
                              });
                            } else {
                              if (showBookOptions)
                                setState(() => showBookOptions = false);
                              else
                                _pageController.animateToPage(
                                  i,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                            }
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: openBookOptions
                                ? FittedTextFieldContainer(
                                    child: TextField(
                                      controller: bookNameFieldController,
                                      onChanged: (value) =>
                                          newBookNameText = value,
                                      focusNode: bookNameFocusNode,
                                      style: TextStyle(
                                        color: Theme.darkTextColor,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "book name...",
                                        hintStyle: TextStyle(
                                            color: Theme.lightDarkColor),
                                        isDense: true,
                                        counterText: '',
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  )
                                : Text(
                                    books[i].data["book_name"],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.darkTextColor
                                          : showBookOptions
                                              ? Theme.lightColor
                                              : Theme.darkLightColor,
                                      fontSize: 27,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),
                      ),
                      openBookOptions
                          ? Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 28,
                                    height: 35,
                                    margin: EdgeInsets.only(right: 15),
                                    child: FlatButton(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => _deleteBook(),
                                      child: Image.asset(
                                        "assets/images/DeleteIcon.png",
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.only(right: 5),
                                    child: FlatButton(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => _toggleHomeBook(),
                                      child: SvgPicture.asset(homeIcon),
                                    ),
                                  ),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(7),
                                  //   ),
                                  //   alignment: Alignment.centerRight,
                                  //   width: 25,
                                  //   margin: EdgeInsets.only(right: 5),
                                  //   height: 25,
                                  //   child: FlatButton(
                                  //     materialTapTargetSize:
                                  //         MaterialTapTargetSize.shrinkWrap,
                                  //     padding: EdgeInsets.all(0),
                                  //     onPressed: () {},
                                  //     child: SvgPicture.asset(
                                  //       "assets/vectors/EditNameIcon.svg",
                                  //       color: Theme.semiDarkColor,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

    return bookWidgets;
  }

  _fetchUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    userDetailsRef = Firestore.instance.collection('Users').document(user.uid);

    userDetailsSnapshot = userDetailsRef.snapshots().listen((doc) {
      setState(() {
        homeBookId = doc.data["homeBook"];
      });

      for (var i = 0; i < books.length; i++) {
        if (books[i].documentID == doc.data["homeBook"]) {
          _pageController.jumpToPage(i);
          setState(() {
            currentBookIndex = i;
          });
        }
      }
    });
  }

  _toggleHomeBook() async {
    setState(() {
      homeBookId = homeBookId == books[currentBookIndex].documentID
          ? "NONE"
          : books[currentBookIndex].documentID;
    });

    Map<String, dynamic> map = {"homeBook": books[currentBookIndex].documentID};

    try {
      await userDetailsRef.updateData(map);
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }

  _setBookName() async {
    try {
      await todoCollectionRef
          .document(books[currentBookIndex].documentID)
          .setData({
        "book_name": newBookNameText,
      }, merge: true);
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }

  handleBookNameFocusNode() {
    if (!bookNameFocusNode.hasFocus && newBookNameText != null) {
      // user clicked outside the field after once focused
      if (newBookNameText != "") {
        // if textfield has some book name
        _setBookName();
      } else {
        // if textfield is left empty // cannot update the name!
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("User name cannot be empty!"),
          ),
        );
      }
    }
  }

  _deleteBook() async {
    // show the dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete \"" +
                books[currentBookIndex].data["book_name"] +
                "\"?"),
            content: Text("You cannot recover this book once deleted."),
            actions: [
              // # Cancel button
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.semiDarkColor,
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
                    color: Theme.warningColor,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () async {
                  try {
                    int reservedBookIndex = currentBookIndex;

                    setState(() {
                      showBookOptions = false;
                      currentBookIndex = 0;
                    });

                    await todoCollectionRef
                        .document(books[reservedBookIndex].documentID)
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
}
