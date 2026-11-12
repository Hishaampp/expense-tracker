package com.example.expenses.upi

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Scan & Pay (Phase 11): lists the installed UPI apps and opens one with a
 * payment link. The UPI app answers through [onResult] with a line such as
 * `Status=SUCCESS&txnRef=…`, passed to Dart as it is. This app never
 * handles money or the UPI PIN.
 */
class UpiChannel(
    private val context: Context,
    messenger: BinaryMessenger,
    private val launch: (Intent) -> Unit,
) : MethodChannel.MethodCallHandler {
    private var pending: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "app/upi").setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "apps" -> result.success(apps())
            "pay" -> pay(call, result)
            else -> result.notImplemented()
        }
    }

    private fun apps(): List<Map<String, String>> {
        val pm = context.packageManager
        val probe = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
        return pm.queryIntentActivities(probe, 0)
            .map { it.activityInfo.packageName to it.loadLabel(pm).toString() }
            .distinctBy { it.first }
            .filter { it.first != context.packageName }
            .map { (id, name) -> mapOf("id" to id, "name" to name) }
    }

    private fun pay(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")
        val app = call.argument<String>("app")
        if (uri == null || app == null || !uri.startsWith("upi://pay")) {
            result.error("bad_args", "A upi://pay link and an app are needed.", null)
            return
        }
        // A payment still waiting for its answer gets none now.
        pending?.success(null)
        pending = result
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri)).setPackage(app)
        try {
            launch(intent)
        } catch (e: Exception) {
            pending = null
            result.error("not_opened", "The UPI app could not be opened.", null)
        }
    }

    /** The UPI app's answer; null when it gave none (backed out). */
    fun onResult(data: Intent?) {
        val response = data?.getStringExtra("response")
            ?: data?.extras?.keySet()?.firstOrNull { it.equals("response", true) }
                ?.let { data.extras?.getString(it) }
        pending?.success(response)
        pending = null
    }
}
