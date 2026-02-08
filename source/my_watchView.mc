import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class my_watchView extends WatchUi.WatchFace {
  var drawer as ModernWatchDrawer;
  var isAsleep as Boolean;

  function initialize() {
    WatchFace.initialize();
    drawer = new ModernWatchDrawer();
    isAsleep = false;
  }

  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
  }

  function onShow() as Void {
    isAsleep = false;
  }

  function onUpdate(dc as Dc) as Void {
    drawer.initializeContext(dc);
    drawer.drawBatteryPercent(dc);
    drawer.drawDateWithBackground(dc);
    drawer.drawTicker(dc);
    drawer.drawHours(dc);
    drawer.drawHourHands(dc);
    drawer.drawMinuteHands(dc);
    if (!isAsleep) {
      drawer.drawSecondHands(dc);
    }
    drawer.drawCenterCircle(dc);
  }

  function onHide() as Void {}

  function onExitSleep() as Void {
    isAsleep = false;
  }

  function onEnterSleep() as Void {
    isAsleep = true;
  }
}
