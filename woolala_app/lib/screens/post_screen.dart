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


String getNewID()
{
  final DateTime timeID = DateTime.now().toLocal();
  final DateFormat formatterID = DateFormat('yyyyMMddHHmm');
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
  TextEditingController _c;
  String img64;

  static final DateTime now = DateTime.now().toLocal();
  static final DateFormat formatter = DateFormat('MM-dd-yyyy');
  final String date = formatter.format(now);

  @override
  initState() {
    _c = new TextEditingController();
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
            _image == null ? Text('No image selected.') : Image.file(_image),
            SizedBox(height: 20.0),
            TextField(maxLength: 69, maxLengthEnforced: true, textInputAction: TextInputAction.go, keyboardType: TextInputType.multiline, maxLines: null, decoration: new InputDecoration(hintText: "Enter a caption!", contentPadding: const EdgeInsets.all(20.0)), controller: _c,),
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
              }),
                print(_text),
                createPost(currentUser.userID + ":::" + getNewID() , img64, date, _text, currentUser.userID, currentUser.profileName),
                Navigator.pushReplacementNamed(context, '/home')
              },
            ),
            SizedBox(height: 100.0, width: 20),
          ]),
    );
  }
}
