import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jots_mobile/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Change user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
    // .map((FirebaseUser user) => _userFromFirebaseUser(user));
  }

  // # Sign in with GOOGLE
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      AuthResult authResult = await _auth.signInWithCredential(credential);
      FirebaseUser user = authResult.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // # Sign Up with Email and Password
  Future signUpWithEmailAndPassword(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return _userFromFirebaseUser(user);
  }

  // # LOG IN with Email and Password
  Future logInWithEmailAndPassword(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return _userFromFirebaseUser(user);
  }

  // # Send password reset Email
  Future sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  // # Check if user exists
  // Future<void> checkIfUserExists(String email) async {
  //   return _auth.
  // }
}
