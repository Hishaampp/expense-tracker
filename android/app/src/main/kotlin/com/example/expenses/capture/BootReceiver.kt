package com.example.expenses.capture

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService

/** After a reboot, asks Android to reconnect the listener (spec §6.2). */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        if (!CaptureNotificationListener.isEnabled(context)) return
        NotificationListenerService.requestRebind(
            ComponentName(context, CaptureNotificationListener::class.java),
        )
    }
}
