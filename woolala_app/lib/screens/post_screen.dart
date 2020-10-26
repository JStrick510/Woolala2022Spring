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


class PostScreen extends StatefulWidget {
  PostScreen();

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File _image;
  final picker = ImagePicker();


  @override
  Widget build(BuildContext context) {
    _image = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/imgup'),
            child: Icon(
              Icons.reply,  // add custom icons also
            ),
          ),
        ),
        body: Center(
          child: _image == null
              ? Text('No image selected.')
              : Image.file(_image),
        ),
        bottomNavigationBar: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    child: Icon(Icons.chat_bubble_outline),
                    onPressed: () => null,
                    heroTag: null,
                  ),
                  SizedBox(height: 100.0),
                  // FloatingActionButton(
                  //   child: Icon(Icons.check),
                  //   onPressed: () => null,
                  //   heroTag: null,
                  // ),
                  FloatingActionButton(
                    child: Icon(Icons.check),
                    onPressed: () => {createPost(123, "1234", "05/12/2345", "test", null, 123), Navigator.pushReplacementNamed(context, '/home')},
                    heroTag: null,
                  )
                ]
        ),

    );
  }
}
