import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class my_watchView extends WatchUi.WatchFace {
  var drawer as StylishWatchDrawer;
  var isAsleep as Boolean;

  function initialize() {
    WatchFace.initialize();
    drawer = new StylishWatchDrawer();
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
    drawer.drawTickMarks(dc);
    drawer.drawHourNumbers(dc);
    drawer.drawInnerRing(dc);
    drawer.drawDate(dc);
    drawer.drawBatteryPercent(dc);
    drawer.drawHourHand(dc);
    drawer.drawMinuteHand(dc);
    if (!isAsleep) {
      drawer.drawSecondHand(dc);
    }
    drawer.drawCenterDot(dc);
  }

  function onHide() as Void {}

  function onExitSleep() as Void {
    isAsleep = false;
  }

  function onEnterSleep() as Void {
    isAsleep = true;
  }
}
