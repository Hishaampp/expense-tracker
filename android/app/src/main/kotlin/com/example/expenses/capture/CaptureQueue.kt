package com.example.expenses.capture

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.io.RandomAccessFile

/**
 * Append-only queue of raw captures in app-private storage (spec §6.1).
 * One JSON object per line. Survives process death. Never logs content.
 *
 * Delivery is at-least-once: Dart drains, records, then acks the ids it
 * handled, and the Dart side de-duplicates.
 */
class CaptureQueue(context: Context) {
    private val file = File(context.filesDir, "capture_queue.jsonl")
    private val lockFile = File(context.filesDir, "capture_queue.lock")

    /** Adds [capture] to the end of the queue. */
    fun append(capture: JSONObject) = withLock {
        file.appendText(capture.toString() + "\n")
    }

    /** Every queued capture, oldest first. Unreadable lines are skipped. */
    fun readAll(): List<JSONObject> = withLock {
        if (!file.exists()) return@withLock emptyList()
        file.readLines().mapNotNull { line ->
            if (line.isBlank()) null else try {
                JSONObject(line)
            } catch (e: org.json.JSONException) {
                null
            }
        }
    }

    /** Removes the captures whose ids are in [ids]. */
    fun remove(ids: Set<String>) = withLock {
        if (!file.exists()) return@withLock
        val keep = file.readLines().filter { line ->
            if (line.isBlank()) return@filter false
            val id = try {
                JSONObject(line).optString("id")
            } catch (e: org.json.JSONException) {
                ""
            }
            id !in ids
        }
        val tmp = File(file.parentFile, "capture_queue.jsonl.tmp")
        tmp.writeText(if (keep.isEmpty()) "" else keep.joinToString("\n", postfix = "\n"))
        tmp.renameTo(file)
    }

    /** Number of queued captures. */
    fun size(): Int = readAll().size

    // A file lock guards against the app and a receiver writing at once;
    // the monitor guards threads within this process.
    private fun <T> withLock(block: () -> T): T = synchronized(LOCK) {
        RandomAccessFile(lockFile, "rw").use { raf ->
            raf.channel.lock().use { block() }
        }
    }

    companion object {
        private val LOCK = Any()
    }
}
