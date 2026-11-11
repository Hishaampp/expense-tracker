package com.example.expenses.capture

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.util.UUID

/**
 * Reads payment notifications from allowlisted apps and queues their text
 * (spec §6.2). Only queues text with a rupee amount; never logs content.
 */
class CaptureNotificationListener : NotificationListenerService() {
    private lateinit var queue: CaptureQueue
    private lateinit var sources: CaptureSources

    // The same notification is often posted again or updated: skip a key
    // whose text has not changed (spec §6.2). Bounded; resets on restart,
    // where Dart's content hash catches repeats.
    private val recent = object : LinkedHashMap<String, Int>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Int>?) =
            size > 200
    }

    override fun onCreate() {
        super.onCreate()
        queue = CaptureQueue(applicationContext)
        sources = CaptureSources(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) return
        if (sbn.packageName !in sources.allowed()) return
        val n = sbn.notification ?: return
        if (n.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
        if (n.flags and Notification.FLAG_ONGOING_EVENT != 0) return

        val (title, text) = extract(n) ?: return
        if (!CaptureFilter.hasAmount(text)) return
        val hash = text.hashCode()
        synchronized(recent) {
            if (recent[sbn.key] == hash) return
            recent[sbn.key] = hash
        }
        queue.append(
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("source", "android_notification")
                .put("origin", sbn.packageName)
                .put("title", title ?: JSONObject.NULL)
                .put("text", text)
                .put("receivedAt", sbn.postTime),
        )
        CaptureStatus.markCaptured(applicationContext)
        CaptureBus.queued()
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        requestRebind(ComponentName(this, CaptureNotificationListener::class.java))
    }

    /**
     * Title and text of [n]. For a messaging-style notification (Google
     * Messages groups a conversation into one) only the newest message.
     */
    private fun extract(n: Notification): Pair<String?, String>? {
        val style = NotificationCompat.MessagingStyle
            .extractMessagingStyleFromNotification(n)
        val extras = n.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        if (style != null && style.messages.isNotEmpty()) {
            val newest = style.messages.last()
            val text = newest.text?.toString() ?: return null
            val sender = newest.person?.name?.toString() ?: title
            return sender to text
        }
        val text = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            ?: extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)?.lastOrNull()?.toString()
            ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            ?: return null
        return title to text
    }

    companion object {
        /** Whether the user has granted this app notification access. */
        fun isEnabled(context: Context): Boolean =
            androidx.core.app.NotificationManagerCompat
                .getEnabledListenerPackages(context)
                .contains(context.packageName)
    }
}
