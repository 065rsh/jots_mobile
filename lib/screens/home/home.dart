import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/home/book.dart';
import 'package:jots_mobile/screens/home/profileOptions.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Animation<Offset> _offsetAnimation;
  bool isProfileOptionsClosed = true;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
                    alignment: Alignment.topRight, // align self
                    child: Container(
                      width: 60,
                      height: 50,
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          if (isProfileOptionsClosed) {
                            _controller.forward();
                            setState(() => isProfileOptionsClosed = false);
                          } else {
                            _controller.reverse();
                            setState(() => isProfileOptionsClosed = true);
                          }
                        },
                        child: Image.asset(
                          "assets/images/DownArrow.png",
                          width: 25,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      itemCount: 2,
                      itemBuilder: (context, i) => Book(i),
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
                  : Opacity(
                      opacity: 0.5,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        onPressed: () {
                          _controller.reverse();
                          setState(() => isProfileOptionsClosed = true);
                        },
                        color: Colors.white,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
