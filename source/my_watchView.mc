import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class my_watchView extends WatchUi.WatchFace {
    var drawer as ModernWatchDrawer;
    var drawSecondsHand as Boolean;

    function initialize() {
        WatchFace.initialize();
        drawer = new ModernWatchDrawer();
        drawSecondsHand = true;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        drawSecondsHand = true;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        drawer.initializeContext(dc);
        
        drawer.drawTicher(dc);
        drawer.drawHours(dc);
        drawer.drawDate(dc);
        drawer.drawHourHands(dc);
        drawer.drawMinuteHands(dc);
        if(drawSecondsHand) {
            drawer.drawSecondHands(dc);
        }
        drawer.drawCenterCircle(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        drawSecondsHand = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        drawSecondsHand = false;
    }

}

