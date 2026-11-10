package com.example.expenses

import android.content.Intent
import android.os.Bundle
import com.example.expenses.capture.CaptureChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var capture: CaptureChannel? = null
    private var pendingShare: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        capture = CaptureChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
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
