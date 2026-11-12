package com.example.expenses

import android.content.Intent
import android.os.Bundle
import androidx.activity.result.contract.ActivityResultContracts
import com.example.expenses.capture.CaptureChannel
import com.example.expenses.upi.UpiChannel
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private var capture: CaptureChannel? = null
    private var upi: UpiChannel? = null
    private var pendingShare: Intent? = null

    // Registered with the activity, so a UPI app's answer is delivered even
    // after the app was restored.
    private val upiLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            upi?.onResult(it.data)
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        capture = CaptureChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        ) { this }
        upi = UpiChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        ) { upiLauncher.launch(it) }
        pendingShare?.let { handleShare(it) }
        pendingShare = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Only a fresh launch carries the share; a restored activity has
        // already handled it.
        if (savedInstanceState == null) handleShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShare(intent)
    }

    private fun handleShare(intent: Intent?) {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return
        val channel = capture
        if (channel == null) {
            pendingShare = intent
            return
        }
        channel.enqueueShare(text, referrer?.host)
        // Consume it, so a configuration change does not queue it again.
        intent.action = null
    }
}
