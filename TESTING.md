# Unit Testing Guide

## Overview

Unit tests have been added for the watch face logic functions. Tests are focused on pure logic functions (calculations, conversions) and do not test drawing functions.

## Test Structure

### Files Created

- `source/WatchLogic.mc` - Pure logic functions extracted from drawing code
- `source/TestFramework.mc` - Simple testing framework for Monkey C
- `source/WatchLogicTests.mc` - Unit tests for all logic functions
- `source/TestRunner.mc` - Test runner application

### What's Tested

1. **Mathematical Functions**
   - `polarToX()` - Convert polar coordinates to X coordinate
   - `polarToY()` - Convert polar coordinates to Y coordinate

2. **Time/Angle Calculations**
   - `calculateHourAngle()` - Hour hand angle calculation
   - `calculateMinuteAngle()` - Minute hand angle calculation
   - `calculateSecondAngle()` - Second hand angle calculation

3. **Battery Logic**
   - `calculateBatteryAngle()` - Battery level to angle conversion
   - `getBatteryColor()` - Battery level to color mapping (classic)
   - `getBatteryColorModern()` - Battery level to color mapping (modern)
   - `shouldShowBatteryPercent()` - Whether to display battery percentage

## Running Tests

### Option 1: Using Simulator Console (Recommended)

1. Build and run your watch face in the Garmin simulator
2. Add this to your `my_watchApp.mc` `initialize()` method (debug mode):
   ```monkey-c
   if (DEBUG) {
     runTests();
   }
   ```
3. Check the simulator console output for test results

### Option 2: Temporary Test App

1. Modify `manifest.xml` to change the entry point:
   ```xml
   <iq:application entry="TestRunnerApp" ...>
   ```
2. Build and run in simulator
3. Check console output for test results
4. **Don't forget to change it back to `my_watchApp`!**

### Option 3: Call from Initialization

Add to `my_watchApp.mc`:
```monkey-c
function initialize() {
  Application.AppBase.initialize();
  runTests(); // Call this to run tests
}
```

## Test Results Format

```
========== WatchLogic Tests ==========

[PASS] polarToX - 0 degrees (top)
[PASS] polarToX - 90 degrees (right)
[FAIL] someTest - Expected: 90, Got: 89.5

========== Test Summary ==========
Tests passed: 45
Tests failed: 1
Total: 46
==================================
```

## Code Changes Made

Minimal changes were made to existing code:
- Created `WatchLogic.mc` with pure logic functions
- Updated `modernWatchDrawer.mc` to use `WatchLogic` functions
- Original logic preserved, now testable

## Adding New Tests

To add tests for new functions:

1. Add the logic function to `WatchLogic.mc`
2. Add test method to `WatchLogicTests.mc`:
   ```monkey-c
   function testNewFunction() as Void {
     framework.runTest("Test name", method(:testNewFunction_case1));
   }

   function testNewFunction_case1() as Void {
     var result = WatchLogic.newFunction(input);
     framework.assertEqual(result, expected, "Error message");
   }
   ```
3. Call the test method in `runAllTests()`

## Assertions Available

- `assertEqual(actual, expected, message)` - Exact equality
- `assertApproxEqual(actual, expected, tolerance, message)` - Floating point comparison
- `assertTrue(condition, message)` - Boolean true check
- `assertFalse(condition, message)` - Boolean false check

## Notes

- Tests run in the Garmin simulator environment
- Drawing functions are not unit tested (require visual validation)
- Focus is on testable logic and calculations
- All angle calculations are in degrees (0 = top, 90 = right)
