import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'dart:io';
//import 'package:woolala_app/screens/login_screen.dart';
//import 'package:image_picker/image_picker.dart';
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
  List<Object> arguments;
  String _text = "";
  String _price = "";
  String _cat = "";
  TextEditingController _c;
  TextEditingController _d;
  String _a = "";
  //String img64;
  List<File> images;
  List<String> encodes;

  String dropdownvalue = 'Apparel';
  var items = [
    "Apparel",
    "Shoes",
    "Accessories",
    "Crafts",
    "Designs",
    "Home",
    "Others"
  ];

  static final DateTime now = DateTime.now().toLocal();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String date = formatter.format(now);

  @override
  initState() {
    _c = new TextEditingController();
    _d = new TextEditingController();
    _a = "Apparel";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context).settings.arguments;

    images = arguments[0];
    encodes = arguments[1];

    _image = images[0];
    //img64 = arguments[1];
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
              //maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
              //maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: new InputDecoration(
                  hintText: "Enter a target price!",
                  contentPadding: const EdgeInsets.all(20.0)),
              controller: _d,
            ),
            SizedBox(height: 20.0),
            Text("Enter Category of Post:"),

            DropdownButton(

              // Initial Value
              value: dropdownvalue,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String newValue) {
                setState(() {
                  dropdownvalue = newValue;
                  _a = newValue;
                });
              },
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
                  this._cat = _a;
                }),
                print(_text),
                createPost(currentUser.userID + ":::" + getNewID(), encodes[0],
                    encodes[1], encodes[2], encodes[3], encodes[4], date,
                    _text, currentUser.userID, currentUser.profileName, _price, _cat),
                Navigator.pop(context),
                Navigator.pushReplacementNamed(context, '/home'),
              },
            ),
            SizedBox(height: 100.0, width: 20),
          ]),
    );
  }
}
