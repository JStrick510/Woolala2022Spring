import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

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