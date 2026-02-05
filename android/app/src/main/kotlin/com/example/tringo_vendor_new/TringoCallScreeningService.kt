package com.example.tringo_vendor_new


import android.net.Uri
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class TringoCallScreeningService : CallScreeningService() {

    private val TAG = "TRINGO_SCREEN"

    override fun onScreenCall(callDetails: Call.Details) {
        try {
            val handle: Uri? = callDetails.handle // tel:9876543210
            val number = handle?.schemeSpecificPart?.trim().orEmpty()

            Log.d(TAG, "onScreenCall number=$number")

            // ✅ IMPORTANT:
            // CallScreeningService mainly works for INCOMING screening.
            // Outgoing trigger-க்கு InCallService தான் reliable.
            // But compile error fix + optional incoming hook:
            if (number.isNotBlank()) {
                // If you want immediate overlay on incoming:
                // TringoOverlayService.start(this, number, "", showOnCallEnd = false)

                // If you want after call ends for incoming:
                TringoOverlayService.start(this, number, "", showOnCallEnd = true)
            }

            // ✅ MUST respond, otherwise system treats as not handled
            val response = CallResponse.Builder()
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSkipCallLog(false)
                .setSkipNotification(false)
                .build()

            respondToCall(callDetails, response)

        } catch (e: Exception) {
            Log.e(TAG, "onScreenCall error: ${e.message}", e)

            // safe default response
            val response = CallResponse.Builder().build()
            respondToCall(callDetails, response)
        }
    }
}