import 'package:flutter/material.dart';
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
  Animation<Offset> _offsetAnimation;
  bool isProfileOptionsOpen = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.5),
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
    _controller.forward();
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
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
            Container(
              alignment: Alignment.topRight,
              child: Container(
                width: 50,
                height: 40,
                margin: EdgeInsets.only(top: 5, right: 5),
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  splashColor: Colors.transparent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    if (isProfileOptionsOpen) {
                      _controller.forward();
                      setState(() => isProfileOptionsOpen = false);
                    } else {
                      _controller.reverse();
                      setState(() => isProfileOptionsOpen = true);
                    }
                  },
                  child: Image.asset(
                    "assets/images/DownArrow.png",
                    width: 25,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
