import Toybox.Application;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application as App;

// Simple test runner
// To run tests, temporarily change the app entry point in manifest.xml to TestRunnerApp
// Or call runTests() from your app initialization in debug mode

class TestRunnerApp extends App.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state as Lang.Dictionary?) as Void {
    runTests();
  }

  function onStop(state as Lang.Dictionary?) as Void {
  }

  function getInitialView() {
    // Return empty view since we're just running tests
    return [new WatchUi.View()];
  }
}

function runTests() as Void {
  System.println("\n\n========================================");
  System.println("        Running Unit Tests");
  System.println("========================================\n");

  var tests = new WatchLogicTests();
  tests.runAllTests();

  System.println("\n========================================");
  System.println("        Tests Complete");
  System.println("========================================\n\n");
}
