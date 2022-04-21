import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/login_screen.dart';
//import 'dart:io';
//import 'dart:convert';
//import 'package:woolala_app/main.dart';

class CreateUserName extends StatefulWidget {
  final String currentOnlineUserId;
  CreateUserName({this.currentOnlineUserId});

  @override
  _CreateUserNameState createState() => _CreateUserNameState();
}

class _CreateUserNameState extends State<CreateUserName> {
  TextEditingController userNameController = TextEditingController();
  bool loading = false;
  bool _userNameValid = false;
  bool _badUsername = false;
  bool _takenUsername = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _textinputGlobalKey = GlobalKey();

  void initState() {
    super.initState();
  }

  updateUserInfo() async {
    _badUsername = false;
    _takenUsername = false;
    setState(() {
      userNameController.text.isEmpty ||
              userNameController.text.trim().length > 30
          ? _userNameValid = false
          : _userNameValid = true;
    });
    String nameToSend = userNameController.text.trim();
    if (nameToSend.contains(new RegExp('[^a-zA-Z0-9_]'))) {
      setState(() {
        _userNameValid = false;
        _badUsername = true;
      });
    } else {
      http.Response res = await User.isUserNameTaken(nameToSend);
      // print(res.body.toString());
      if (res.body.isEmpty) {
        setState(() {
          _userNameValid = true;
          _takenUsername = false;
          _badUsername = false;
        });
      } else {
        setState(() {
          _userNameValid = false;
          _takenUsername = true;
        });
      }
    }
    if (_userNameValid) {
      //print("update user info on server");
      currentUser.setUserName(userNameController.text.trim());
      SnackBar successSB = SnackBar(
        content: Text("User Name Updated Successfully"),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSB);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (_badUsername) {
        SnackBar failedSB = SnackBar(
          content: Text(
              "Invalid Characters in Username. Must be letters or numbers only"),
        );
        _scaffoldGlobalKey.currentState.showSnackBar(failedSB);
      } else if (_takenUsername) {
        SnackBar failedSB = SnackBar(
          content: Text("Username already taken. Try again."),
        );
        _scaffoldGlobalKey.currentState.showSnackBar(failedSB);
      } else {
        SnackBar failedSB = SnackBar(
          content:
              Text("Invalid Characters in Username or it is already taken"),
        );
        _scaffoldGlobalKey.currentState.showSnackBar(failedSB);
      }
    }
    _textinputGlobalKey.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldGlobalKey,
      child: Scaffold(
          // key: _scaffoldGlobalKey,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.blue),
            title: Text(
              'Create User Name',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.done,
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
                            onTap: () => {print("Change pic from gallery")},
                            child: currentUser.createProfileAvatar())
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          createUserNameTextFormField(),
                          createPrivacySwitch(),
                          createUserTypeSwitch(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Column createUserNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "User Name: @YourName",
            style: TextStyle(color: Colors.black),
          ),
        ),
        Form(
          key: _textinputGlobalKey,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            controller: userNameController,
            decoration: InputDecoration(
              hintText: "Enter a unique user name here",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              // errorText:
              //     _userNameValid ? null : "User Name is invalid or already taken",
            ),
            validator: (val) {
              if (val != null) {
                if (_badUsername)
                  return "Username must only be letters and/or numbers only";
                else if (_takenUsername) return "Username is already taken";
                return "User Name is invalid or already taken";
              }
              return null;
            },
          ),
        )
      ],
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
}
