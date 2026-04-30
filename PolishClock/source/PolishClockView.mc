import Toybox.ActivityMonitor;
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
    private const DATE_Y    = 55;   // centre of date line
    private const MARQUEE_Y = 115;  // centre of scrolling time text
    private const HR_Y      = 175;  // centre of heart rate line

    // Marquee scroll speed in pixels per second (high-power update)
    private const SCROLL_SPEED = 2;

    // Gap between end of text and start of next loop (px)
    private const LOOP_GAP = 60;

    // ── State ──────────────────────────────────────────────────────────────
    private var mScrollX     as Float = SCREEN_W.toFloat();
    private var mTimeString  as String = "";
    private var mDateString  as String = "";
    private var mHrString    as String = "--";
    private var mTextWidth   as Number = 0;
    private var mIsLowPower  as Boolean = false;

    // Cached last minute to avoid rebuilding the string every second
    private var mLastMinute  as Number = -1;
    private var mLastHour    as Number = -1;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        // Nothing to lay out — all drawing is manual.
        // Compute initial time string so first frame is not blank.
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        _updateTimeString(now.hour, now.min);
        _updateDateString(now.day, now.month);
        _updateHrString();
        mScrollX = SCREEN_W.toFloat();
    }

    // Called every second in high-power, every minute in low-power
    function onUpdate(dc as Graphics.Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        // Rebuild date/time strings only when minute changes
        if (now.hour != mLastHour || now.min != mLastMinute) {
            _updateTimeString(now.hour, now.min);
            _updateDateString(now.day, now.month);
            _updateHrString();
            mLastHour   = now.hour;
            mLastMinute = now.min;
            // Recompute text width for the new string
            mTextWidth = dc.getTextWidthInPixels(mTimeString, Graphics.FONT_MEDIUM);
            // In low-power mode reset scroll position
            if (mIsLowPower) {
                mScrollX = SCREEN_W.toFloat();
            }
        }

        // Advance marquee (only meaningful in high-power; low-power stays put)
        if (!mIsLowPower) {
            mScrollX -= SCROLL_SPEED;
            // When text has fully scrolled off the left, restart from the right
            if (mScrollX + mTextWidth < 0) {
                mScrollX = SCREEN_W.toFloat() + LOOP_GAP;
            }
        }

        _drawFrame(dc);
    }

    // Called every second in high-power for partial updates.
    // We repaint the entire face every second anyway for the marquee.
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

    private function _updateDateString(day as Number, month as Number) as Void {
        var monthAbbr = PolishTime.getMonthAbbr(month);
        mDateString = day.toString() + " / " + monthAbbr;
    }

    private function _updateHrString() as Void {
        var info = ActivityMonitor.getInfo();
        if (info != null && info.heartRate != null) {
            mHrString = info.heartRate.toString();
        } else {
            mHrString = "--";
        }
    }

    private function _drawFrame(dc as Graphics.Dc) as Void {
        // ── Background ───────────────────────────────────────────────────
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // ── Date line ────────────────────────────────────────────────────
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            DATE_Y,
            Graphics.FONT_SMALL,
            mDateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // ── Horizontal separator lines ────────────────────────────────────
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(20, DATE_Y + 22, SCREEN_W - 20, DATE_Y + 22);
        dc.drawLine(20, MARQUEE_Y + 22, SCREEN_W - 20, MARQUEE_Y + 22);

        // ── Marquee clip region ──────────────────────────────────────────
        // Clip so text doesn't bleed outside the designated strip.
        // The strip runs from y=89 to y=141 (MARQUEE_Y ± 26px for FONT_MEDIUM).
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

        // ── Heart rate line ───────────────────────────────────────────────
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            CENTER_X,
            HR_Y,
            Graphics.FONT_SMALL,
            "♥ " + mHrString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
