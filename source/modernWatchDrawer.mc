import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class ModernWatchDrawer {
  // Layout constants
  var w as Number = 0;
  var h as Number = 0;
  var cx as Number = 0;
  var cy as Number = 0;
  var maxRadius as Number = 0;
  var backgroundColor as Number = 0x000055;
  var dataFont as Graphics.FontDefinition = Graphics.FONT_TINY;

  // Drawing constants
  const TICK_RADIUS_RATIO = 0.66;
  const HOUR_HAND_LENGTH_RATIO = 0.55;
  const MINUTE_HAND_LENGTH_RATIO = 0.75;
  const SECOND_HAND_LENGTH_RATIO = 0.85;
  const SECOND_HAND_BACK_LENGTH = 15;
  const HOUR_HAND_WIDTH = 5;
  const MINUTE_HAND_WIDTH = 3;
  const SECOND_HAND_WIDTH = 2;

  // Tick mark geometry
  const TICK_INNER_OFFSET = 9;
  const TICK_HOUR_OUTER_OFFSET = 6;
  const TICK_SQUARE_GAP = 8;
  const TICK_SQUARE_LENGTH = 14;
  const TICK_SQUARE_WIDTH = 6;
  const TICK_BATTERY_PEN_WIDTH = 4;
  const TICK_NORMAL_PEN_WIDTH = 2;

  // Date display
  const DATE_OFFSET_Y = 25;
  const DATE_PADDING_X = 4;
  const DATE_PADDING_W = 6;
  const DATE_PADDING_TOP = 1;
  const DATE_CORNER_RADIUS = 4;

  // Center circle
  const CENTER_DOT_RADIUS = 4;
  const CENTER_RING_RADIUS = 6;

  // Cached system values (updated each frame)
  var cachedBattery as Float = 100.0;
  var cachedTime as System.ClockTime?;

  function initializeContext(dc as Dc) as Void {
    dc.setColor(backgroundColor, backgroundColor);
    dc.clear();
    dc.setAntiAlias(true);

    w = dc.getWidth();
    h = dc.getHeight();
    cx = w / 2;
    cy = h / 2;
    maxRadius = (w < h ? w : h) / 2;

    cachedBattery = System.getSystemStats().battery;
    cachedTime = System.getClockTime();
  }

  function drawBatteryPercent(dc as Dc) as Void {
    if (!WatchLogic.shouldShowBatteryPercent(cachedBattery)) {
      return;
    }
    var batteryText = cachedBattery.format("%.0f") + " %";
    dc.setColor(Gfx.COLOR_LT_GRAY, backgroundColor);
    dc.drawText(cx, (cy * 2) / 3, dataFont, batteryText, Gfx.TEXT_JUSTIFY_CENTER);
  }

  function drawDateWithBackground(dc as Dc) as Void {
    var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_MEDIUM);
    var theDate = info.day_of_week + " " + info.day.toString();
    var dateWidth = dc.getTextDimensions(theDate, dataFont)[0];
    var fontHeight = dc.getTextDimensions("31", dataFont)[1];
    var cornerX = cx - dateWidth / 2;
    var cornerY = cy + DATE_OFFSET_Y;

    dc.setColor(Gfx.COLOR_LT_GRAY, backgroundColor);
    dc.fillRoundedRectangle(
      cornerX - DATE_PADDING_X,
      cornerY + DATE_PADDING_TOP,
      dateWidth + DATE_PADDING_W,
      fontHeight - DATE_PADDING_TOP,
      DATE_CORNER_RADIUS
    );
    dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cornerX, cornerY, dataFont, theDate, Gfx.TEXT_JUSTIFY_LEFT);
  }

  function drawTicker(dc as Dc) as Void {
    var radius = (maxRadius * TICK_RADIUS_RATIO).toNumber() + 2;
    var batteryAngle = WatchLogic.calculateBatteryAngle(cachedBattery);
    var batteryColor = WatchLogic.getBatteryColorModern(cachedBattery);

    for (var i = 0; i < 60; i += 1) {
      var degre = ((i / 60.0) * 360).toNumber();
      var isHour = i % 5 == 0;
      var innerR = radius - TICK_INNER_OFFSET;
      var endR = isHour ? radius + TICK_HOUR_OUTER_OFFSET : radius;
      var squareBegin = endR + TICK_SQUARE_GAP;
      var squareEnd = squareBegin + TICK_SQUARE_LENGTH;

      if (degre <= batteryAngle) {
        dc.setColor(batteryColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(TICK_BATTERY_PEN_WIDTH);
      } else {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(TICK_NORMAL_PEN_WIDTH);
      }

      drawAngleLine(degre, innerR, endR, dc);

      if (isHour && i % 15 != 0) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        drawAngleRectangle(degre, squareBegin, squareEnd, TICK_SQUARE_WIDTH, dc);
      }
    }
  }

  function drawHours(dc as Dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

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
    if (cachedTime == null) { return; }
    var hourAngle = WatchLogic.calculateHourAngle(
      cachedTime.hour,
      cachedTime.min
    );
    var hourLen = (maxRadius * HOUR_HAND_LENGTH_RATIO).toNumber();

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    drawAngleRectangle(hourAngle, 0, hourLen, HOUR_HAND_WIDTH, dc);
  }

  function drawMinuteHands(dc as Dc) as Void {
    if (cachedTime == null) { return; }
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
    if (cachedTime == null) { return; }
    var secondLen = (maxRadius * SECOND_HAND_LENGTH_RATIO).toNumber();
    var secondAngle = WatchLogic.calculateSecondAngle(cachedTime.sec);

    var x1 = centerToX(secondAngle, -SECOND_HAND_BACK_LENGTH);
    var y1 = centerToY(secondAngle, -SECOND_HAND_BACK_LENGTH);
    var x2 = centerToX(secondAngle, secondLen);
    var y2 = centerToY(secondAngle, secondLen);

    dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(SECOND_HAND_WIDTH);
    dc.drawLine(x1, y1, x2, y2);
  }

  function drawCenterCircle(dc as Dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.fillCircle(cx, cy, CENTER_DOT_RADIUS);

    dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.drawCircle(cx, cy, CENTER_RING_RADIUS);
  }

  private function centerToX(angleDeg as Number, dist as Number) as Float {
    return WatchLogic.polarToX(angleDeg, dist, cx);
  }

  private function centerToY(angleDeg as Number, dist as Number) as Float {
    return WatchLogic.polarToY(angleDeg, dist, cy);
  }

  private function drawAngleLine(
    angle as Number,
    innerR as Integer,
    endR as Integer,
    dc as Dc
  ) as Void {
    dc.drawLine(
      centerToX(angle, innerR), centerToY(angle, innerR),
      centerToX(angle, endR), centerToY(angle, endR)
    );
  }

  private function drawAngleRectangle(
    angle as Number,
    innerR as Integer,
    endR as Integer,
    width as Number,
    dc as Dc
  ) as Void {
    var halfWidth = width / 2.0;
    var rad = Math.toRadians(angle);
    var sinA = Math.sin(rad);
    var cosA = Math.cos(rad);

    // Perpendicular offsets: sin(a±90) = ±cos(a), cos(a±90) = ∓sin(a)
    var perpX = cosA * halfWidth;
    var perpY = sinA * halfWidth;

    var innerX = cx + sinA * innerR;
    var innerY = cy - cosA * innerR;
    var outerX = cx + sinA * endR;
    var outerY = cy - cosA * endR;

    dc.fillPolygon([
      [innerX - perpX, innerY - perpY],
      [innerX + perpX, innerY + perpY],
      [outerX + perpX, outerY + perpY],
      [outerX - perpX, outerY - perpY],
    ]);
  }
}
