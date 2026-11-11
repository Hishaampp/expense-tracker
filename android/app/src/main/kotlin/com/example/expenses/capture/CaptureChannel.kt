package com.example.expenses.capture

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.Executors

/**
 * The bridge between the native capture queue and Dart (spec §6.1):
 * MethodChannel `app/capture` and EventChannel `app/capture/events`.
 * Native code only queues raw text; all parsing happens in Dart.
 */
class CaptureChannel(
    private val context: Context,
    messenger: BinaryMessenger,
    private val activity: () -> Activity?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val queue = CaptureQueue(context)
    private val sources = CaptureSources(context)
    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newSingleThreadExecutor()
    private var events: EventChannel.EventSink? = null

    init {
        MethodChannel(messenger, "app/capture").setMethodCallHandler(this)
        EventChannel(messenger, "app/capture/events").setStreamHandler(this)
        CaptureBus.onQueued = { main.post { events?.success("queued") } }
    }

    /** Queues text shared into the app and tells Dart if it is listening. */
    fun enqueueShare(text: String, origin: String?) {
        if (text.isBlank()) return
        queue.append(
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("source", "share")
                .put("origin", origin ?: JSONObject.NULL)
                .put("title", JSONObject.NULL)
                .put("text", text)
                .put("receivedAt", System.currentTimeMillis()),
        )
        CaptureBus.queued()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "drainQueue" -> result.success(queue.readAll().map { it.toString() })
            "ack" -> {
                val ids = call.argument<List<String>>("ids") ?: emptyList()
                queue.remove(ids.toSet())
                result.success(null)
            }
            "status" -> result.success(status())
            "openCaptureSettings" -> {
                start(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                result.success(null)
            }
            "openBatterySettings" -> {
                start(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                result.success(null)
            }
            "openAppSettings" -> {
                start(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        .setData(Uri.fromParts("package", context.packageName, null)),
                )
                result.success(null)
            }
            "getSources" -> result.success(
                mapOf(
                    "allowed" to sources.allowed().toList(),
                    "defaults" to CaptureSources.DEFAULTS.toList(),
                    "defaultSms" to sources.defaultSmsPackage(),
                ),
            )
            "setSources" -> {
                val packages = call.argument<List<String>>("packages") ?: emptyList()
                sources.setAllowed(packages.toSet())
                result.success(null)
            }
            "requestSmsPermission" -> {
                activity()?.let { SmsSupport.requestPermission(it) }
                result.success(null)
            }
            "importSmsHistory" -> {
                val months = call.argument<Int>("months") ?: 1
                io.execute {
                    val count = SmsSupport.importHistory(context, months)
                    main.post { result.success(count) }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun status(): Map<String, Any?> = mapOf(
        "platform" to "android",
        "listenerEnabled" to CaptureNotificationListener.isEnabled(context),
        "smsSupported" to SmsSupport.SUPPORTED,
        "smsPermission" to SmsSupport.hasPermission(context),
        "lastCaptureAt" to CaptureStatus.lastCaptureAt(context),
        "queueSize" to queue.size(),
        "manufacturer" to Build.MANUFACTURER,
    )

    private fun start(intent: Intent) {
        val host = activity()
        if (host != null) {
            host.startActivity(intent)
        } else {
            context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }
}
