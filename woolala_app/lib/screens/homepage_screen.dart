import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:woolala_app/screens/login_screen.dart';

final GlobalKey<ScaffoldState> _scaffoldKeyHomepage = new GlobalKey<ScaffoldState>();

class HomepageScreen extends StatelessWidget {
  GoogleSignIn googleSignIn = GoogleSignIn(clientId: "566232493002-qqkorq4nvfqu9o8es6relg6fe4mj01mm.apps.googleusercontent.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Homepage'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: startSignOut,
            child: Text("Sign Out"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      key: _scaffoldKeyHomepage,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue[900],
                  Colors.blue[700],
                  Colors.blue[400]
                ]
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  void startSignOut() {
    print("Sign Out");
    googleSignIn.signOut();
    Navigator.push(_scaffoldKeyHomepage.currentContext, MaterialPageRoute(builder: (context) => LoginScreen()));

    //FACEBOOK HERE
  }

}
