import Toybox.Graphics;

using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian;

class ClassicWatchDrawer {
    var batteryArcWidth = 10;
    var w;
    var h;
    var cx;
    var cy;

    function initVars(dc as Dc) as Void {
        w = dc.getWidth();
        h = dc.getHeight();
        cx = w / 2;
        cy = h / 2;
        dc.setAntiAlias(true);
    }

    function drawBatteryLevel(dc as Dc) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery;
        var angle = (battery / 100.0) * 360;
        var radius = w / 2 - batteryArcWidth / 2;

        dc.setPenWidth(batteryArcWidth / 2);
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK);
        dc.drawArc(w/2, h/2, radius, Gfx.ARC_COUNTER_CLOCKWISE, 0, 360);

        if(battery <= 10){
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        } else if(battery <= 20){
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
        } else {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_BLACK);
        }
        dc.drawArc(w/2, h/2, radius, Gfx.ARC_COUNTER_CLOCKWISE, 0, angle);
    }

    function drawTicher(dc as Dc) as Void {
        var radius = (w < h ? w : h) / 2 - batteryArcWidth - 2;

        // Draw 60 tick marks
        for (var i = 0; i < 60; i += 1) {
            var angle = (i / 60.0) * 2 * Math.PI; // full circle

            var isHour = (i % 5 == 0);
            var innerR = isHour ? radius - 14 : radius - 8;
            var endR = radius;

            dc.setPenWidth(isHour ? 4 : 2);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

            var x1 = cx + Math.sin(angle) * innerR;
            var y1 = cy - Math.cos(angle) * innerR;
            var x2 = cx + Math.sin(angle) * endR;
            var y2 = cy - Math.cos(angle) * endR;

            dc.drawLine(x1, y1, x2, y2);
        }
    }

    function drawHours(dc as Dc) as Void {
        // var centerY = cy - 20;
        var radius = (w < h ? w : h) / 2 - batteryArcWidth;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        // Array of (text, angle)
        // var markers = [["12", 0, fontHeight[0], fontHeight[1]], ["3", 90, fontHeight[0], 0], ["6", 180, fontHeight[0], 0], ["9", 270, fontHeight[0], fontHeight[1]]];
        var fontHeight = dc.getTextDimensions("6", Gfx.FONT_LARGE)[1];
        var markers = [["12", 0, fontHeight, fontHeight], ["3", 90, 30, fontHeight], ["6", 180, fontHeight, fontHeight], ["9", 270, 30, fontHeight]];

        for (var i = 0; i < markers.size(); i += 1) {
            var label = markers[i][0];
            var angleDeg = markers[i][1];
            var rad = Math.toRadians(angleDeg);
            // offset slightly inside circle
            var x = cx + Math.sin(rad) * (radius - markers[i][2]);
            var y = cy - fontHeight / 2 - Math.cos(rad) * (radius - markers[i][3]);
            // System.println("label: " + label + ", x: " + x + ", y: " + y);

            dc.drawText(x, y, Gfx.FONT_LARGE, label, Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawHands(dc as Dc) as Void {
        drawHourHands(dc);
        drawMinuteHands(dc);
        drawSecondHands(dc);
        drawCenterCircle(dc);
    }

    function drawHourHands(dc as Dc) as Void {
        var radius = (w < h ? w : h) / 2 - 10;
        var now = System.getClockTime();
        var hourAngle   = Math.toRadians((now.hour % 12 + now.min / 60.0) * 30);
        var hourLen   = radius * 0.60;

        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy,
            cx + Math.sin(hourAngle) * hourLen,
            cy - Math.cos(hourAngle) * hourLen);
    }

    function drawMinuteHands(dc as Dc) as Void {
        var radius = (w < h ? w : h) / 2 - 10;
        var now = System.getClockTime();
        var minuteAngle = Math.toRadians(now.min * 6 + now.sec / 10.0);
        var minuteLen = radius * 0.80;

        dc.setPenWidth(3);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy,
            cx + Math.sin(minuteAngle) * minuteLen,
            cy - Math.cos(minuteAngle) * minuteLen);
    }

    function drawSecondHands(dc as Dc) as Void {
        var radius = (w < h ? w : h) / 2 - 10;
        var now = System.getClockTime();
        var secondAngle = Math.toRadians(now.sec * 6);
        var secondLen = radius * 0.90;

        dc.setPenWidth(2);
        dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy,
            cx + Math.sin(secondAngle) * secondLen,
            cy - Math.cos(secondAngle) * secondLen);
    }

    function drawCenterCircle(dc as Dc) as Void {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.fillCircle(cx, cy, 4);

        dc.setPenWidth(1);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.drawCircle(cx, cy, 6);
    }

    function drawDate(dc as Dc) as Void {
        var info = Gregorian.utcInfo(Time.today(), Time.FORMAT_SHORT);
        var fontWidth = dc.getTextDimensions("3", Gfx.FONT_LARGE)[0] / 2;
        
        var theDate = info.day.toString();
        var fontDim = dc.getTextDimensions(theDate, Gfx.FONT_SYSTEM_SMALL);
        var circheRadius = (fontDim[0] > fontDim[1] ? fontDim[0] : fontDim[1]) / 2 + 4;

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.drawText(cx - fontWidth + cx / 2, cy , Gfx.FONT_SYSTEM_SMALL, theDate, Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setPenWidth(2);
        dc.drawCircle(cx - fontWidth + cx / 2 - fontDim[0] / 2, cy + 1, circheRadius);
    }
}