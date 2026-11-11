package com.example.expenses.capture

/**
 * The only parsing native code does (spec §6.1): is there a rupee amount at
 * all? Anything without one is never stored, so personal chats never reach
 * the queue.
 */
object CaptureFilter {
    private val amount = Regex(
        """(?:₹|\bRs\.?|\bINR)\s*\d""",
        RegexOption.IGNORE_CASE,
    )

    fun hasAmount(text: String): Boolean = amount.containsMatchIn(text)
}
