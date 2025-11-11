import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

// Unit tests for WatchLogic class
class WatchLogicTests {
  var framework as TestFramework;

  function initialize() {
    framework = new TestFramework();
  }

  function runAllTests() as Void {
    System.println("\n========== WatchLogic Tests ==========\n");

    // Mathematical functions tests
    testPolarToX();
    testPolarToY();

    // Time/angle calculation tests
    testHourAngle();
    testMinuteAngle();
    testSecondAngle();

    // Battery logic tests
    testBatteryAngle();
    testBatteryColor();
    testBatteryColorModern();
    testShouldShowBatteryPercent();

    framework.printSummary();
  }

  // ========== Mathematical Functions Tests ==========

  function testPolarToX() as Void {
    framework.runTest("polarToX - 0 degrees (top)", method(:testPolarToX_0deg));
    framework.runTest("polarToX - 90 degrees (right)", method(:testPolarToX_90deg));
    framework.runTest("polarToX - 180 degrees (bottom)", method(:testPolarToX_180deg));
    framework.runTest("polarToX - 270 degrees (left)", method(:testPolarToX_270deg));
  }

  function testPolarToX_0deg() as Void {
    var result = WatchLogic.polarToX(0, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 120.0, 0.1, "0 degrees should be at center X");
  }

  function testPolarToX_90deg() as Void {
    var result = WatchLogic.polarToX(90, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 220.0, 0.1, "90 degrees should be 100 pixels right");
  }

  function testPolarToX_180deg() as Void {
    var result = WatchLogic.polarToX(180, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 120.0, 0.1, "180 degrees should be at center X");
  }

  function testPolarToX_270deg() as Void {
    var result = WatchLogic.polarToX(270, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 20.0, 0.1, "270 degrees should be 100 pixels left");
  }

  function testPolarToY() as Void {
    framework.runTest("polarToY - 0 degrees (top)", method(:testPolarToY_0deg));
    framework.runTest("polarToY - 90 degrees (right)", method(:testPolarToY_90deg));
    framework.runTest("polarToY - 180 degrees (bottom)", method(:testPolarToY_180deg));
    framework.runTest("polarToY - 270 degrees (left)", method(:testPolarToY_270deg));
  }

  function testPolarToY_0deg() as Void {
    var result = WatchLogic.polarToY(0, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 20.0, 0.1, "0 degrees should be 100 pixels up");
  }

  function testPolarToY_90deg() as Void {
    var result = WatchLogic.polarToY(90, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 120.0, 0.1, "90 degrees should be at center Y");
  }

  function testPolarToY_180deg() as Void {
    var result = WatchLogic.polarToY(180, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 220.0, 0.1, "180 degrees should be 100 pixels down");
  }

  function testPolarToY_270deg() as Void {
    var result = WatchLogic.polarToY(270, 100, 120);
    framework.assertApproxEqual(result.toFloat(), 120.0, 0.1, "270 degrees should be at center Y");
  }

  // ========== Time/Angle Calculation Tests ==========

  function testHourAngle() as Void {
    framework.runTest("Hour angle - 12:00", method(:testHourAngle_12_00));
    framework.runTest("Hour angle - 3:00", method(:testHourAngle_3_00));
    framework.runTest("Hour angle - 6:00", method(:testHourAngle_6_00));
    framework.runTest("Hour angle - 9:00", method(:testHourAngle_9_00));
    framework.runTest("Hour angle - 12:30", method(:testHourAngle_12_30));
    framework.runTest("Hour angle - 3:15", method(:testHourAngle_3_15));
  }

  function testHourAngle_12_00() as Void {
    var angle = WatchLogic.calculateHourAngle(12, 0);
    framework.assertApproxEqual(angle.toFloat(), 0.0, 0.1, "12:00 should be 0 degrees");
  }

  function testHourAngle_3_00() as Void {
    var angle = WatchLogic.calculateHourAngle(3, 0);
    framework.assertApproxEqual(angle.toFloat(), 90.0, 0.1, "3:00 should be 90 degrees");
  }

  function testHourAngle_6_00() as Void {
    var angle = WatchLogic.calculateHourAngle(6, 0);
    framework.assertApproxEqual(angle.toFloat(), 180.0, 0.1, "6:00 should be 180 degrees");
  }

  function testHourAngle_9_00() as Void {
    var angle = WatchLogic.calculateHourAngle(9, 0);
    framework.assertApproxEqual(angle.toFloat(), 270.0, 0.1, "9:00 should be 270 degrees");
  }

  function testHourAngle_12_30() as Void {
    var angle = WatchLogic.calculateHourAngle(12, 30);
    framework.assertApproxEqual(angle.toFloat(), 15.0, 0.1, "12:30 should be 15 degrees");
  }

  function testHourAngle_3_15() as Void {
    var angle = WatchLogic.calculateHourAngle(3, 15);
    framework.assertApproxEqual(angle.toFloat(), 97.5, 0.1, "3:15 should be 97.5 degrees");
  }

  function testMinuteAngle() as Void {
    framework.runTest("Minute angle - 0:00", method(:testMinuteAngle_0));
    framework.runTest("Minute angle - 15:00", method(:testMinuteAngle_15));
    framework.runTest("Minute angle - 30:00", method(:testMinuteAngle_30));
    framework.runTest("Minute angle - 45:00", method(:testMinuteAngle_45));
    framework.runTest("Minute angle - 30:30", method(:testMinuteAngle_30_30));
  }

  function testMinuteAngle_0() as Void {
    var angle = WatchLogic.calculateMinuteAngle(0, 0);
    framework.assertApproxEqual(angle.toFloat(), 0.0, 0.1, "0:00 should be 0 degrees");
  }

  function testMinuteAngle_15() as Void {
    var angle = WatchLogic.calculateMinuteAngle(15, 0);
    framework.assertApproxEqual(angle.toFloat(), 90.0, 0.1, "15:00 should be 90 degrees");
  }

  function testMinuteAngle_30() as Void {
    var angle = WatchLogic.calculateMinuteAngle(30, 0);
    framework.assertApproxEqual(angle.toFloat(), 180.0, 0.1, "30:00 should be 180 degrees");
  }

  function testMinuteAngle_45() as Void {
    var angle = WatchLogic.calculateMinuteAngle(45, 0);
    framework.assertApproxEqual(angle.toFloat(), 270.0, 0.1, "45:00 should be 270 degrees");
  }

  function testMinuteAngle_30_30() as Void {
    var angle = WatchLogic.calculateMinuteAngle(30, 30);
    framework.assertApproxEqual(angle.toFloat(), 183.0, 0.1, "30:30 should be 183 degrees");
  }

  function testSecondAngle() as Void {
    framework.runTest("Second angle - 0", method(:testSecondAngle_0));
    framework.runTest("Second angle - 15", method(:testSecondAngle_15));
    framework.runTest("Second angle - 30", method(:testSecondAngle_30));
    framework.runTest("Second angle - 45", method(:testSecondAngle_45));
  }

  function testSecondAngle_0() as Void {
    var angle = WatchLogic.calculateSecondAngle(0);
    framework.assertEqual(angle, 0, "0 seconds should be 0 degrees");
  }

  function testSecondAngle_15() as Void {
    var angle = WatchLogic.calculateSecondAngle(15);
    framework.assertEqual(angle, 90, "15 seconds should be 90 degrees");
  }

  function testSecondAngle_30() as Void {
    var angle = WatchLogic.calculateSecondAngle(30);
    framework.assertEqual(angle, 180, "30 seconds should be 180 degrees");
  }

  function testSecondAngle_45() as Void {
    var angle = WatchLogic.calculateSecondAngle(45);
    framework.assertEqual(angle, 270, "45 seconds should be 270 degrees");
  }

  // ========== Battery Logic Tests ==========

  function testBatteryAngle() as Void {
    framework.runTest("Battery angle - 0%", method(:testBatteryAngle_0));
    framework.runTest("Battery angle - 25%", method(:testBatteryAngle_25));
    framework.runTest("Battery angle - 50%", method(:testBatteryAngle_50));
    framework.runTest("Battery angle - 100%", method(:testBatteryAngle_100));
  }

  function testBatteryAngle_0() as Void {
    var angle = WatchLogic.calculateBatteryAngle(0.0);
    framework.assertApproxEqual(angle.toFloat(), 0.0, 0.1, "0% should be 0 degrees");
  }

  function testBatteryAngle_25() as Void {
    var angle = WatchLogic.calculateBatteryAngle(25.0);
    framework.assertApproxEqual(angle.toFloat(), 90.0, 0.1, "25% should be 90 degrees");
  }

  function testBatteryAngle_50() as Void {
    var angle = WatchLogic.calculateBatteryAngle(50.0);
    framework.assertApproxEqual(angle.toFloat(), 180.0, 0.1, "50% should be 180 degrees");
  }

  function testBatteryAngle_100() as Void {
    var angle = WatchLogic.calculateBatteryAngle(100.0);
    framework.assertApproxEqual(angle.toFloat(), 360.0, 0.1, "100% should be 360 degrees");
  }

  function testBatteryColor() as Void {
    framework.runTest("Battery color - 5%", method(:testBatteryColor_5));
    framework.runTest("Battery color - 15%", method(:testBatteryColor_15));
    framework.runTest("Battery color - 50%", method(:testBatteryColor_50));
  }

  function testBatteryColor_5() as Void {
    var color = WatchLogic.getBatteryColor(5.0);
    framework.assertEqual(color, Graphics.COLOR_RED, "5% should be RED");
  }

  function testBatteryColor_15() as Void {
    var color = WatchLogic.getBatteryColor(15.0);
    framework.assertEqual(color, Graphics.COLOR_YELLOW, "15% should be YELLOW");
  }

  function testBatteryColor_50() as Void {
    var color = WatchLogic.getBatteryColor(50.0);
    framework.assertEqual(color, Graphics.COLOR_GREEN, "50% should be GREEN");
  }

  function testBatteryColorModern() as Void {
    framework.runTest("Battery color modern - 15%", method(:testBatteryColorModern_15));
    framework.runTest("Battery color modern - 25%", method(:testBatteryColorModern_25));
    framework.runTest("Battery color modern - 50%", method(:testBatteryColorModern_50));
  }

  function testBatteryColorModern_15() as Void {
    var color = WatchLogic.getBatteryColorModern(15.0);
    framework.assertEqual(color, Graphics.COLOR_RED, "15% should be RED");
  }

  function testBatteryColorModern_25() as Void {
    var color = WatchLogic.getBatteryColorModern(25.0);
    framework.assertEqual(color, Graphics.COLOR_YELLOW, "25% should be YELLOW");
  }

  function testBatteryColorModern_50() as Void {
    var color = WatchLogic.getBatteryColorModern(50.0);
    framework.assertEqual(color, Graphics.COLOR_GREEN, "50% should be GREEN");
  }

  function testShouldShowBatteryPercent() as Void {
    framework.runTest("Show battery - 30%", method(:testShouldShowBatteryPercent_30));
    framework.runTest("Show battery - 40%", method(:testShouldShowBatteryPercent_40));
    framework.runTest("Show battery - 50%", method(:testShouldShowBatteryPercent_50));
  }

  function testShouldShowBatteryPercent_30() as Void {
    var result = WatchLogic.shouldShowBatteryPercent(30.0);
    framework.assertTrue(result, "30% should show battery percent");
  }

  function testShouldShowBatteryPercent_40() as Void {
    var result = WatchLogic.shouldShowBatteryPercent(40.0);
    framework.assertTrue(result, "40% should show battery percent");
  }

  function testShouldShowBatteryPercent_50() as Void {
    var result = WatchLogic.shouldShowBatteryPercent(50.0);
    framework.assertFalse(result, "50% should NOT show battery percent");
  }
}
