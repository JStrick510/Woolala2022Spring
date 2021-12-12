import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:intl/intl.dart';

String getNewID() {
  final DateTime timeID = DateTime.now().toLocal();
  final DateFormat formatterID = DateFormat('yyyyMMddHHmmss');
  return formatterID.format(timeID);
}

class PostScreen extends StatefulWidget {
  PostScreen();

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File _image;
  List<Object> test;
  String _text = "";
  String _price = "";
  TextEditingController _c;
  TextEditingController _d;
  String img64;

  static final DateTime now = DateTime.now().toLocal();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String date = formatter.format(now);

  @override
  initState() {
    _c = new TextEditingController();
    _d = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    test = ModalRoute.of(context).settings.arguments;
    _image = test[0];
    img64 = test[1];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // backgroundColor: Colors.grey[800],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/imgup'),
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: new FileImage(_image),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              maxLength: 280,
              maxLengthEnforced: true,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: new InputDecoration(
                  hintText: "Enter a caption!",
                  contentPadding: const EdgeInsets.all(20.0)),
              controller: _c,
            ),
            SizedBox(height: 20.0),
            TextField(
              maxLength: 280,
              maxLengthEnforced: true,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: new InputDecoration(
                  hintText: "Enter a target price!",
                  contentPadding: const EdgeInsets.all(20.0)),
              controller: _d,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 100.0),
            FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () => {
                setState(() {
                  this._text = _c.text;
                  this._price = _d.text;
                }),
                print(_text),
                // print(price_text),
                createPost(currentUser.userID + ":::" + getNewID(), img64, date,
                    _text, currentUser.userID, currentUser.profileName, _price),
                Navigator.pop(context),
                Navigator.pushReplacementNamed(context, '/home'),
              },
            ),
            SizedBox(height: 100.0, width: 20),
          ]),
    );
  }
}
