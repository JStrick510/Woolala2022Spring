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
import 'package:woolala_app/screens/post_screen.dart';
import 'package:intl/intl.dart';

class ImageUploadScreen extends StatefulWidget {
  ImageUploadScreen();

  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image = null;
  final picker = ImagePicker();
  bool selected = false;
  String _text = "";
  TextEditingController _c;

  static final DateTime now = DateTime.now().toLocal();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String date = formatter.format(now);

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          child: Icon(
            Icons.arrow_back_outlined, // add custom icons also
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () => {
              if (_image != null)
                Navigator.pushReplacementNamed(context, '/makepost',
                    arguments: _image)
            },
            child: Text("Next"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      body: Column(children: [
        _image == null ? Text('') : Image.file(_image),
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
      ]),
      bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: Icon(Icons.camera_enhance),
              onPressed: () => getImageCamera(),
              heroTag: null,
            ),
            SizedBox(height: 100.0),
            // FloatingActionButton(
            //   child: Icon(Icons.check),
            //   onPressed: () => null,
            //   heroTag: null,
            // ),
            FloatingActionButton(
              child: Icon(Icons.collections),
              onPressed: () => getImageGallery(),
              heroTag: null,
            )
          ]),
    );
  }
}
