package com.example.tringo_vendor_new


import android.Manifest
import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.app.role.RoleManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sim_info"
    private val TAG = "TRINGO_NATIVE"

    private val REQ_ROLE_CALL_SCREENING = 9001
    private var pendingRoleResult: MethodChannel.Result? = null

    private val REQ_ROLE_DIALER = 9002
    private var pendingDialerResult: MethodChannel.Result? = null

    private val REQ_PHONE_STATE = 9101
    private var pendingPhonePermResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "requestReadPhoneState" -> requestReadPhoneStateNative(result)

                    "debugPhonePerm" -> {
                        val ok = hasReadPhoneState()
                        Log.d(TAG, "debugPhonePerm => READ_PHONE_STATE granted=$ok")
                        result.success(ok)
                    }

                    "isBackgroundRestricted" -> {
                        try {
                            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                            val restricted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                am.isBackgroundRestricted
                            } else false
                            Log.d(TAG, "isBackgroundRestricted => $restricted")
                            result.success(restricted)
                        } catch (e: Exception) {
                            Log.e(TAG, "isBackgroundRestricted failed: ${e.message}", e)
                            result.success(false)
                        }
                    }

                    "openBatteryUnrestrictedSettings" -> {
                        openBatteryUnrestrictedSettingsBestEffort()
                        result.success(true)
                    }

                    "openBatterySettingsDirect" -> {
                        openAppDetails()
                        result.success(true)
                    }

                    "isAppInPowerSaveMode" -> result.success(isAppInPowerSaveMode())

                    "getSimInfo" -> result.success(getSimInfoNative())

                    "isDefaultCallerIdApp" -> {
                        val ok = isTringoDefaultCallerIdSpam(this)
                        Log.d(TAG, "isDefaultCallerIdApp => $ok")
                        result.success(ok)
                    }

                    "requestDefaultCallerIdApp" -> requestSetAsDefaultCallerIdSpam(result)

                    "isDefaultDialerApp" -> {
                        val ok = isTringoDefaultDialer(this)
                        Log.d(TAG, "isDefaultDialerApp => $ok")
                        result.success(ok)
                    }

                    "requestDefaultDialerApp" -> requestSetAsDefaultDialer(result)

                    "isOverlayGranted" -> {
                        val ok = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(this)
                        } else true
                        result.success(ok)
                    }

                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
                            startActivity(intent)
                        }
                        result.success(true)
                    }

                    "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())

                    "requestIgnoreBatteryOptimization" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                    data = Uri.parse("package:$packageName")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                                result.success(true)
                            } else {
                                openAppDetails()
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "requestIgnoreBatteryOptimization failed: ${e.message}", e)
                            openAppDetails()
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun requestReadPhoneStateNative(result: MethodChannel.Result) {
        if (hasReadPhoneState()) {
            result.success(true)
            return
        }

        if (pendingPhonePermResult != null) {
            result.success(false)
            return
        }

        pendingPhonePermResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_PHONE_STATE),
            REQ_PHONE_STATE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQ_PHONE_STATE) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            Log.d(TAG, "READ_PHONE_STATE permission result => $granted")
            pendingPhonePermResult?.success(granted)
            pendingPhonePermResult = null
        }
    }

    private fun hasReadPhoneState(): Boolean {
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "READ_PHONE_STATE granted: $granted")
        return granted
    }

    private fun isTringoDefaultCallerIdSpam(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val rm = context.getSystemService(RoleManager::class.java)
            rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        } else false
    }

    private fun requestSetAsDefaultCallerIdSpam(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val rm = getSystemService(RoleManager::class.java)

                if (!rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                    startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                    result.success(false)
                    return
                }

                if (pendingRoleResult != null) {
                    result.success(isTringoDefaultCallerIdSpam(this))
                    return
                }

                pendingRoleResult = result
                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, REQ_ROLE_CALL_SCREENING)
            } else {
                startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "requestDefaultCallerIdApp failed: ${e.message}", e)
            result.success(false)
        }
    }

    private fun isTringoDefaultDialer(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val rm = context.getSystemService(RoleManager::class.java)
            rm.isRoleHeld(RoleManager.ROLE_DIALER)
        } else false
    }

    private fun requestSetAsDefaultDialer(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val rm = getSystemService(RoleManager::class.java)

                if (!rm.isRoleAvailable(RoleManager.ROLE_DIALER)) {
                    startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                    result.success(false)
                    return
                }

                if (pendingDialerResult != null) {
                    result.success(isTringoDefaultDialer(this))
                    return
                }

                pendingDialerResult = result
                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, REQ_ROLE_DIALER)
            } else {
                startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "requestDefaultDialerApp failed: ${e.message}", e)
            result.success(false)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQ_ROLE_CALL_SCREENING) {
            val granted = isTringoDefaultCallerIdSpam(this)
            pendingRoleResult?.success(granted)
            pendingRoleResult = null
            return
        }

        if (requestCode == REQ_ROLE_DIALER) {
            val granted = isTringoDefaultDialer(this)
            pendingDialerResult?.success(granted)
            pendingDialerResult = null
            return
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                pm.isIgnoringBatteryOptimizations(packageName)
            } else true
        } catch (e: Exception) {
            false
        }
    }

    private fun isAppInPowerSaveMode(): Boolean {
        return try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            pm.isPowerSaveMode
        } catch (e: Exception) {
            false
        }
    }

    private fun openBatteryUnrestrictedSettingsBestEffort() {
        if (openAppDetails()) return

        if (isPackageInstalled("com.miui.securitycenter")) {
            if (tryStart(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))) return
            if (tryStart(ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerMainActivity"))) return
        }

        tryStart(Intent(Settings.ACTION_SETTINGS))
    }

    private fun openAppDetails(): Boolean {
        return tryStart(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        )
    }

    private fun tryStart(intent: Intent): Boolean {
        return try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun tryStart(component: ComponentName): Boolean {
        return try {
            val intent = Intent().apply {
                this.component = component
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun isPackageInstalled(pkg: String): Boolean {
        return try {
            packageManager.getPackageInfo(pkg, 0)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun getSimInfoNative(): List<Map<String, Any?>> {
        if (!hasReadPhoneState()) return emptyList()

        val subscriptionManager = getSystemService(SubscriptionManager::class.java) ?: return emptyList()

        val list: List<SubscriptionInfo> = try {
            subscriptionManager.activeSubscriptionInfoList ?: emptyList()
        } catch (_: SecurityException) {
            emptyList()
        }

        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        return list.map { info ->
            var number: String? = null
            try { number = info.number } catch (_: SecurityException) {}

            if (number.isNullOrEmpty()) {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        val tmForSub = telephonyManager.createForSubscriptionId(info.subscriptionId)
                        number = tmForSub.line1Number
                    }
                } catch (_: Exception) {}
            }

            mapOf(
                "slotIndex" to info.simSlotIndex,
                "displayName" to info.displayName?.toString(),
                "carrierName" to info.carrierName?.toString(),
                "countryIso" to info.countryIso,
                "number" to (number ?: "")
            )
        }
    }
}



//package com.example.tringo_vendor_new
//
//import android.content.Intent
//import android.net.Uri
//import android.os.Build
//import android.os.Bundle
//import android.os.PowerManager
//import android.provider.Settings
//import android.util.Log
//import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//
//    private val CHANNEL = "sim_info"
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//
//                    "isIgnoringBatteryOptimizations" -> {
//                        try {
//                            val pm = getSystemService(POWER_SERVICE) as PowerManager
//                            val ignoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                                pm.isIgnoringBatteryOptimizations(packageName)
//                            } else true
//                            result.success(ignoring)
//                        } catch (e: Exception) {
//                            result.success(false)
//                        }
//                    }
//
//                    "requestIgnoreBatteryOptimization" -> {
//                        try {
//                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
//                                intent.data = Uri.parse("package:$packageName")
//                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                                startActivity(intent)
//                            }
//                            result.success(true)
//                        } catch (e: Exception) {
//                            result.success(false)
//                        }
//                    }
//
//                    "openBatteryUnrestrictedSettings" -> {
//                        try {
//                            openBatterySettingsBestEffort()
//                            result.success(true)
//                        } catch (e: Exception) {
//                            result.success(false)
//                        }
//                    }
//
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    private fun openBatterySettingsBestEffort() {
//        val pkg = packageName
//
//        // ✅ 1) App details (ALWAYS works)
//        if (tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
//                data = Uri.parse("package:$pkg")
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            })
//        ) return
//
//        // ✅ 2) Request ignore battery optimizations screen
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (tryStart(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
//                    data = Uri.parse("package:$pkg")
//                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                })
//            ) return
//        }
//
//        // ✅ 3) Battery optimization list (fallback)
//        tryStart(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
//            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//        })
//    }
//
//    private fun tryStart(intent: Intent): Boolean {
//        return try {
//            startActivity(intent)
//            true
//        } catch (e: Exception) {
//            Log.e("Tringo", "Failed to open settings: ${e.message}")
//            false
//        }
//    }
//}
//
////package com.example.tringo_vendor_new
////
////import io.flutter.embedding.android.FlutterActivity
////
////class MainActivity : FlutterActivity()
