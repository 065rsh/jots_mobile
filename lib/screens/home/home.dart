import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  PageController _pageController = PageController(initialPage: 0);
  AutoScrollController bookHeadRowController;
  StreamSubscription<QuerySnapshot> booksSnapshot;
  CollectionReference todoCollectionRef;

  Animation<Offset> _offsetAnimation;
  bool isProfileOptionsClosed = true;
  List books = [];
  int currentBookIndex = 0;

  @override
  void initState() {
    super.initState();

    _fetchBooks();

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
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
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
              child: Column(
                children: <Widget>[
                  // head of home
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    alignment: Alignment.topCenter, // align self
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Book names
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: bookHeadRowController,
                            child: Row(
                              children: _getBookButtons(),
                            ),
                          ),
                        ),
                        Row(
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
                              width: 60,
                              height: 50,
                              child: FlatButton(
                                splashColor: Colors.transparent,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  if (isProfileOptionsClosed) {
                                    _controller.forward();
                                    setState(
                                        () => isProfileOptionsClosed = false);
                                  } else {
                                    _controller.reverse();
                                    setState(
                                        () => isProfileOptionsClosed = true);
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
                      ],
                    ),
                  ),
                  // book PageView
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: (bookIndex) {
                        setState(() => currentBookIndex = bookIndex);
                        bookHeadRowController.scrollToIndex(
                          bookIndex,
                          preferPosition: AutoScrollPosition.middle,
                        );
                      },
                      itemCount: books.length,
                      itemBuilder: (context, i) =>
                          BookItem(books[i].documentID, todoCollectionRef),
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
                        color: Theme.lightFadeWhitiseColor,
                      ),
                    ),
            ),
          ],
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

    booksSnapshot = todoCollectionRef.snapshots().listen((data) {
      List fetchedBookNames = [];

      data.documents.forEach((doc) {
        fetchedBookNames.add(doc);
      });

      setState(() {
        books = fetchedBookNames;
      });
    });
  }

  _getBookButtons() {
    List<Widget> bookWidgets = [];

    for (int i = 0; i < books.length; i++) {
      bookWidgets.add(
        AutoScrollTag(
          key: ValueKey(i),
          controller: bookHeadRowController,
          index: i,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 7),
            child: FlatButton(
              splashColor: Colors.transparent,
              onPressed: () {},
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Text(
                    books[i].data["book_name"],
                    style: TextStyle(
                      color: currentBookIndex == i
                          ? Theme.darkTextColor
                          : Theme.darkLightColor,
                      fontSize: 27,
                      fontWeight: currentBookIndex == i
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return bookWidgets;
  }
}
