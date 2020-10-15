import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage_screen.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class LoginScreen extends StatelessWidget {
  GoogleSignIn googleSignIn = GoogleSignIn(clientId: "566232493002-qqkorq4nvfqu9o8es6relg6fe4mj01mm.apps.googleusercontent.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.purple[900],
                Colors.purple[800],
                Colors.purple[600]
              ]
          ),
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('./assets/logos/w_logo_test.png', width: 350, height: 200, fit: BoxFit.contain, semanticLabel: 'WooLaLa logo'),
              Text("Powered by: ", style: TextStyle(color: Colors.white, fontSize: 16),),
              Image.asset('assets/logos/fashionNXT_logo.png', width: 150, height: 30, fit: BoxFit.contain, semanticLabel: 'FashioNXT logo'),
              SizedBox(height: 25,),
              Text("Login With:", style: TextStyle(color: Colors.white, fontSize: 24),),
              _buildSocialButtonRow()
            ],
          ),
      ),
     ),
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0, width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 20.0,),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtonRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(startFacebookSignIn, AssetImage('assets/logos/facebook_logo.png',),),
          _buildSocialBtn(startGoogleSignIn, AssetImage('assets/logos/google_logo.png',),),
        ],
      ),
    );
  }

  void startGoogleSignIn() async {
    GoogleSignInAccount user = await googleSignIn.signIn();
    if (user == null) {
      print("Sign in failed.");
      SnackBar googleSnackBar = SnackBar(content: Text("Sign in failed."));
      _scaffoldKey.currentState.showSnackBar(googleSnackBar);
    }
    else {
      print(user);
      SnackBar googleSnackBar = SnackBar(content: Text("Welcome ${user.displayName}!"));
      _scaffoldKey.currentState.showSnackBar(googleSnackBar);
      Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(builder: (context) => HomepageScreen()));
    }
  }




  void startFacebookSignIn() async {
    FacebookLogin facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;

        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
        final profile = json.decode(graphResponse.body);
        print(profile);
        SnackBar googleSnackBar = SnackBar(content: Text("Welcome ${profile["name"]}!"));
        _scaffoldKey.currentState.showSnackBar(googleSnackBar);

        Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(builder: (context) => HomepageScreen()));

        // final credential = FacebookAuthProvider.getCredential(accessToken: token);
        // final graphResponse = away http:get()
        // _showLoggedInUI();
        break;
      case FacebookLoginStatus.cancelledByUser:
        // _showCancelledMessage();
        print("Sign in failed.");
        SnackBar googleSnackBar = SnackBar(content: Text("Sign in failed."));
        _scaffoldKey.currentState.showSnackBar(googleSnackBar);
        break;
      case FacebookLoginStatus.error:
        // _showErrorOnUI(result.errorMessage);
        print("Sign in failed.");
        SnackBar googleSnackBar = SnackBar(content: Text("Sign in failed."));
        _scaffoldKey.currentState.showSnackBar(googleSnackBar);

        break;
    }
  }
}
