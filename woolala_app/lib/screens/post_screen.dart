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

class PostScreen extends StatefulWidget {
  PostScreen();

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File _image;
  final picker = ImagePicker();
  String _text = "";
  TextEditingController _c;

  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String date = formatter.format(now);

  @override
  initState() {
    _c = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _image = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // backgroundColor: Colors.grey[800],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/imgup'),
          child: Icon(
            Icons.reply, // add custom icons also
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image),
            SizedBox(height: 20.0),
            TextField(textInputAction: TextInputAction.go, keyboardType: TextInputType.multiline, maxLines: null, decoration: new InputDecoration(hintText: "Enter a caption!", contentPadding: const EdgeInsets.all(20.0))),
            new Text(_text,
                style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            new Text(date),
          ],
        ),
      ),
      bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: Icon(Icons.chat_bubble_outline),
              onPressed: () => {
                showDialog(
                    child: new Dialog(
                      child: new Column(
                        children: <Widget>[
                          new TextField(
                            decoration:
                                new InputDecoration(hintText: "Update Info"),
                            controller: _c,
                          ),
                          new FlatButton(
                            child: new Text("Save"),
                            onPressed: () {
                              setState(() {
                                this._text = _c.text;
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                    context: context)
              },
            ),
            SizedBox(height: 100.0),
            // FloatingActionButton(
            //   child: Icon(Icons.check),
            //   onPressed: () => null,
            //   heroTag: null,
            // ),
            FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () => {
                createPost(123, "1234", date, _text, null, 123),
                Navigator.pushReplacementNamed(context, '/home')
              },
              heroTag: null,
            )
          ]),
    );
  }
}
