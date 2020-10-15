import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

StepDefinitionGeneric TapIcons() {
  return when1<String, FlutterWorld>(
    'I tap the {string} icon',
        (key, context) async {
      // TODO:
      // key could be either google or facebook
      // need some code to check it really gets into the login page
      },
  );
}

StepDefinitionGeneric LoginAPIs() {
  return then1<String, FlutterWorld>(
    'I should see {string} log-in api',
        (key, context) async {
      // TODO:
      // key could be either google or facebook
      // need some code to check it really gets into the login page
    },
  );
}

StepDefinitionGeneric LoggedIn() {
  return when1<String, FlutterWorld>(
    'I pass the {string} authentication',
      (key, context) async {
      // TODO:
      // key could be either google or facebook
      // need some code to check whether the user has successfully logged in
      },
  );
}

StepDefinitionGeneric Homepage() {
  return then<FlutterWorld>(
    'I should have "homepage" on screen',
        (context) async {
      // TODO:
      // key could be either google or facebook
      // need some code to check it really gets into the login page
    },
  );
}

StepDefinitionGeneric Facebook() {
  return then<FlutterWorld>(
    'I should have "homepage" on screen',
        (context) async {
          FacebookLogin facebookLogin = FacebookLogin();
          final result = await facebookLogin.logIn(['email']);

          switch (result.status) {
            case FacebookLoginStatus.loggedIn:
              final token = result.accessToken.token;

              final graphResponse = await http.get(
                  'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
              final profile = json.decode(graphResponse.body);
              print(profile);
              print(profile["name"]);
              SnackBar googleSnackBar = SnackBar(content: Text("Welcome ${profile["name"]}!"));
              _scaffoldKey.currentState.showSnackBar(googleSnackBar);

              // final credential = FacebookAuthProvider.getCredential(accessToken: token);
              // final graphResponse = away http:get()
              // _showLoggedInUI();
              break;
            case FacebookLoginStatus.cancelledByUser:
            // _showCancelledMessage();
              print("Sign in failed.");
              break;
            case FacebookLoginStatus.error:
            // _showErrorOnUI(result.errorMessage);
              print("Sign in failed.");

              break;
          }
    },
  );
}