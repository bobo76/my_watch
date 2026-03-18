import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.ActivityMonitor;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class TacticalWatchDrawer {
  // Layout constants
  var w as Number = 0;
  var h as Number = 0;
  var cx as Number = 0;
  var cy as Number = 0;
  var maxRadius as Number = 0;
  var backgroundColor as Number = 0x000000; // Black background

  // Color constants
  var gaugeColor as Number = 0x555555; // Gray for gauges
  var textColor as Number = 0xaaaaaa; // Light gray text
  var accentColor as Number = 0xff6600; // Orange accent

  // Cached system values
  var cachedBattery as Float = 100.0;
  var cachedTime as System.ClockTime?;
  var cachedInfo as ActivityMonitor.Info?;

  function initializeContext(dc as Dc) as Void {
    dc.setColor(backgroundColor, backgroundColor);
    dc.clear();
    dc.setAntiAlias(true);

    w = dc.getWidth();
    h = dc.getHeight();
    cx = w / 2;
    cy = h / 2;
    maxRadius = (w < h ? w : h) / 2;

    // Cache system values
    cachedBattery = System.getSystemStats().battery;
    cachedTime = System.getClockTime();
    cachedInfo = ActivityMonitor.getInfo();
  }

  // Draw button labels around the perimeter
  function drawButtonLabels(dc as Dc) as Void {}

  // Draw small gauge at specified position
  private function drawSmallGauge(
    dc as Dc,
    x as Number,
    y as Number,
    value as Number,
    max as Number,
    label as String
  ) as Void {
    var radius = 25;

    // Draw outer circle
    dc.setColor(gaugeColor, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawCircle(x, y, radius);

    // Draw tick marks
    for (var i = 0; i < 12; i++) {
      var angle = (i / 12.0) * 2 * Math.PI;
      var innerR = radius - 4;
      var outerR = radius - 1;

      var x1 = x + Math.sin(angle) * innerR;
      var y1 = y - Math.cos(angle) * innerR;
      var x2 = x + Math.sin(angle) * outerR;
      var y2 = y - Math.cos(angle) * outerR;

      dc.setPenWidth(1);
      dc.drawLine(x1, y1, x2, y2);
    }

    // Draw value
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      x,
      y - 8,
      Gfx.FONT_TINY,
      value.format("%d"),
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Draw label
    dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(x, y + 3, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_CENTER);
  }

  // Draw the main analog clock face
  function drawMainClock(dc as Dc) as Void {
    var clockCenterY = cy - 20; // Position in upper center
    var clockRadius = 65;

    // Draw main clock circle
    dc.setColor(gaugeColor, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawCircle(cx, clockCenterY, clockRadius);

    // Draw tick marks (60 marks around full circle)
    for (var i = 0; i < 60; i++) {
      var angle = (i / 60.0) * 2 * Math.PI;
      var isHour = i % 5 == 0;
      var innerR = isHour ? clockRadius - 8 : clockRadius - 4;
      var outerR = clockRadius;

      dc.setPenWidth(isHour ? 2 : 1);
      dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);

      var x1 = cx + Math.sin(angle) * innerR;
      var y1 = clockCenterY - Math.cos(angle) * innerR;
      var x2 = cx + Math.sin(angle) * outerR;
      var y2 = clockCenterY - Math.cos(angle) * outerR;

      dc.drawLine(x1, y1, x2, y2);
    }

    // Draw speedometer-style numbers (only on top half)
    dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);
    var font = Gfx.FONT_XTINY;

    // Left side: 8
    dc.drawText(
      cx - clockRadius - 12,
      clockCenterY - 5,
      font,
      "8",
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Top: 50
    dc.drawText(
      cx,
      clockCenterY - clockRadius - 12,
      font,
      "50",
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Right side: 100
    dc.drawText(
      cx + clockRadius + 12,
      clockCenterY - 5,
      font,
      "100",
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Draw clock hands
    drawClockHands(dc, clockCenterY, clockRadius);
  }

  private function drawClockHands(
    dc as Dc,
    centerY as Number,
    radius as Number
  ) as Void {
    var hourAngle =
      (((cachedTime.hour % 12) + cachedTime.min / 60.0) / 12.0) * 2 * Math.PI;
    var minuteAngle = (cachedTime.min / 60.0) * 2 * Math.PI;
    var secondAngle = (cachedTime.sec / 60.0) * 2 * Math.PI;

    // Hour hand
    var hourLen = radius * 0.5;
    dc.setPenWidth(4);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      centerY,
      cx + Math.sin(hourAngle) * hourLen,
      centerY - Math.cos(hourAngle) * hourLen
    );

    // Minute hand
    var minuteLen = radius * 0.7;
    dc.setPenWidth(3);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      centerY,
      cx + Math.sin(minuteAngle) * minuteLen,
      centerY - Math.cos(minuteAngle) * minuteLen
    );

    // Second hand
    var secondLen = radius * 0.8;
    dc.setPenWidth(1);
    dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      centerY,
      cx + Math.sin(secondAngle) * secondLen,
      centerY - Math.cos(secondAngle) * secondLen
    );

    // Center dot
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.fillCircle(cx, centerY, 4);
  }

  // Draw peripheral gauges
  function drawGauges(dc as Dc) as Void {
    // Top left gauge - showing "100"
    var steps = 100;
    if (cachedInfo != null && cachedInfo.steps != null) {
      steps = (cachedInfo.steps / 100).toNumber(); // Scale for display
      if (steps > 100) {
        steps = 100;
      }
    }
    drawSmallGauge(dc, 40, 65, steps, 100, "");

    // Left middle gauge - showing calories or distance
    var metric = 8;
    if (cachedInfo != null && cachedInfo.calories != null) {
      metric = (cachedInfo.calories / 100).toNumber(); // Scale down
      if (metric > 99) {
        metric = 99;
      }
    }
    drawSmallGauge(dc, 35, cy - 10, metric, 100, "");
  }

  // Draw battery with label as a small gauge
  function drawBattery(dc as Dc) as Void {
    var batteryY = cy + 55;
    var radius = 25;

    // Draw battery circle
    dc.setColor(gaugeColor, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawCircle(cx, batteryY, radius);

    // Draw tick marks
    for (var i = 0; i < 12; i++) {
      var angle = (i / 12.0) * 2 * Math.PI;
      var innerR = radius - 4;
      var outerR = radius - 1;

      var x1 = cx + Math.sin(angle) * innerR;
      var y1 = batteryY - Math.cos(angle) * innerR;
      var x2 = cx + Math.sin(angle) * outerR;
      var y2 = batteryY - Math.cos(angle) * outerR;

      dc.setPenWidth(1);
      dc.drawLine(x1, y1, x2, y2);
    }

    // Draw battery percentage value
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      batteryY - 8,
      Gfx.FONT_TINY,
      cachedBattery.format("%.0f"),
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Draw "BATTERY" label below gauge
    dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      batteryY + 20,
      Gfx.FONT_XTINY,
      "BATTERY",
      Gfx.TEXT_JUSTIFY_CENTER
    );
  }

  // Draw date display on right side
  function drawDate(dc as Dc) as Void {
    var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_SHORT);
    var dayOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    var day = dayOfWeek[info.day_of_week - 1];
    var date = info.day.toString();

    var dateX = w - 30;
    var dateY = cy;

    // Draw date box background with border
    var boxWidth = 32;
    var boxHeight = 24;

    dc.setColor(gaugeColor, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawRectangle(
      dateX - boxWidth / 2,
      dateY - boxHeight / 2,
      boxWidth,
      boxHeight
    );

    // Draw day of week on top
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(
      dateX,
      dateY - 10,
      Gfx.FONT_XTINY,
      day,
      Gfx.TEXT_JUSTIFY_CENTER
    );

    // Draw separator line
    dc.setPenWidth(1);
    dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(dateX - 12, dateY - 2, dateX + 12, dateY - 2);

    // Draw date number on bottom
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(dateX, dateY + 2, Gfx.FONT_TINY, date, Gfx.TEXT_JUSTIFY_CENTER);
  }

  // Main draw function to be called from view
  function draw(dc as Dc, showSeconds as Boolean) as Void {
    initializeContext(dc);
    drawButtonLabels(dc);
    drawMainClock(dc);
    drawGauges(dc);
    drawBattery(dc);
    drawDate(dc);
  }
}
