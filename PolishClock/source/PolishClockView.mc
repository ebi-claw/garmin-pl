import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class PolishClockView extends WatchUi.WatchFace {

    // ── Layout constants for 240×240 fenix 6S Pro ─────────────────────────
    private const SCREEN_W  = 240;
    private const CENTER_X  = SCREEN_W / 2;

    // Y positions (from top)
    private const DATE_Y    = 70;   // centre of date line
    private const MARQUEE_Y = 120;  // centre of scrolling time text

    // Marquee scroll speed: 240px / 5s = 48 px per second
    private const SCROLL_SPEED = 48;

    // Gap between end of text and start of next loop (px)
    private const LOOP_GAP = 60;

    // ── State ──────────────────────────────────────────────────────────────
    private var mScrollX     as Float = SCREEN_W.toFloat();
    private var mTimeString  as String = "";
    private var mDateString  as String = "";
    private var mTextWidth   as Number = 0;
    private var mIsLowPower  as Boolean = false;

    // Cached last minute to avoid rebuilding the string every second
    private var mLastMinute  as Number = -1;
    private var mLastHour    as Number = -1;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        _updateTimeString(now.hour, now.min);
        _updateDateString(now.day_of_week, now.day, now.month);
        mScrollX = SCREEN_W.toFloat();
    }

    // Called every second in high-power, every minute in low-power
    function onUpdate(dc as Graphics.Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        if (now.hour != mLastHour || now.min != mLastMinute) {
            _updateTimeString(now.hour, now.min);
            _updateDateString(now.day_of_week, now.day, now.month);
            mLastHour   = now.hour;
            mLastMinute = now.min;
            mTextWidth = dc.getTextWidthInPixels(mTimeString, Graphics.FONT_MEDIUM);
            if (mIsLowPower) {
                mScrollX = SCREEN_W.toFloat();
            }
        }

        if (!mIsLowPower) {
            mScrollX -= SCROLL_SPEED;
            if (mScrollX + mTextWidth < 0) {
                mScrollX = SCREEN_W.toFloat() + LOOP_GAP;
            }
        }

        _drawFrame(dc);
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        onUpdate(dc);
    }

    function onEnterSleep() as Void {
        mIsLowPower = true;
        mScrollX = SCREEN_W.toFloat();
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        mIsLowPower = false;
        WatchUi.requestUpdate();
    }

    // ── Private helpers ────────────────────────────────────────────────────

    private function _updateTimeString(hour as Number, minute as Number) as Void {
        mTimeString = PolishTime.getTimeString(hour, minute);
    }

    private function _updateDateString(dayOfWeek as Number, day as Number, month as Number) as Void {
        mDateString = PolishTime.getDayName(dayOfWeek) + " / " + day.toString() + " / " + PolishTime.getMonthName(month);
    }

    private function _drawFrame(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Date line
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            DATE_Y,
            Graphics.FONT_TINY,
            mDateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Separator lines
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(20, DATE_Y + 22, SCREEN_W - 20, DATE_Y + 22);
        dc.drawLine(20, MARQUEE_Y + 22, SCREEN_W - 20, MARQUEE_Y + 22);

        // Marquee — clipped to its strip
        dc.setClip(0, MARQUEE_Y - 26, SCREEN_W, 52);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            mScrollX.toNumber(),
            MARQUEE_Y,
            Graphics.FONT_MEDIUM,
            mTimeString,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.clearClip();
    }
}
