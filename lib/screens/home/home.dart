import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jots_mobile/screens/home/book.dart';
import 'package:jots_mobile/screens/home/customDrawer.dart';
import 'package:jots_mobile/theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FocusNode editBookNameFocusNode = new FocusNode();
  CollectionReference todoCollectionRef;
  CollectionReference pageRef;
  StreamSubscription<QuerySnapshot> pageRefSnapshot;

  bool _isDrawerOpen = false;
  dynamic _selectedBook;
  String _homeBookId = "";
  bool _isEditingBookName = false;
  String newBookNameText;
  bool isRefreshingBook = false;
  List pages = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    editBookNameFocusNode.addListener(_handleEditBookNameFocusNode);
  }

  @override
  void dispose() {
    super.dispose();

    pageRefSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: drawerBgColor,
        body: Container(
          child: Stack(
            children: <Widget>[
              CustomDrawer(_updateSelectedBook, _updateHomeBook, _toggleDrawer),
              Book(
                  pages,
                  pageRef,
                  isRefreshingBook,
                  _isDrawerOpen,
                  _selectedBook,
                  _homeBookId,
                  _toggleDrawer,
                  _startEditingBookName,
                  _refreshBook),
              // # Editing book overlay as editing book name background
              AnimatedSwitcher(
                // used AnimatedSwitcher to fade in whities overlay over home page
                duration: Duration(milliseconds: 200),
                child: _isEditingBookName
                    ? GestureDetector(
                        onTap: () {
                          setState(() => _isEditingBookName = false);
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: Container(
                          color: lightTransparentColor,
                          margin: EdgeInsets.only(top: 35),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    color: Colors.white,
                                    height: 45,
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: TextFormField(
                                        autofocus: true,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        initialValue: _selectedBook != null
                                            ? _selectedBook.data["book_name"]
                                            : "",
                                        textAlign: TextAlign.center,
                                        focusNode: editBookNameFocusNode,
                                        onChanged: (text) {
                                          setState(() {
                                            newBookNameText = text;
                                          });
                                        },
                                        style: TextStyle(
                                          color: darkTextColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Book name...",
                                          hintStyle: TextStyle(
                                            color: lightDarkColor,
                                          ),
                                          isDense: true,
                                          counterText: '',
                                          contentPadding:
                                              EdgeInsets.only(left: 7),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
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
      ),
    );
  }

  _updateSelectedBook(selectedBook) {
    setState(() {
      _selectedBook = selectedBook;
    });

    _refreshBook();
    _fetchPages();
  }

  _refreshBook() {
    setState(() {
      isRefreshingBook = true;
    });

    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        isRefreshingBook = false;
      });
    });
  }

  _fetchPages() async {
    if (_selectedBook != null) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      CollectionReference todoCollectionRef = Firestore.instance
          .collection('Users')
          .document(user.uid)
          .collection("Todo");

      pageRef = todoCollectionRef
          .document(_selectedBook.documentID)
          .collection("Pages");

      pageRefSnapshot =
          pageRef.orderBy('creation_date').snapshots().listen((data) {
        List fetchedpages = [];

        data.documents.forEach((doc) {
          fetchedpages.add(doc);
        });

        setState(() {
          pages = fetchedpages;
        });
      });
    }
  }

  _updateHomeBook(homeBookId) {
    setState(() {
      _homeBookId = homeBookId;
    });
  }

  _toggleDrawer(drawerOpen) {
    setState(() => _isDrawerOpen = drawerOpen);
  }

  _startEditingBookName() {
    setState(() => _isEditingBookName = true);
    editBookNameFocusNode.requestFocus();
  }

  _setBookName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    try {
      todoCollectionRef = Firestore.instance
          .collection('Users')
          .document(user.uid)
          .collection('Todo');

      await todoCollectionRef.document(_selectedBook.documentID).setData({
        "book_name": newBookNameText,
      }, merge: true);
    } catch (e) {
      print("ERROR will updating task: " + e.toString());
    }
  }

  _handleEditBookNameFocusNode() {
    if (!editBookNameFocusNode.hasFocus) {
      // user clicked outside the field after once focused
      if (newBookNameText != null) {
        if (newBookNameText != "") {
          // if textfield has some book name
          _setBookName();
        } else {
          // if textfield is left empty // cannot update the name!
          _scaffoldKey.currentState.showSnackBar(
            new SnackBar(
              content: new Text(
                "Book name cannot be empty!",
              ),
            ),
          );
        }
      }
      setState(() => _isEditingBookName = false);
    }
  }
}
