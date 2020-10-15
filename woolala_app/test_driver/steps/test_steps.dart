import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric tapLoginButton() {
  return when1<String, FlutterWorld>(
    'I tap the {string} button',
        (key, context) async {
      final locator = find.byValueKey(key);
      await FlutterDriverUtils.tap(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric appIsOpen() {
  return given1<String, FlutterWorld>(
    'The {string} is open',
        (key, context) async {

    },
  );
}

StepDefinitionGeneric iShouldSeeText() {
  return then1<String, FlutterWorld>(
    'I should see {string} on my screen',
        (key, context) async {

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

StepDefinitionGeneric onPage() {
  return given1<String, FlutterWorld>(
    'I am on the {string} screen',
        (key, context) async {

    },
  );
}
