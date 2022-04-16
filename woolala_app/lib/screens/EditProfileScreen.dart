import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../main.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

Future<void> unFollow(String currentAccountID, String otherAccountID) async {
  http.Response res = await http.post(Uri.parse(
      domain + '/unfollow/' + currentAccountID + '/' + otherAccountID));
}

Future<void> deleteUser(String currentAccountID) async {
  http.Response res =
      await http.post(Uri.parse(domain + '/deleteUser/' + currentAccountID));
  print(res);
}

Future<void> deletePosts(String currentAccountID) async {
  http.Response res = await http
      .post(Uri.parse(domain + '/deleteAllPosts/' + currentAccountID));
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameController = TextEditingController();
  TextEditingController handleController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool _profileNameValid = true;
  bool _bioValid = true;
  final picker = ImagePicker();
  File _image;
  PickedFile pickedFile;
  String img64;
  List<Object> args;

  //Lists to delete the followers and following.
  List followingList = [];
  List followerList = [];

  unFollowAll() async {
    followingList = currentUser.following;
    followerList = currentUser.followers;
    for (int i = 0; i < followingList.length; i++) {
      await unFollow(currentUser.userID, followingList[i]);
    }
    for (int i = 0; i < followerList.length; i++) {
      await unfollow(followerList[i], currentUser.userID);
    }
    await deletePosts(currentUser.userID);
    //await deleteUser(currentUser.userID);
  }

  void initState() {
    super.initState();
    displayUserInfo();
  }

  Future<File> cropProfilePic(imagePath) async {
    File onlyCroppedImage = await ImageCropper.cropImage(
      sourcePath: imagePath,
      maxHeight: 400,
      maxWidth: 400,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'ChooseNXT',
        activeControlsWidgetColor: Colors.blue,
        toolbarColor: Colors.white,
        toolbarWidgetColor: Colors.black,
      ),
    );
    return onlyCroppedImage;
  }

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage (source: ImageSource.gallery);
    if (pickedFile != null) {
      //_image = File(pickedFile.path);
      _image = await cropProfilePic(pickedFile.path);
      if (_image != null) {
        final bytes = _image.readAsBytesSync();
        img64 = base64Encode(bytes);
        http.Response res = await currentUser.setProfilePic(img64);
        //print("Res: " + res.toString());
        //Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/editProfile');
      }else {
        print('No image selected.');
      }
    } else {
      final snackBar =
      SnackBar(content: Text('No image has been selected'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //http.Response res = await currentUser.setProfilePic('default');
      //Navigator.pushReplacementNamed(context, '/editProfile');
    }
  }

  displayUserInfo() async {
    setState(() {
      loading = true;
    });
    //access the user's info from the database and set the default text to be the current text
    profileNameController.text = currentUser.profileName;
    handleController.text = currentUser.userName;
    bioController.text = currentUser.bio;
    urlController.text = currentUser.url;

    setState(() {
      loading = false;
    });
  }

  updateUserInfo() {
    setState(() {
      profileNameController.text.trim().length < 2 ||
              profileNameController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;
      bioController.text.trim().length > 140
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_bioValid && _profileNameValid) {
      print("update user info on server");
      currentUser.setUserBio(bioController.text.trim());
      currentUser.setProfileName(profileNameController.text.trim());
      currentUser.setUserName(handleController.text.trim());
      currentUser.setURL(urlController.text.trim());
      SnackBar successSB = SnackBar(
        content: Text("Profile Updated Successfully"),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSB);
    } else {
      SnackBar failedSB = SnackBar(
        content: Text("Profile Failed to Update"),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(failedSB);
    }
  }

  @override
  Widget build(BuildContext context) {
    //args = ModalRoute.of(context).settings.arguments;
    //_image = args[0];
    // img64 = args[1];
    //print("PROFILE PIC: " + currentUser.profilePic);

    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        leading: BackButton(
          // color: Colors.white,
          color: Colors.black,
          onPressed: () =>
              {Navigator.pushReplacementNamed(context, '/profile')},
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              // color: Colors.white,
              color: Colors.black,
              size: 30.0,
            ),
            onPressed: () => {
              updateUserInfo(),
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 7.0),
                  child: Column(children: <Widget>[
                    GestureDetector(
                      onTap: () => {
                        getImageGallery(),
                      },
                      child: currentUser.createProfileAvatar(),
                    )
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      createProfileNameTextFormField(),
                      createHandleTextFormField(),
                      createBioTextFormField(),
                      createUrlTextFormField(),
                      createPrivacySwitch(),
                      createUserTypeSwitch(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createDeleteButton(),
              ])
          //alignment: FractionalOffset.bottomCenter,
          ),
    );
  }

  Row createPrivacySwitch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            "Private Account",
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Switch(
            value: currentUser.private,
            onChanged: (value) {
              setState(() {
                currentUser.setPrivacy(value);
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Row createUserTypeSwitch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Text(
            "Brand Account",
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Switch(
            value: currentUser.brand,
            onChanged: (value) {
              setState(() {
                currentUser.setBrand(value);
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget createDeleteButton() {
    return RaisedButton(
      child: Text('Delete Account'),
      color: Colors.red,
      textColor: Colors.white,
      elevation: 5,
      padding: EdgeInsets.fromLTRB(80.0, 0, 80, 0),
      onPressed: () {
        showDeleteConfirmation(context);
      },
    );
  }

  showDeleteConfirmation(BuildContext context) {
    Widget cancelButton = FlatButton(
      textColor: Colors.black,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = FlatButton(
      child: Text("Continue"),
      textColor: Colors.red,
      onPressed: () async {
        unFollowAll();
        deleteUser(currentUser.userID);
        Navigator.popUntil(context, ModalRoute.withName('/'));
        googleLogoutUser();
        facebookLogoutUser();
        Navigator.pushNamed(context, '/');
      },
    );

    AlertDialog deleteConfirmation = AlertDialog(
      title: Text('Delete Account'),
      content: Text("Are you sure you want to delete your ChooseNXT Account?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return deleteConfirmation;
      },
    );
  }

 Column createHandleTextFormField(){
 return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: <Widget>[
         Padding(
           padding: EdgeInsets.only(top: 13.0),
           child: Text(
             "User Handle",
             style: TextStyle(color: Colors.black),
           ),
         ),
         TextField(
           style: TextStyle(color: Colors.black),
           controller: handleController,
           decoration: InputDecoration(
             hintText: "Enter user handle here",
             enabledBorder: UnderlineInputBorder(
               borderSide: BorderSide(color: Colors.grey),
             ),
             focusedBorder: UnderlineInputBorder(
               borderSide: BorderSide(color: Colors.black),
             ),
             hintStyle: TextStyle(color: Colors.grey),
           ),
         )
       ],
     );
 }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: profileNameController,
          decoration: InputDecoration(
            hintText: "Write your profile name here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText:
                _profileNameValid ? null : "Profile Name is insufficient",
          ),
        )
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 26.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Enter your bio here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _bioValid ? null : "Bio is too long",
          ),
        )
      ],
    );
  }

  Column createUrlTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 26.0),
          child: Text(
            "URL",
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: urlController,
          decoration: InputDecoration(
            hintText: "Enter your URL here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            // errorText: _bioValid ? null : "Bio is too long",
          ),
        )
      ],
    );
  }

  createProfilePicturePicker() {
    return FutureBuilder(
        future: changeProfilePic(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                print('Error: ${snapshot.error}');
              else
                print('Result: ${snapshot.data}');
          }
          return currentUser.createProfileAvatar();
        });
  }

  changeProfilePic() async {
    print("Picture Changing...");
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      final bytes = _image.readAsBytesSync();
      img64 = base64Encode(bytes);
    } else {
      img64 = "default";
    }
    await currentUser.setProfilePic(img64);
    print("Picture");
  }

  Future pickImage() async {
    pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      final bytes = _image.readAsBytesSync();
      img64 = base64Encode(bytes);
    } else {
      img64 = "default";
    }
    //print(img64);
    http.Response res = await currentUser.setProfilePic(img64);
    Navigator.pushReplacementNamed(context, '/editProfile');
  }
}
