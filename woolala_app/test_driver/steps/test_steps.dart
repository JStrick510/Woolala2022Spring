import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

StepDefinitionGeneric TapButtonNTimesStep() {
  return when2<String, int, FlutterWorld>(
    'I tap the {string} button {int} times',
        (key, count, context) async {
      final locator = find.byValueKey(key);
      for (var i = 0; i < count; i += 1) {
        await FlutterDriverUtils.tap(context.world.driver, locator);
      }
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


    },
  );
}