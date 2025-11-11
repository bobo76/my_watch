import Toybox.Lang;
import Toybox.System;

// Custom test assertion error
class TestAssertionError extends Lang.Exception {
  var msg as String;

  function initialize(message as String) {
    Lang.Exception.initialize();
    msg = message;
  }
}

// Simple test framework for Monkey C
class TestFramework {
  var testsPassed as Number = 0;
  var testsFailed as Number = 0;
  var currentTestName as String = "";

  function runTest(testName as String, testFunc as Method) as Void {
    currentTestName = testName;
    try {
      testFunc.invoke();
      testsPassed++;
      System.println("[PASS] " + testName);
    } catch (ex) {
      testsFailed++;
      if (ex instanceof TestAssertionError) {
        System.println("[FAIL] " + testName + " - " + ex.msg);
      } else {
        System.println("[FAIL] " + testName + " - Unknown error");
      }
    }
  }

  function assertEqual(actual, expected, message as String) as Void {
    if (actual != expected) {
      var errMsg = message + " - Expected: " + expected + ", Got: " + actual;
      throw new TestAssertionError(errMsg);
    }
  }

  function assertApproxEqual(actual as Float, expected as Float, tolerance as Float, message as String) as Void {
    var diff = actual - expected;
    if (diff < 0) {
      diff = -diff;
    }
    if (diff > tolerance) {
      var errMsg = message + " - Expected: " + expected + " (±" + tolerance + "), Got: " + actual;
      throw new TestAssertionError(errMsg);
    }
  }

  function assertTrue(condition as Boolean, message as String) as Void {
    if (!condition) {
      throw new TestAssertionError(message);
    }
  }

  function assertFalse(condition as Boolean, message as String) as Void {
    if (condition) {
      throw new TestAssertionError(message);
    }
  }

  function printSummary() as Void {
    System.println("\n========== Test Summary ==========");
    System.println("Tests passed: " + testsPassed);
    System.println("Tests failed: " + testsFailed);
    System.println("Total: " + (testsPassed + testsFailed));
    if (testsFailed == 0) {
      System.println("All tests passed!");
    }
    System.println("==================================\n");
  }
}
