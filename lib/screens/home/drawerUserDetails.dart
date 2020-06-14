import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jots_mobile/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class DrawerUserDetails extends StatefulWidget {
  @override
  _DrawerUserDetailsState createState() => _DrawerUserDetailsState();
}

class _DrawerUserDetailsState extends State<DrawerUserDetails> {
  FocusNode displayNameFocusNode = new FocusNode();

  FirebaseUser user;
  var userPhoto;

  String newDisplayNameText;
  bool isEditingUser = false;

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

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);

    if (user != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // # user DP and (Display name and Email)
          Row(
            children: <Widget>[
              // # user photo
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
                                backgroundImage: NetworkImage(user.photoUrl),
                                radius: 30,
                                backgroundColor: Colors.transparent,
                              )
                            : Image.asset(
                                "assets/images/NoUserPhotoIcon.png",
                                width: 60,
                              ),
                  ),
                  isEditingUser
                      ? ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(30),
                            ),
                            child: FlatButton(
                              onPressed: () => getUserPhoto(),
                              child: SvgPicture.asset(
                                "assets/vectors/EditIcon.svg",
                                width: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
              // # display name and email
              Container(
                height: 43,
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextFormField(
                        readOnly: !isEditingUser,
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
                          color: themex.textTheme.headline1.color,
                        ),
                        decoration: InputDecoration(
                          hintText: "Set user name...",
                          hintStyle: TextStyle(color: lightDarkColor),
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.all(0),
                          border: isEditingUser ? null : InputBorder.none,
                        ),
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: semiDarkTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // # Edit button
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isEditingUser ? themeblue : lightDarkColor,
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
                setState(() => isEditingUser = !isEditingUser);
                displayNameFocusNode.requestFocus();
              },
              child: SvgPicture.asset(
                "assets/vectors/EditIcon.svg",
                color: isEditingUser ? themeblue : lightDarkColor,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Future getUserPhoto() async {
    try {
      var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 200,
      );

      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child(user.uid + '/userDetails/profileImages.jpg');
      StorageUploadTask uploadTask = storageReference.putFile(File(image.path));
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

  void getFirebaseUser() async {
    await FirebaseAuth.instance.currentUser().then((value) => value.reload());
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    setState(() => user = currentUser);
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
        isEditingUser = false;
      });
    }
  }
}
