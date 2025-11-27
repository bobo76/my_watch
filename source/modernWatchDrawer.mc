import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class ModernWatchDrawer {
  // Layout constants
  var batteryArcWidth as Number = 10;
  var w as Number = 0;
  var h as Number = 0;
  var cx as Number = 0;
  var cy as Number = 0;
  var maxRadius as Number = 0;
  var backgroundColor as Number = 0x000055;
  var dataFont as Graphics.FontDefinition = Graphics.FONT_TINY;

  // Color constants
  var darkNavyBlue as Number = 0x000022; // Dark Navy Blue
  var darkOrange as Number = 0xcc6600; // Dark Orange
  var navyBlue as Number = 0x000055; // Navy Blue
  var darkMediumBlue as Number = 0x000066; // Dark Medium Blue (was octal, now hex)

  // Drawing constants
  const TICK_RADIUS_RATIO = 0.66;
  const HOUR_HAND_LENGTH_RATIO = 0.55;
  const MINUTE_HAND_LENGTH_RATIO = 0.75;
  const SECOND_HAND_LENGTH_RATIO = 0.85;
  const SECOND_HAND_BACK_LENGTH = 15;
  const HOUR_HAND_WIDTH = 5;
  const MINUTE_HAND_WIDTH = 3;
  const SECOND_HAND_WIDTH = 2;

  // Cached system values (updated each frame)
  var cachedBattery as Float = 100.0;
  var cachedTime as System.ClockTime?;

  function initializeContext(dc as Dc) as Void {
    backgroundColor = navyBlue;
    dataFont = Gfx.FONT_TINY;
    dc.setColor(backgroundColor, backgroundColor);
    dc.clear();
    dc.setAntiAlias(true);

    w = dc.getWidth();
    h = dc.getHeight();
    cx = w / 2;
    cy = h / 2;
    maxRadius = (w < h ? w : h) / 2;

    // Cache system values to avoid repeated expensive calls
    cachedBattery = System.getSystemStats().battery;
    cachedTime = System.getClockTime();
  }

  function drawBatteryPercent(dc as Dc) as Void {
    if (!WatchLogic.shouldShowBatteryPercent(cachedBattery)) {
      return;
    }
    var batteryText = cachedBattery.format("%.0f") + " %";
    var percentWidth = dc.getTextDimensions(batteryText, dataFont)[0];
    dc.setColor(Gfx.COLOR_LT_GRAY, backgroundColor);

    dc.drawText(
      cx - percentWidth / 2,
      (cy / 3) * 2,
      dataFont,
      batteryText,
      Gfx.TEXT_JUSTIFY_LEFT
    );
  }

  function drawDateWithBackground(dc as Dc) as Void {
    var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_MEDIUM);
    var theDate = info.day_of_week + " " + info.day.toString();
    var dateWidth = dc.getTextDimensions(theDate, dataFont)[0];
    var fontHeight = dc.getTextDimensions("31", dataFont)[1];
    var cornerX = cx - dateWidth / 2;
    var cornerY = cy + 25;

    dc.setColor(Gfx.COLOR_LT_GRAY, backgroundColor);
    dc.fillRoundedRectangle(
      cornerX - 4,
      cornerY + 1,
      dateWidth + 6,
      fontHeight - 1,
      4
    );
    dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cornerX, cornerY, dataFont, theDate, Gfx.TEXT_JUSTIFY_LEFT);
  }

  function drawTicker(dc as Dc) as Void {
    var radius = (maxRadius * TICK_RADIUS_RATIO).toNumber() + 2;
    var batteryAngle = WatchLogic.calculateBatteryAngle(cachedBattery);
    var batteryColor = WatchLogic.getBatteryColorModern(cachedBattery);

    // Draw 60 tick marks
    for (var i = 0; i < 60; i += 1) {
      var degre = ((i / 60.0) * 360).toNumber();
      var isHour = i % 5 == 0;
      var innerR = radius - 9;
      var endR = isHour ? radius + 6 : radius;
      var squareBegin = endR + 8;
      var squareEnd = squareBegin + 14;

      if (degre <= batteryAngle) {
        dc.setColor(batteryColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
      } else {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
      }

      drawAngleLine(degre, innerR, endR, dc);

      if (isHour && i % 15 != 0) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        drawAngleRectangle(degre, squareBegin, squareEnd, 6, dc);
      }
    }
  }

  function drawHours(dc as Dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    // Array of (text, angle, x offset, y offset)
    var fontMidH = dc.getTextDimensions("6", Gfx.FONT_LARGE)[1] / 2;
    var markers = [
      ["12", 0, 0, fontMidH],
      ["3", 90, fontMidH, 0],
      ["6", 180, 0, fontMidH],
      ["9", 270, fontMidH, 0],
    ];

    for (var i = 0; i < markers.size(); i += 1) {
      var label = markers[i][0];
      var angleDeg = markers[i][1];
      var x = centerToX(angleDeg, maxRadius - markers[i][2].toNumber());
      var y =
        centerToY(angleDeg, maxRadius - markers[i][3].toNumber()) - fontMidH;
      dc.drawText(x, y, Gfx.FONT_LARGE, label, Gfx.TEXT_JUSTIFY_CENTER);
    }
  }

  function drawHourHands(dc as Dc) as Void {
    var hourAngle = WatchLogic.calculateHourAngle(
      cachedTime.hour,
      cachedTime.min
    );
    var hourLen = (maxRadius * HOUR_HAND_LENGTH_RATIO).toNumber();

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    drawAngleRectangle(hourAngle, 0, hourLen, HOUR_HAND_WIDTH, dc);
  }

  function drawMinuteHands(dc as Dc) as Void {
    var minuteAngle = WatchLogic.calculateMinuteAngle(
      cachedTime.min,
      cachedTime.sec
    );
    var minuteLen = (maxRadius * MINUTE_HAND_LENGTH_RATIO).toNumber();

    dc.setPenWidth(MINUTE_HAND_WIDTH);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      cy,
      centerToX(minuteAngle, minuteLen),
      centerToY(minuteAngle, minuteLen)
    );
  }

  function drawSecondHands(dc as Dc) as Void {
    var secondLen = (maxRadius * SECOND_HAND_LENGTH_RATIO).toNumber();
    var secondAngle = WatchLogic.calculateSecondAngle(cachedTime.sec);

    // Start point (behind center)
    var x1 = centerToX(secondAngle, -SECOND_HAND_BACK_LENGTH);
    var y1 = centerToY(secondAngle, -SECOND_HAND_BACK_LENGTH);

    // End point
    var x2 = centerToX(secondAngle, secondLen);
    var y2 = centerToY(secondAngle, secondLen);

    dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(SECOND_HAND_WIDTH);
    dc.drawLine(x1, y1, x2, y2);
  }

  function drawCenterCircle(dc as Dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.fillCircle(cx, cy, 4);

    dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.drawCircle(cx, cy, 6);
  }

  private function centerToX(angleDeg as Number, dist as Number) as Float {
    var rad = Math.toRadians(angleDeg);
    return cx + Math.sin(rad) * dist;
  }

  private function centerToY(angleDeg as Number, dist as Number) as Float {
    var rad = Math.toRadians(angleDeg);
    return cy - Math.cos(rad) * dist;
  }

  private function drawAngleLine(
    angle as Number,
    innerR as Integer,
    endR as Integer,
    dc as Dc
  ) as Void {
    var x1 = centerToX(angle, innerR);
    var y1 = centerToY(angle, innerR);
    var x2 = centerToX(angle, endR);
    var y2 = centerToY(angle, endR);

    dc.drawLine(x1, y1, x2, y2);
  }

  private function drawAngleRectangle(
    angle as Number,
    innerR as Integer,
    endR as Integer,
    width as Number,
    dc as Dc
  ) as Void {
    var halfWidth = width / 2.0;

    // Calculate perpendicular offset angle (in degrees)
    var perpAngleLeft = angle - 90;
    var perpAngleRight = angle + 90;

    // Calculate 4 corners of the rectangle
    var innerLeft = [
      centerToX(angle, innerR) +
        Math.sin(Math.toRadians(perpAngleLeft)) * halfWidth,
      centerToY(angle, innerR) -
        Math.cos(Math.toRadians(perpAngleLeft)) * halfWidth,
    ];

    var innerRight = [
      centerToX(angle, innerR) +
        Math.sin(Math.toRadians(perpAngleRight)) * halfWidth,
      centerToY(angle, innerR) -
        Math.cos(Math.toRadians(perpAngleRight)) * halfWidth,
    ];

    var outerRight = [
      centerToX(angle, endR) +
        Math.sin(Math.toRadians(perpAngleRight)) * halfWidth,
      centerToY(angle, endR) -
        Math.cos(Math.toRadians(perpAngleRight)) * halfWidth,
    ];

    var outerLeft = [
      centerToX(angle, endR) +
        Math.sin(Math.toRadians(perpAngleLeft)) * halfWidth,
      centerToY(angle, endR) -
        Math.cos(Math.toRadians(perpAngleLeft)) * halfWidth,
    ];

    // Draw filled rectangle
    dc.fillPolygon([innerLeft, innerRight, outerRight, outerLeft]);
  }
}
