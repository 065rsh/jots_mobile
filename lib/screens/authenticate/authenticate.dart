import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart' as Theme;
import 'package:provider/provider.dart';
import 'package:jots_mobile/main.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
          child: Stack(
            children: <Widget>[
              Padding(
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
                    LoginTemplate(),
                  ],
                ),
              ),
              Container(
                width: 400,
                margin: EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.bottomCenter,
                child: Image.asset("assets/images/ThingsIllustration.png"),
              ),
            ],
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

const spinkit = SpinKitThreeBounce(
  color: Color(0xFF3E9FFF),
  size: 20.0,
);

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _auth = AuthService();
  final _emailTextController = TextEditingController();

  String email = "";
  String password = "";
  String emailValidityText = "";
  String passwordValidityText = "";
  RegExp emailValidityRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool hidePassword = true;
  bool isLogIn = true;
  bool isLoading = false;
  String emailNotVerifiedText = "";
  String emailVerificationText =
      "Sent verification email.\nClick link in the email to continue.";

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Color(0xFF777777),
        ),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text("Send Email"),
      onPressed: () async {
        try {
          await _auth.sendPasswordResetEmail(email);
        } catch (e) {
          if (e.toString().contains("ERROR_USER_NOT_FOUND")) {
            setState(() {
              emailValidityText = "• User not found";
            });
          }
          print(e.toString());
        }
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Forgot password?"),
      content:
          Text("We will send a change password link to your email:\n" + email),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Email
          Column(
            // Email text and text field
            children: <Widget>[
              Container(
                // Email text
                margin: EdgeInsets.only(top: 30),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Text(
                      "Email ",
                      style: TextStyle(
                        color: Color(0xFF777777),
                      ),
                    ),
                    Text(
                      emailValidityText,
                      style: TextStyle(
                        color: Theme.errorColor,
                      ),
                    ),
                  ],
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
                      controller: _emailTextController,
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
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          setState(
                              () => emailValidityText = '• Cannot be empty!');
                        } else if (!emailValidityRegExp.hasMatch(email)) {
                          setState(() => emailValidityText = "• Invalid");
                        } else {
                          setState(() => emailValidityText = "");
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Password
          Column(
            // password text and text field
            children: <Widget>[
              Container(
                // Password title text
                margin: EdgeInsets.only(top: 25),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Text(
                      "Password ",
                      style: TextStyle(
                        color: Color(0xFF777777),
                      ),
                    ),
                    Text(
                      passwordValidityText,
                      style: TextStyle(
                        color: Theme.errorColor,
                      ),
                    ),
                  ],
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
                          obscureText: hidePassword,
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
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              setState(() =>
                                  passwordValidityText = '• Cannot be empty!');
                            } else if (value.length < 8) {
                              setState(() => passwordValidityText =
                                  "• Minimum 8 characters");
                            } else {
                              setState(() => passwordValidityText = "");
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
                        setState(() => hidePassword = !hidePassword);
                      },
                      padding: EdgeInsets.all(4),
                      child: Image.asset("assets/images/" +
                          (hidePassword ? "Show" : "Hide") +
                          "PasswordIcon.png"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Forgot password
          Container(
            // Forgot Password Blue text
            alignment: Alignment.centerRight,
            child: FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.all(0),
              onPressed: () {
                if (_emailTextController.text.isEmpty) {
                  setState(() => emailValidityText = '• Cannot be empty!');
                } else if (!emailValidityRegExp
                    .hasMatch(_emailTextController.text)) {
                  setState(() => emailValidityText = "• Invalid");
                } else {
                  setState(() => emailValidityText = "");
                  showAlertDialog(context);
                }
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  height: 0,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.linkColor,
                ),
              ),
            ),
          ),
          // Buttons
          Container(
            margin: EdgeInsets.only(top: 20),
            child: isLoading
                ? spinkit
                : user != null && !user.isEmailVerified
                    ?
                    // Show email verification buttons
                    Padding(
                        padding: const EdgeInsets.only(left: 5, right: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // left button, default as SIGN UP
                                Container(
                                  child: FlatButton(
                                    onPressed: () async {
                                      setState(() => isLoading = true);
                                      try {
                                        await _auth.sendVerificationEmail(user);
                                      } catch (e) {
                                        print(e);
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    },
                                    child: Text(
                                      "Try Again!",
                                      style: TextStyle(
                                        fontSize: 15,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.darkTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                // Right button default as LOG IN
                                Container(
                                  child: OutlineButton(
                                    onPressed: () async {
                                      setState(() => isLoading = true);
                                      try {
                                        FirebaseUser currentUser =
                                            await FirebaseAuth.instance
                                                .currentUser();
                                        await currentUser.reload();
                                        if (currentUser.isEmailVerified) {
                                          setState(() => isLoading = false);
                                          RestartWidget.restartApp(context);
                                          print("VERIFIED!");
                                        } else {
                                          setState(() => emailNotVerifiedText =
                                              "Email not verified yet!");
                                          print("NOT VERIFIED!");
                                        }
                                      } catch (e) {
                                        print(e);
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    },
                                    borderSide: BorderSide(
                                      color: Theme.themeblue,
                                    ),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(7.0),
                                    ),
                                    child: Text(
                                      "DONE",
                                      style: TextStyle(
                                        fontSize: 15,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.themeblue,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width: 200,
                                  child: Text(
                                    emailVerificationText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    emailNotVerifiedText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.errorColor),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    :
                    // Show Login or Signup buttons
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // left button, default as SIGN UP
                          Container(
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
                          // Right button default as LOG IN
                          Container(
                            child: OutlineButton(
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  try {
                                    setState(() => isLoading = true);
                                    Future.delayed(const Duration(seconds: 100),
                                        () {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    });
                                    if (isLogIn) {
                                      await _auth.logInWithEmailAndPassword(
                                          email, password);
                                    } else {
                                      await _auth.signUpWithEmailAndPassword(
                                          email, password);
                                    }
                                    setState(() => isLoading = false);
                                  } catch (e) {
                                    if (e
                                        .toString()
                                        .contains("ERROR_USER_NOT_FOUND")) {
                                      setState(() {
                                        emailValidityText = "• User not found";
                                      });
                                    } else if (e
                                        .toString()
                                        .contains("ERROR_INVALID_EMAIL")) {
                                      setState(() {
                                        emailValidityText = "• Invalid";
                                      });
                                    } else if (e
                                        .toString()
                                        .contains("ERROR_WRONG_PASSWORD")) {
                                      setState(() {
                                        passwordValidityText = "• Incorrect";
                                      });
                                    } else if (e
                                        .toString()
                                        .contains("ERROR_TOO_MANY_REQUESTS")) {
                                      setState(() {
                                        passwordValidityText =
                                            "• Too many attempts, try again later!";
                                      });
                                    }
                                    print(e);
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                              borderSide: BorderSide(
                                width: 1,
                                color: Theme.lightBorderColor,
                              ),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(7.0),
                              ),
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
          // Divider
          Container(
            // Log in template divider
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Divider(
              color: Theme.lightBorderColor,
            ),
          ),
          // Google Button
          Container(
            // Continue with Google button
            width: 240,
            height: 48,
            margin: EdgeInsets.only(bottom: 10),
            child: OutlineButton(
              padding: EdgeInsets.only(left: 5, right: 5),
              onPressed: () async {
                dynamic user = await _auth.signInWithGoogle();
                if (user != null) {
                  print("USER: " + user.uid);
                } else {
                  print("ERROR!");
                }
              },
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(7.0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: Image.asset("assets/images/GoogleLogo.png"),
                  ),
                  Expanded(
                    flex: 30,
                    child: Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: Theme.darkTextColor,
                        fontSize: 15,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
