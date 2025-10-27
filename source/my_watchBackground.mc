import Toybox.Application;
import Toybox.Graphics;
// import Toybox.Lang;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {
    var drawer;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
        drawer = new ClassicWatchDrawer();
    }

    function draw(dc as Dc) as Void {
        drawer.initVars(dc);
        drawer.drawBatteryLevel(dc);
        drawer.drawTicher(dc);
        drawer.drawHours(dc);
        drawer.drawDate(dc);
        drawer.drawHourHands(dc);
        drawer.drawMinuteHands(dc);
        drawer.drawCenterCircle(dc);    
    }

}
