import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';
import 'steps/test_steps.dart';

Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [Glob(r"test_driver/features/**.feature")]
    ..reporters = [
      ProgressReporter(),
      //TestRunSummaryReporter(),
      JsonReporter(path: './report.json')
    ] // you can include the "StdoutReporter()" without the message level parameter for verbose log information
    // ..hooks = [HookExample()]
    ..stepDefinitions = [
      loggedIn(),
      onPage(),
      iShouldSeeText(),
      accountIsValid(),
      tapTheButton(),
      isEdited(),
      iShouldSeeButton(),
      profileIsUpdated(),
      canUploadChosenImage()
    ]
    // ..customStepParameterDefinitions = [ColourParameter()]
    ..restartAppBetweenScenarios = true
    ..targetAppPath = "test_driver/app.dart"
    // ..tagExpression = "@smoke" // uncomment to see an example of running scenarios based on tag expressions
    ..exitAfterTestRun = true; // set to false if debugging to exit cleanly
  return GherkinRunner().execute(config);
}
