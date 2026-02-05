package com.example.tringo_vendor_new


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class TringoCallReceiver : BroadcastReceiver() {

    private val TAG = "TRINGO_CALL_RX"

    override fun onReceive(context: Context, intent: Intent) {
        try {
            if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
                intent.action != "android.intent.action.PHONE_STATE"
            ) return

            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: ""
            val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""

            Log.d(TAG, "onReceive state=$state number=$incomingNumber")

            // ✅ Only start overlay when ringing (incoming call)
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                val phone = incomingNumber.ifBlank { "UNKNOWN" }

                // showOnCallEnd=false => show immediately on incoming
                TringoOverlayService.start(
                    context,
                    phone = phone,
                    contactName = "",
                    showOnCallEnd = false,
                    launchedByReceiver = true
                )
            }
        } catch (t: Throwable) {
            Log.e(TAG, "Receiver crash: ${t.message}", t)
        }
    }
}
