package com.example.expenses.upi

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Scan & Record (Phase 11): lists the installed UPI apps and opens one on
 * its own home screen, where the payer scans and pays as usual. UPI apps
 * refuse or limit payments another app starts, so no payment link is
 * passed. This app never handles money or the UPI PIN.
 */
class UpiChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    init {
        MethodChannel(messenger, "app/upi").setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "apps" -> result.success(apps())
            "open" -> result.success(open(call.argument<String>("app")))
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

    private fun open(app: String?): Boolean {
        if (app == null) return false
        val launch = context.packageManager.getLaunchIntentForPackage(app) ?: return false
        return try {
            context.startActivity(launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: Exception) {
            false
        }
    }
}
