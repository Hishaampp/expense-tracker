package com.example.expenses.capture

import android.app.Activity
import android.content.Context

/**
 * The Play build never reads SMS (spec §6.2: Play allows SMS permissions
 * only for default SMS apps). This stub keeps the shared code flavor-free.
 */
object SmsSupport {
    const val SUPPORTED = false

    fun hasPermission(context: Context): Boolean = false

    fun requestPermission(activity: Activity) = Unit

    fun importHistory(context: Context, months: Int): Int = 0
}
