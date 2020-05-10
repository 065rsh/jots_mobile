import 'package:flutter/material.dart';
import 'theme.dart' as Theme;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF5137),
                Color(0xFFFF7F46),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: <Widget>[
                  Column(
                    //# Top content
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.centerLeft,
                        child: new Text(
                          "JOTS",
                          style: TextStyle(
                            fontFamily: 'Bungee',
                            fontSize: 50,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1.5
                              ..color = Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: new Row(
                          children: <Widget>[
                            new Container(
                              child: new Image.asset(
                                'assets/images/TickIcon.png',
                                width: 25,
                                height: 25,
                              ),
                            ),
                            new Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                              ),
                              child: new Text(
                                "Only Care about completing the task.",
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  LoginTemplate()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginTemplate extends StatefulWidget {
  LoginTemplateState createState() {
    return LoginTemplateState();
  }
}

class LoginTemplateState extends State<LoginTemplate> {
  String templateTitle = "LOG IN";

  changeTemplateTitleCB(isLogIn) {
    setState(() {
      templateTitle = isLogIn ? "LOG IN" : "SIGN UP";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(3, 7),
              ),
            ],
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    templateTitle,
                    style: TextStyle(
                      letterSpacing: 1,
                      color: Color(0xFF777777),
                      fontSize: 20,
                    ),
                  ),
                ),
                SignInForm(changeTemplateTitleCB),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SignInForm extends StatefulWidget {
  final Function(bool) changeTemplateTitleCB;

  SignInForm(this.changeTemplateTitleCB);

  SignInFormState createState() {
    return SignInFormState();
  }
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool isLogIn = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Column(
            // Email text and text field
            children: <Widget>[
              Container(
                // Email text
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                    color: Color(0xFF777777),
                  ),
                ),
              ),
              Container(
                // Email text field
                height: 45,
                margin: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.lightBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(
                        color: Color(0xFF555555),
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        hintText: "example@email.com",
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Cannot be empty!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            // password text and text field
            children: <Widget>[
              Container(
                // Password title text
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(
                    color: Color(0xFF777777),
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Container(
                    // Password text field
                    height: 45,
                    margin: EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.lightBorderColor,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          obscureText: showPassword,
                          style: TextStyle(
                            color: Color(0xFF555555),
                            decoration: TextDecoration.none,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                              left: 10,
                              right: 50,
                            ),
                            hintText: "pass****",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    width: 32,
                    height: 32,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          showPassword =
                              !showPassword; // update the state of the class to show color change
                        });
                      },
                      padding: EdgeInsets.all(4),
                      child: Image.asset("assets/images/" +
                          (showPassword ? "Show" : "Hide") +
                          "PasswordIcon.png"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            // Forgot Password Blue text
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 3),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 13,
                  color: Theme.linkColor),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  // left button, default as SIGN UP
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        isLogIn = !isLogIn;
                      });
                      widget.changeTemplateTitleCB(isLogIn);
                    },
                    child: Text(
                      isLogIn ? "SIGN UP" : "LOG IN",
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                        color: Theme.linkColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  // left button, default as SIGN UP
                  child: OutlineButton(
                    onPressed: () {},
                    borderSide: BorderSide(
                      width: 1,
                      color: Theme.lightBorderColor,
                    ),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(7.0)),
                    child: Text(
                      isLogIn ? "LOG IN" : "SIGN UP",
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                        color: Theme.darkTextColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
