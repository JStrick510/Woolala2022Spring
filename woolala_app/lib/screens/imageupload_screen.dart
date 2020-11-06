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
import 'dart:io' as Io;

class ImageUploadScreen extends StatefulWidget {
  ImageUploadScreen();

  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image = null;
  String img64;
  final picker = ImagePicker();
  bool selected = false;

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        final bytes = _image.readAsBytesSync();
        img64 = base64Encode(bytes);
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
            Icons.reply, // add custom icons also
          ),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () => {
              if (_image != null)
                Navigator.pushReplacementNamed(context, '/makepost',
                    arguments: [_image, img64])
            },
            child: Text("Next"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      body: Column(children: [
        _image == null ? Text('') : Image.file(_image),
      ]),
      bottomNavigationBar: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: Icon(Icons.camera_enhance),
              key: ValueKey("Camera"),
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
              key: ValueKey("Gallery"),
              onPressed: () => getImageGallery(),
              heroTag: null,
            )
          ]),
    );
  }
}
