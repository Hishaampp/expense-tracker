package com.example.expenses.capture

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import org.json.JSONObject
import java.util.Calendar
import java.util.UUID

/**
 * Direct SMS access for the sideload build (spec §6.2): a receiver for new
 * messages (`SmsReceiver`) and a one-off import of past bank messages.
 */
object SmsSupport {
    const val SUPPORTED = true
    private const val REQUEST_CODE = 4107

    fun hasPermission(context: Context): Boolean =
        listOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS).all {
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }

    fun requestPermission(activity: Activity) {
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS),
            REQUEST_CODE,
        )
    }

    /**
     * Queues bank messages from the last [months] months. Returns how many
     * were queued. Dart de-duplicates, so running it twice is safe.
     */
    fun importHistory(context: Context, months: Int): Int {
        if (!hasPermission(context)) return 0
        val since = Calendar.getInstance().apply { add(Calendar.MONTH, -months) }.timeInMillis
        val queue = CaptureQueue(context)
        var count = 0
        context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE),
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(since.toString()),
            "${Telephony.Sms.DATE} ASC",
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val sender = cursor.getString(0) ?: continue
                val body = cursor.getString(1) ?: continue
                val date = cursor.getLong(2)
                if (!SmsSenders.isCommercial(sender) || !CaptureFilter.hasAmount(body)) continue
                queue.append(capture(sender, body, date))
                count++
            }
        }
        if (count > 0) CaptureBus.queued()
        return count
    }

    fun capture(sender: String, body: String, date: Long): JSONObject = JSONObject()
        .put("id", UUID.randomUUID().toString())
        .put("source", "android_sms")
        .put("origin", sender)
        .put("title", JSONObject.NULL)
        .put("text", body)
        .put("receivedAt", date)
}

/** Indian commercial SMS sender IDs (spec §6.2). */
object SmsSenders {
    // "AX-HDFCBK", "VM-SBIUPI-S" (category suffix), or a bare header from
    // carriers that drop the prefix. A phone number is never commercial.
    private val header = Regex("""^(?:[A-Z]{2}-)?[A-Z0-9]{5,9}(?:-[A-Z])?$""")

    fun isCommercial(sender: String): Boolean {
        val s = sender.trim().uppercase()
        return header.matches(s) && s.any { it.isLetter() }
    }
}
