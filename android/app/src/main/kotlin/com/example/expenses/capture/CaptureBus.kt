package com.example.expenses.capture

/**
 * Lets capture sources (the notification listener, the SMS receiver) tell
 * a running Flutter engine that something was queued. When the app is not
 * running nothing listens; Dart drains the queue on its next start.
 */
object CaptureBus {
    @Volatile
    var onQueued: (() -> Unit)? = null

    fun queued() {
        onQueued?.invoke()
    }
}
