import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:woolala_app/screens/login_screen.dart';

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



class HomepageScreen extends StatefulWidget {
  final bool signedInWithGoogle;
  HomepageScreen(this.signedInWithGoogle);
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Homepage'),
        key: ValueKey("homepage"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () => startSignOut(context),
            child: Text("Sign Out"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
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
            children: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () {Navigator.pushReplacementNamed(context, '/profile');},
                child: Text("To Profile", style: TextStyle(fontSize: 16.0),),
              )
            ],
          ),
        ),
      ),
    );
  }

  void startSignOut(BuildContext context) {
    print("Sign Out");
    if(widget.signedInWithGoogle)
    {
      googleLogoutUser();
      Navigator.pushReplacementNamed(context, '/');
    }
    else
    {
        FacebookLogin facebookLogin = FacebookLogin();
        facebookLogin.logOut();
        Navigator.pushReplacementNamed(context, '/');
    }
  }

}