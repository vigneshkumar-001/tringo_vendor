package com.example.tringo_vendor_new


import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager

class TringoIncomingPopupActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        setContentView(R.layout.tringo_overlay)

        val phone = intent.getStringExtra("phone") ?: ""
        val contactName = intent.getStringExtra("contactName") ?: ""

        val svc = Intent(this, TringoOverlayService::class.java).apply {
            putExtra("phone", phone)
            putExtra("contactName", contactName)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(svc) else startService(svc)

        findViewById<android.view.View>(R.id.closeBtn)?.setOnClickListener {
            stopService(Intent(this, TringoOverlayService::class.java))
            finish()
        }
    }

    override fun onDestroy() {
        stopService(Intent(this, TringoOverlayService::class.java))
        super.onDestroy()
    }
}