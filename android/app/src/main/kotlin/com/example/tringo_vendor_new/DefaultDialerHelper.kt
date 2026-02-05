package com.example.tringo_vendor_new


import android.app.Activity
import android.app.role.RoleManager
import android.os.Build

object DefaultDialerHelper {

    const val REQ_ROLE_DIALER = 999

    fun requestDefaultDialer(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = activity.getSystemService(RoleManager::class.java)
            if (!roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                activity.startActivityForResult(intent, REQ_ROLE_DIALER)
            }
        }
    }
}