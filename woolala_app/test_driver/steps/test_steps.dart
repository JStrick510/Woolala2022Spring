import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric loggedIn() {
  return given<FlutterWorld>(
    'I am already logged in',
        (context) async {
      final locator = find.byValueKey("GoToHome");
      await FlutterDriverUtils.tap(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric onPage() {
  return given1<String, FlutterWorld>(
    'I am on the {string} screen',
        (key, context) async {


    },
  );
}

StepDefinitionGeneric iShouldSeeText() {
  return then1<String, FlutterWorld>(
    'I should see {string} on my screen',
        (key, context) async {
      final locator = find.byValueKey(key);
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric accountIsValid() {
  return given2<String, String, FlutterWorld>(
    'My {string} account is {string}',
        (key, validity, context) async {

    },
  );
}

StepDefinitionGeneric tapTheButton() {
  return when1<String, FlutterWorld>(
    'I tap the {string} button',
        (key, context) async {
      final locator = find.byValueKey(key);
      print(locator);
      await FlutterDriverUtils.tap(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric isEdited() {
  return when1<String, FlutterWorld>(
    '{string} is edited',
        (key, context) async {

    },
  );
}

StepDefinitionGeneric iShouldSeeButton() {
  return then1<String, FlutterWorld>(
    'I should see the {string} button',
        (key, context) async {
      final locator = find.byValueKey(key);
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric profileIsUpdated() {
  return and1<String, FlutterWorld>(
    '{string} is updated',
        (key, context) async {

    },
  );
}

StepDefinitionGeneric chooseAnImage() {
  return when1<String, FlutterWorld>(
    'I choose an image from {string}',
        (key, context) async {

    },
  );
}

StepDefinitionGeneric selectedImageOnScreen() {
  return and2<String, String, FlutterWorld>(
    'the {string} are on the {string} screen',
        (key1, key2, context) async {

    },
  );
}

