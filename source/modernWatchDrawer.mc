import Toybox.Graphics;
import Toybox.Lang;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

class ModernWatchDrawer {
  var batteryArcWidth = 10;
  var w;
  var h;
  var cx;
  var cy;
  var maxRadius as Number = 0;
  var backgroundColor;
  var dataFont;

  var darkNavyBlue = 0x000022; // Dark Navy Blue
  var darkOrange = 0xcc6600; // Dark Orange
  var navyBlue = 0x000055; // Navy Blue
  var darkMediumBlue = 000066;

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
  }

  function drawBatteryPercent(dc as Dc) as Void {
    var battery = System.getSystemStats().battery;
    if (battery > 40) {
      return;
    }
    var batteryText = battery.format("%.0f") + " %";
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

  function drawTicher(dc as Dc) as Void {
    var radius = (maxRadius / 3) * 2 + 2;
    var battery = System.getSystemStats().battery;
    var batteryAngle = (battery / 100.0) * 360;
    var batteryColor;

    if (battery <= 20) {
      batteryColor = Gfx.COLOR_RED;
    } else if (battery <= 30) {
      batteryColor = Gfx.COLOR_YELLOW;
    } else {
      batteryColor = Gfx.COLOR_GREEN;
    }

    // Draw 60 tick marks
    for (var i = 0; i < 60; i += 1) {
      var degre = ((i / 60.0) * 360).toNumber();
      var isHour = i % 5 == 0;
      var innerR = radius - 8;
      var endR = isHour ? radius + 6 : radius;
      var squareBegin = endR + 8;
      var squareEnd = squareBegin + 10;

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
        dc.setPenWidth(6);
        drawAngleLine(degre, squareBegin, squareEnd, dc);
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
    var now = System.getClockTime();
    var hourAngle = (((now.hour % 12) + now.min / 60.0) * 30).toNumber();
    var hourLen = (maxRadius * 0.55).toNumber();

    dc.setPenWidth(5);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      cy,
      centerToX(hourAngle, hourLen),
      centerToY(hourAngle, hourLen)
    );
  }

  function drawMinuteHands(dc as Dc) as Void {
    var now = System.getClockTime();
    var minuteAngle = (now.min * 6 + now.sec / 10.0).toNumber();
    var minuteLen = (maxRadius * 0.75).toNumber();

    dc.setPenWidth(3);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(
      cx,
      cy,
      centerToX(minuteAngle, minuteLen),
      centerToY(minuteAngle, minuteLen)
    );
  }

  function drawSecondHands(dc as Dc) as Void {
    var now = System.getClockTime();
    var secondLen = (maxRadius * 0.85).toNumber(); // your preferred second hand length
    var back = 15; // how far past the center
    var secondAngle = now.sec * 6;

    // Start point (behind center)
    var x1 = centerToX(secondAngle, -back);
    var y1 = centerToY(secondAngle, -back);

    // End point
    var x2 = centerToX(secondAngle, secondLen);
    var y2 = centerToY(secondAngle, secondLen);

    dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(2);
    dc.drawLine(x1, y1, x2, y2);
  }

  function drawCenterCircle(dc as Dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.fillCircle(cx, cy, 4);

    dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.drawCircle(cx, cy, 6);
  }

  function drawDate(dc as Dc) as Void {
    var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_MEDIUM);
    var theDate = info.day_of_week + " " + info.day.toString();
    var dayWidth = dc.getTextDimensions(info.day_of_week, dataFont)[0];
    var dateWidth = dc.getTextDimensions(theDate, dataFont)[0];
    var spaceWidth = dc.getTextDimensions(" ", dataFont)[0];
    var fontHeight = dc.getTextDimensions("31", dataFont)[1];
    var cornerX = cx - dateWidth / 2;
    var cornerY = cy + 25;

    dc.setColor(Gfx.COLOR_WHITE, backgroundColor);
    dc.drawText(cornerX, cornerY, dataFont, theDate, Gfx.TEXT_JUSTIFY_LEFT);
    dc.setPenWidth(1);
    var dayTotalWidth = dayWidth + spaceWidth / 2 + 1;
    dc.drawRoundedRectangle(cornerX - 1, cornerY, dateWidth + 3, fontHeight, 3);
    var lineX = cornerX + dayTotalWidth;
    dc.drawLine(lineX, cornerY, lineX, cornerY + fontHeight - 1);
  }

  function drawDiamondHand(
    dc as Dc,
    cx as Float,
    cy as Float,
    angle as Float,
    length as Float,
    width as Float,
    baseLen as Float
  ) as Void {
    // Calcul des positions des 4 points du losange
    var sinA = Math.sin(angle);
    var cosA = Math.cos(angle);

    // Pointe avant
    var tipX = cx + sinA * length;
    var tipY = cy - cosA * length;

    // Pointe arrière
    var backX = cx - sinA * baseLen;
    var backY = cy + cosA * baseLen;

    // Largeur sur les côtés (perpendiculaire à l’angle)
    var perpA = angle + Math.PI / 2;
    var wSin = Math.sin(perpA);
    var wCos = Math.cos(perpA);

    var sideX1 = cx + (wSin * width) / 2;
    var sideY1 = cy - (wCos * width) / 2;
    var sideX2 = cx - (wSin * width) / 2;
    var sideY2 = cy + (wCos * width) / 2;

    // Les 4 sommets du polygone (ordre important)
    var points = [
      [tipX, tipY],
      [sideX1, sideY1],
      [backX, backY],
      [sideX2, sideY2],
    ];
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
    dc.fillPolygon(points);
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
}
