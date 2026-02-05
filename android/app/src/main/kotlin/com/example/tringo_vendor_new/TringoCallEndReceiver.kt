package com.example.tringo_vendor_new


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class TringoCallEndReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "TRINGO_CALL_END_RX"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_STATE = "last_state"
        private const val KEY_LAST_NUMBER = "last_number"
        private const val KEY_USER_CLOSED = "user_closed_during_call"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""

        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
        val savedNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
        val userClosed = prefs.getBoolean(KEY_USER_CLOSED, false)

        if (number.isNotBlank()) prefs.edit().putString(KEY_LAST_NUMBER, number).apply()

        val finalNumber = when {
            number.isNotBlank() -> number
            savedNumber.isNotBlank() -> savedNumber
            else -> "UNKNOWN"
        }

        Log.d(TAG, "state=$stateStr lastState=$lastState final=$finalNumber closed=$userClosed")

        val endedNow =
            (lastState == TelephonyManager.EXTRA_STATE_RINGING || lastState == TelephonyManager.EXTRA_STATE_OFFHOOK) &&
                    stateStr == TelephonyManager.EXTRA_STATE_IDLE

        if (endedNow && userClosed) {
            TringoOverlayService.start(
                ctx = context.applicationContext,
                phone = finalNumber,
                contactName = "",
                showOnCallEnd = true,
                launchedByReceiver = true
            )
            prefs.edit().putBoolean(KEY_USER_CLOSED, false).apply()
        }

        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
    }
}
