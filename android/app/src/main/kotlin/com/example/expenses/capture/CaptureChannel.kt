package com.example.expenses.capture

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID

/**
 * The bridge between the native capture queue and Dart (spec §6.1):
 * MethodChannel `app/capture` and EventChannel `app/capture/events`.
 * Native code only queues raw text; all parsing happens in Dart.
 */
class CaptureChannel(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val queue = CaptureQueue(context)
    private val main = Handler(Looper.getMainLooper())
    private var events: EventChannel.EventSink? = null

    init {
        MethodChannel(messenger, "app/capture").setMethodCallHandler(this)
        EventChannel(messenger, "app/capture/events").setStreamHandler(this)
    }

    /** Queues text shared into the app and tells Dart if it is listening. */
    fun enqueueShare(text: String, origin: String?) {
        if (text.isBlank()) return
        val capture = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("source", "share")
            .put("origin", origin ?: JSONObject.NULL)
            .put("title", JSONObject.NULL)
            .put("text", text)
            .put("receivedAt", System.currentTimeMillis())
        queue.append(capture)
        main.post { events?.success("queued") }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "drainQueue" -> result.success(queue.readAll().map { it.toString() })
            "ack" -> {
                val ids = call.argument<List<String>>("ids") ?: emptyList()
                queue.remove(ids.toSet())
                result.success(null)
            }
            "status" -> result.success(
                mapOf(
                    "platform" to "android",
                    "queueSize" to queue.size(),
                )
            )
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }
}
