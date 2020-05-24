import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/services/auth.dart';
import 'package:jots_mobile/theme.dart' as Theme;
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ProfileOptions extends StatefulWidget {
  @override
  _ProfileOptionsState createState() => _ProfileOptionsState();
}

class _ProfileOptionsState extends State<ProfileOptions> {
  FocusNode displayNameFocusNode = new FocusNode();
  final AuthService _auth = AuthService();

  FirebaseUser user;
  var userPhoto;

  String newDisplayNameText;
  bool isEditingName = false;

  final String editNameIcon = 'assets/vectors/EditNameIcon.svg';

  @override
  void initState() {
    super.initState();
    displayNameFocusNode.addListener(handleDisplayNameFocusNode);
    getFirebaseUser();
  }

  @override
  void dispose() {
    super.dispose();
    displayNameFocusNode.dispose();
  }

  void getFirebaseUser() async {
    await FirebaseAuth.instance.currentUser().then((value) => value.reload());
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    setState(() => user = currentUser);
  }

  Future getUserPhoto() async {
    try {
      var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
      );

      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child(user.uid + '/userDetails/profileImages.jpg');
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;

      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          FirebaseAuth.instance.currentUser().then((val) {
            UserUpdateInfo updateUser = UserUpdateInfo();
            updateUser.photoUrl = fileURL;
            val.updateProfile(updateUser);
          });
        });
      });

      setState(() => userPhoto = image);
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to change your display picture!"),
        ),
      );
      print(e);
    }
  }

  void handleDisplayNameFocusNode() {
    if (!displayNameFocusNode.hasFocus) {
      if (newDisplayNameText != "") {
        FirebaseAuth.instance.currentUser().then((val) {
          UserUpdateInfo updateUser = UserUpdateInfo();
          updateUser.displayName = newDisplayNameText;
          val.updateProfile(updateUser);
        });
      } else if (newDisplayNameText != null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("User name cannot be empty!"),
          ),
        );
      }

      setState(() {
        isEditingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              // user details row
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // user DP and (Display name and Email)
                    Row(
                      children: <Widget>[
                        // user photo
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              child: userPhoto != null
                                  ? Image.file(
                                      userPhoto,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : user.photoUrl != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user.photoUrl),
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                        )
                                      : Image.asset(
                                          "assets/images/NoUserPhotoIcon.png",
                                          width: 60,
                                        ),
                            ),
                            isEditingName
                                ? ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Color(0x22000000),
                                      ),
                                      child: FlatButton(
                                        onPressed: () => getUserPhoto(),
                                        child: SvgPicture.asset(
                                          "assets/vectors/EditNameIcon.svg",
                                          width: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        // display name and email
                        Container(
                          height: 43,
                          margin: EdgeInsets.only(left: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 200,
                                child: TextFormField(
                                  readOnly: !isEditingName,
                                  initialValue: user.displayName,
                                  focusNode: displayNameFocusNode,
                                  onChanged: (text) {
                                    setState(() {
                                      newDisplayNameText = text;
                                    });
                                  },
                                  maxLength: 40,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    letterSpacing: 1,
                                    color: Theme.darkTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Set user name...",
                                    hintStyle:
                                        TextStyle(color: Theme.lightDarkColor),
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: EdgeInsets.all(0),
                                    border:
                                        isEditingName ? null : InputBorder.none,
                                  ),
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Theme.semiDarkTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Edit button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isEditingName
                              ? Theme.themeblue
                              : Color(0xFFBBBBBB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerRight,
                      width: 40,
                      height: 40,
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          setState(() => isEditingName = !isEditingName);
                          displayNameFocusNode.requestFocus();
                        },
                        child: SvgPicture.asset(
                          editNameIcon,
                          color: isEditingName
                              ? Theme.themeblue
                              : Theme.semiDarkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // log out button
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 30),
                child: FlatButton(
                  padding: EdgeInsets.all(5),
                  onPressed: () {
                    _auth.signOut();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/LogOutIcon.png",
                        width: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "LOG OUT",
                          style: TextStyle(
                            color: Theme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
