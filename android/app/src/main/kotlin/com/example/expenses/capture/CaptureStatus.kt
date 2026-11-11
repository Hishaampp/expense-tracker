package com.example.expenses.capture

import android.content.Context

/** Remembers when the last capture was queued, for the health screen. */
object CaptureStatus {
    private const val PREFS = "capture_status"
    private const val LAST = "last_capture_at"

    fun markCaptured(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putLong(LAST, System.currentTimeMillis()).apply()
    }

    /** Epoch milliseconds of the last capture, or null. */
    fun lastCaptureAt(context: Context): Long? {
        val value = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getLong(LAST, 0L)
        return if (value == 0L) null else value
    }
}
