package com.example.tringo_vendor_new

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sim_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "isIgnoringBatteryOptimizations" -> {
                        try {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            val ignoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                pm.isIgnoringBatteryOptimizations(packageName)
                            } else true
                            result.success(ignoring)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "requestIgnoreBatteryOptimization" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                intent.data = Uri.parse("package:$packageName")
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "openBatteryUnrestrictedSettings" -> {
                        try {
                            openBatterySettingsBestEffort()
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun openBatterySettingsBestEffort() {
        val pkg = packageName

        // ✅ 1) App details (ALWAYS works)
        if (tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
        ) return

        // ✅ 2) Request ignore battery optimizations screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (tryStart(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$pkg")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                })
            ) return
        }

        // ✅ 3) Battery optimization list (fallback)
        tryStart(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        })
    }

    private fun tryStart(intent: Intent): Boolean {
        return try {
            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e("Tringo", "Failed to open settings: ${e.message}")
            false
        }
    }
}

//package com.example.tringo_vendor_new
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()
