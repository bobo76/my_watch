import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class my_watchView extends WatchUi.WatchFace {
  var drawer as ModernWatchDrawer;
  var onSleep as Boolean;

  function initialize() {
    WatchFace.initialize();
    drawer = new ModernWatchDrawer();
    onSleep = false;
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    onSleep = false;
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    drawer.initializeContext(dc);

    drawer.drawBatteryPercent(dc);
    drawer.drawDateWithBackground(dc);
    drawer.drawTicher(dc);
    drawer.drawHours(dc);
    drawer.drawHourHands(dc);
    drawer.drawMinuteHands(dc);
    if (!onSleep) {
      drawer.drawSecondHands(dc);
    }
    drawer.drawCenterCircle(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    onSleep = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {
    onSleep = true;
  }
}
