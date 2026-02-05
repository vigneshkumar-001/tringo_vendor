package com.example.tringo_vendor_new


import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.telecom.Call
import android.telecom.InCallService
import android.util.Log

class TringoInCallService : InCallService() {

    private val TAG = "TRINGO_INCALL"

    private var lastNumber: String = ""
    private var shownForThisCall = false
    private var cb: Call.Callback? = null

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)

        shownForThisCall = false
        lastNumber = extractNumber(call)

        Log.d(TAG, "✅ onCallAdded state=${call.state} number=$lastNumber")

        val callback = object : Call.Callback() {
            override fun onStateChanged(call: Call, state: Int) {
                super.onStateChanged(call, state)

                val n = extractNumber(call)
                if (n.isNotBlank()) lastNumber = n

                Log.d(TAG, "onStateChanged state=$state number=$lastNumber shown=$shownForThisCall")

                if (!shownForThisCall && state == Call.STATE_DISCONNECTED) {
                    shownForThisCall = true
                    startOverlayAfterDelay(lastNumber, "DISCONNECTED")
                }
            }
        }

        cb = callback
        try {
            // ✅ More stable
            call.registerCallback(callback, Handler(Looper.getMainLooper()))
        } catch (e: Exception) {
            Log.e(TAG, "registerCallback failed: ${e.message}", e)
        }
    }

    override fun onCallRemoved(call: Call) {
        Log.d(TAG, "✅ onCallRemoved number=$lastNumber shown=$shownForThisCall")

        if (!shownForThisCall && lastNumber.isNotBlank()) {
            shownForThisCall = true
            startOverlayAfterDelay(lastNumber, "onCallRemoved")
        }

        try {
            cb?.let { call.unregisterCallback(it) }
        } catch (_: Exception) {}
        cb = null

        super.onCallRemoved(call)
    }

    private fun startOverlayAfterDelay(number: String, from: String) {
        if (number.isBlank()) {
            Log.w(TAG, "startOverlayAfterDelay skipped (empty number) from=$from")
            return
        }

        Handler(Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "🚀 Starting overlay AFTER call end ($from) for: $number")
            TringoOverlayService.start(
                ctx = applicationContext,
                phone = number,
                contactName = "",
                showOnCallEnd = false
            )
        }, 900)
    }

    private fun extractNumber(call: Call): String {
        return try {
            val handle: Uri? = call.details?.handle
            (handle?.schemeSpecificPart ?: "").trim()
        } catch (e: Exception) {
            Log.e(TAG, "extractNumber failed: ${e.message}", e)
            ""
        }
    }
}