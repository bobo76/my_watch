import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class StylishWatchDrawer {
  // Layout constants
  var w as Number = 0;
  var h as Number = 0;
  var cx as Number = 0;
  var cy as Number = 0;
  var maxRadius as Number = 0;

  // Colors
  const COLOR_BACKGROUND = 0x000000;
  const COLOR_ACCENT = 0xFF8800;
  const COLOR_TRACK = 0x222222;
  const COLOR_HOUR_TEXT = 0xFFFFFF;
  const COLOR_INNER_RING = 0x555555;
  const COLOR_TICK = 0x666666;

  // Tick marks
  const TICK_RADIUS_RATIO = 0.72;
  const TICK_MINUTE_LENGTH = 5;
  const TICK_HOUR_LENGTH = 12;
  const TICK_MINUTE_PEN = 3;
  const TICK_HOUR_PEN = 3;
  const TICK_BATTERY_PEN = 3;

  // Hour numbers
  const HOUR_NUMBER_RADIUS_RATIO = 0.82;

  // Inner ring
  const INNER_RING_RADIUS_RATIO = 0.72;

  // Hand geometry
  const HOUR_TIP_RATIO = 0.50;
  const HOUR_WIDE_RATIO = 0.25;
  const HOUR_TAIL_RATIO = 0.12;
  const HOUR_HALF_WIDTH = 6;

  const MINUTE_TIP_RATIO = 0.70;
  const MINUTE_WIDE_RATIO = 0.10;
  const MINUTE_TAIL_RATIO = 0.08;
  const MINUTE_HALF_WIDTH = 5;

  const SECOND_TIP_RATIO = 0.78;
  const SECOND_BACK_RATIO = 0.17;
  const SECOND_PEN_WIDTH = 2;
  const SECOND_COUNTER_RADIUS = 4;

  // Hand outline
  const HAND_OUTLINE_EXTRA = 2;

  // Center dot
  const CENTER_DOT_RADIUS = 4;

  // Date position
  const DATE_X_RATIO = 0.40;

  // Cached system values (updated each frame)
  var cachedBattery as Float = 100.0;
  var cachedTime as System.ClockTime?;

  function initializeContext(dc as Dc) as Void {
    dc.setColor(COLOR_BACKGROUND, COLOR_BACKGROUND);
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

  // Tick marks colored by battery level
  function drawTickMarks(dc as Dc) as Void {
    var radius = (maxRadius * TICK_RADIUS_RATIO).toNumber();
    var batteryAngle = WatchLogic.calculateBatteryAngle(cachedBattery);
    var batteryColor = WatchLogic.getBatteryColorStylish(cachedBattery);

    for (var i = 0; i < 60; i += 1) {
      var angleDeg = ((i / 60.0) * 360).toNumber();
      var isHour = i % 5 == 0;
      var inBattery = angleDeg <= batteryAngle;

      if (inBattery) {
        dc.setPenWidth(isHour ? TICK_HOUR_PEN : TICK_BATTERY_PEN);
        dc.setColor(batteryColor, Gfx.COLOR_TRANSPARENT);
      } else if (isHour) {
        dc.setPenWidth(TICK_HOUR_PEN);
        dc.setColor(COLOR_HOUR_TEXT, Gfx.COLOR_TRANSPARENT);
      } else {
        dc.setPenWidth(TICK_MINUTE_PEN);
        dc.setColor(COLOR_TICK, Gfx.COLOR_TRANSPARENT);
      }

      var innerR = radius - (isHour ? TICK_HOUR_LENGTH : TICK_MINUTE_LENGTH);
      drawAngleLine(angleDeg, innerR, radius, dc);
    }
  }

  // Layer 4: All 12 hour numbers
  function drawHourNumbers(dc as Dc) as Void {
    var radius = (maxRadius * HOUR_NUMBER_RADIUS_RATIO).toNumber();
    var font = Gfx.FONT_XTINY;
    var fontMidH = dc.getTextDimensions("12", font)[1] / 2;
    dc.setColor(COLOR_HOUR_TEXT, Gfx.COLOR_TRANSPARENT);

    for (var i = 0; i < 12; i += 1) {
      var angleDeg = i * 30;
      var hourNum = i == 0 ? 12 : i;
      var label = hourNum < 10 ? "0" + hourNum.toString() : hourNum.toString();

      var x = centerToX(angleDeg, radius);
      var y = centerToY(angleDeg, radius) - fontMidH;
      dc.drawText(x, y, font, label, Gfx.TEXT_JUSTIFY_CENTER);
    }
  }

  // Layer 5: Thin gray decorative inner ring
  function drawInnerRing(dc as Dc) as Void {
    var radius = (maxRadius * INNER_RING_RADIUS_RATIO).toNumber() + 1;
    dc.setPenWidth(1);
    dc.setColor(COLOR_INNER_RING, Gfx.COLOR_TRANSPARENT);
    dc.drawCircle(cx, cy, radius);
  }

  // Layer 6: Date at 3 o'clock position
  function drawDate(dc as Dc) as Void {
    var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_SHORT);
    var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    var dayOfWeek = dayNames[info.day_of_week - 1];
    var theDate = dayOfWeek + " " + info.day.toString();

    var dateX = cx + (maxRadius * DATE_X_RATIO).toNumber();
    dc.setColor(COLOR_HOUR_TEXT, Gfx.COLOR_TRANSPARENT);
    dc.drawText(dateX, cy, Gfx.FONT_XTINY, theDate, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
  }

  // Layer 7: Battery % shown only when ≤40%
  function drawBatteryPercent(dc as Dc) as Void {
    if (!WatchLogic.shouldShowBatteryPercent(cachedBattery)) {
      return;
    }
    var batteryText = cachedBattery.format("%.0f") + "%";
    dc.setColor(COLOR_ACCENT, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cx, (cy * 2) / 3, Gfx.FONT_XTINY, batteryText, Gfx.TEXT_JUSTIFY_CENTER);
  }

  // Layer 8: Hour hand — white diamond polygon
  function drawHourHand(dc as Dc) as Void {
    if (cachedTime == null) { return; }
    var hourAngle = WatchLogic.calculateHourAngle(
      cachedTime.hour,
      cachedTime.min
    );
    var tipDist = (maxRadius * HOUR_TIP_RATIO).toNumber();
    var wideDist = (maxRadius * HOUR_WIDE_RATIO).toNumber();
    var tailDist = (maxRadius * HOUR_TAIL_RATIO).toNumber();

    dc.setColor(0xCCCCCC, Gfx.COLOR_TRANSPARENT);
    drawDiamondHand(hourAngle, tipDist, wideDist, tailDist, HOUR_HALF_WIDTH, dc);
  }

  // Layer 9: Minute hand — white diamond polygon with outline
  function drawMinuteHand(dc as Dc) as Void {
    if (cachedTime == null) { return; }
    var minuteAngle = WatchLogic.calculateMinuteAngle(
      cachedTime.min,
      cachedTime.sec
    );
    var tipDist = (maxRadius * MINUTE_TIP_RATIO).toNumber();
    var wideDist = (maxRadius * MINUTE_WIDE_RATIO).toNumber();
    var tailDist = (maxRadius * MINUTE_TAIL_RATIO).toNumber();

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    drawDiamondHand(minuteAngle, tipDist, wideDist, tailDist, MINUTE_HALF_WIDTH, dc);
  }

  // Layer 10: Second hand — orange line with counterweight circle
  function drawSecondHand(dc as Dc) as Void {
    if (cachedTime == null) { return; }
    var secondAngle = WatchLogic.calculateSecondAngle(cachedTime.sec);
    var tipDist = (maxRadius * SECOND_TIP_RATIO).toNumber();
    var backDist = (maxRadius * SECOND_BACK_RATIO).toNumber();

    var tipX = centerToX(secondAngle, tipDist);
    var tipY = centerToY(secondAngle, tipDist);
    var backX = centerToX(secondAngle, -backDist);
    var backY = centerToY(secondAngle, -backDist);

    dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(SECOND_PEN_WIDTH);
    dc.drawLine(backX, backY, tipX, tipY);

    // Counterweight circle
    dc.fillCircle(backX, backY, SECOND_COUNTER_RADIUS);
  }

  // Layer 11: Center dot — orange filled circle
  function drawCenterDot(dc as Dc) as Void {
    dc.setColor(COLOR_ACCENT, Gfx.COLOR_TRANSPARENT);
    dc.fillCircle(cx, cy, CENTER_DOT_RADIUS);
  }

  // --- Private helpers ---

  private function drawDiamondHand(
    angleDeg as Number,
    tipDist as Number,
    wideDist as Number,
    tailDist as Number,
    halfWidth as Number,
    dc as Dc
  ) as Void {
    var rad = Math.toRadians(angleDeg);
    var sinA = Math.sin(rad);
    var cosA = Math.cos(rad);

    // Perpendicular offsets
    var perpX = cosA * halfWidth;
    var perpY = sinA * halfWidth;

    // Tip point (along angle direction)
    var tipX = cx + sinA * tipDist;
    var tipY = cy - cosA * tipDist;

    // Tail point (behind center)
    var tailX = cx - sinA * tailDist;
    var tailY = cy + cosA * tailDist;

    // Wide points (perpendicular at wideDist)
    var wideBaseX = cx + sinA * wideDist;
    var wideBaseY = cy - cosA * wideDist;

    dc.fillPolygon([
      [tipX, tipY],
      [wideBaseX + perpX, wideBaseY + perpY],
      [tailX, tailY],
      [wideBaseX - perpX, wideBaseY - perpY],
    ]);
  }

  private function centerToX(angleDeg as Number, dist as Number) as Float {
    return WatchLogic.polarToX(angleDeg, dist, cx);
  }

  private function centerToY(angleDeg as Number, dist as Number) as Float {
    return WatchLogic.polarToY(angleDeg, dist, cy);
  }

  private function drawAngleLine(
    angle as Number,
    innerR as Number,
    endR as Number,
    dc as Dc
  ) as Void {
    dc.drawLine(
      centerToX(angle, innerR), centerToY(angle, innerR),
      centerToX(angle, endR), centerToY(angle, endR)
    );
  }
}
