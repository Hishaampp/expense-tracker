package com.example.expenses.capture

import android.content.Context
import android.provider.Telephony

/**
 * Which apps' notifications may be read (spec §6.2): an allowlist the user
 * can edit in Settings → Capture sources. Kept in SharedPreferences so the
 * listener can read it without Flutter running.
 */
class CaptureSources(private val context: Context) {
    private val prefs = context.getSharedPreferences("capture_sources", Context.MODE_PRIVATE)

    /** The packages currently allowed. */
    fun allowed(): Set<String> {
        val saved = prefs.getStringSet(KEY, null)
        val base = saved ?: DEFAULTS
        // The phone's own default SMS app is always included unless the user
        // removed it, so OEM messaging apps work without a hardcoded name.
        val sms = defaultSmsPackage()
        val removed = prefs.getStringSet(KEY_REMOVED, emptySet()) ?: emptySet()
        return if (sms != null && sms !in removed) base + sms else base
    }

    /** Replaces the allowlist with [packages]. */
    fun setAllowed(packages: Set<String>) {
        val sms = defaultSmsPackage()
        val removed = if (sms != null && sms !in packages) setOf(sms) else emptySet()
        prefs.edit()
            .putStringSet(KEY, packages)
            .putStringSet(KEY_REMOVED, removed)
            .apply()
    }

    /** The phone's default SMS app, or null. */
    fun defaultSmsPackage(): String? = try {
        Telephony.Sms.getDefaultSmsPackage(context)
    } catch (e: SecurityException) {
        null
    }

    companion object {
        private const val KEY = "allowed"
        private const val KEY_REMOVED = "removed_default_sms"

        /**
         * Shipped defaults. VERIFIED from the spec's list; OEM messaging apps
         * are covered by [defaultSmsPackage] at runtime instead of guessed
         * names.
         */
        val DEFAULTS = setOf(
            "com.google.android.apps.messaging", // Google Messages
            "com.samsung.android.messaging", // Samsung Messages
            "com.google.android.apps.nbu.paisa.user", // Google Pay (India)
            "com.phonepe.app", // PhonePe
            "net.one97.paytm", // Paytm
            "in.org.npci.upiapp", // BHIM
        )
    }
}
