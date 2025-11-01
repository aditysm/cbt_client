package com.aplikasi_cbt.aplikasi_cbt

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "aplikasi_cbt/security"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureFlag" -> {
                    window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                "disableSecureFlag" -> {
                    window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                "enableKioskMode" -> {
                    try {
                        startLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LOCKTASK_ERROR", e.message, null)
                    }
                }
                "disableKioskMode" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LOCKTASK_STOP_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
