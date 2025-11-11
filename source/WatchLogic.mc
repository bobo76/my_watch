import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

// Pure logic functions for watch calculations
// These functions contain no drawing code and can be easily tested
class WatchLogic {

  // Calculate hour hand angle in degrees (0-360)
  // hour: 0-23, min: 0-59
  static function calculateHourAngle(hour as Number, min as Number) as Float {
    return ((hour % 12) + min / 60.0) * 30;
  }

  // Calculate minute hand angle in degrees (0-360)
  // min: 0-59, sec: 0-59
  static function calculateMinuteAngle(min as Number, sec as Number) as Float {
    return min * 6 + sec / 10.0;
  }

  // Calculate second hand angle in degrees (0-360)
  // sec: 0-59
  static function calculateSecondAngle(sec as Number) as Number {
    return sec * 6;
  }

  // Calculate battery arc angle in degrees (0-360)
  // battery: 0-100 (percentage)
  static function calculateBatteryAngle(battery as Float) as Float {
    return (battery / 100.0) * 360;
  }

  // Get battery color based on level
  // Returns color constant: RED, YELLOW, or GREEN
  static function getBatteryColor(battery as Float) as Number {
    if (battery <= 10) {
      return Graphics.COLOR_RED;
    } else if (battery <= 20) {
      return Graphics.COLOR_YELLOW;
    } else {
      return Graphics.COLOR_GREEN;
    }
  }

  // Get battery color for modern drawer (different thresholds)
  static function getBatteryColorModern(battery as Float) as Number {
    if (battery <= 20) {
      return Graphics.COLOR_RED;
    } else if (battery <= 30) {
      return Graphics.COLOR_YELLOW;
    } else {
      return Graphics.COLOR_GREEN;
    }
  }

  // Convert polar coordinates (angle in degrees, distance) to X coordinate
  // angleDeg: angle in degrees (0 = top, 90 = right)
  // dist: distance from center
  // cx: center X coordinate
  static function polarToX(angleDeg as Number, dist as Number, cx as Number) as Float {
    var rad = Math.toRadians(angleDeg);
    return cx + Math.sin(rad) * dist;
  }

  // Convert polar coordinates (angle in degrees, distance) to Y coordinate
  // angleDeg: angle in degrees (0 = top, 90 = right)
  // dist: distance from center
  // cy: center Y coordinate
  static function polarToY(angleDeg as Number, dist as Number, cy as Number) as Float {
    var rad = Math.toRadians(angleDeg);
    return cy - Math.cos(rad) * dist;
  }

  // Check if battery should be displayed as warning
  // Returns true if battery is low enough to show percentage
  static function shouldShowBatteryPercent(battery as Float) as Boolean {
    return battery <= 40;
  }
}
