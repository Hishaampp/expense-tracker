package com.example.expenses.capture

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/** Queues new bank SMS as they arrive (sideload build only, spec §6.2). */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        // A long SMS arrives in parts; join them per sender.
        parts.filterNotNull().groupBy { it.originatingAddress ?: "" }.forEach { (sender, msgs) ->
            if (!SmsSenders.isCommercial(sender)) return@forEach
            val body = msgs.joinToString("") { it.messageBody ?: "" }
            if (!CaptureFilter.hasAmount(body)) return@forEach
            val date = msgs.first().timestampMillis
            CaptureQueue(context).append(SmsSupport.capture(sender, body, date))
            CaptureStatus.markCaptured(context)
        }
        CaptureBus.queued()
    }
}
