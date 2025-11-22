package com.aplikasi_cbt.aplikasi_cbt

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "aplikasi_cbt/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                

                "enableStrictKiosk" -> {
                    enableStrictKiosk()
                    result.success(null)
                }

                "enableKioskMode" -> {
                    enableKioskMode()
                    result.success(null)
                }
                "enableSecureFlag" -> {
                    runOnUiThread {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
                "disableSecureFlag" -> {
                    runOnUiThread {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }

                "disableStrictKiosk" -> {
                    disableStrictKiosk()
                    result.success(null)
                }

                "disableKioskMode" -> {
                    disableKioskMode()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun enableStrictKiosk() {
        try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val admin = ComponentName(this, MyDeviceAdminReceiver::class.java)
            if (dpm.isDeviceOwnerApp(packageName)) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    dpm.setLockTaskPackages(admin, arrayOf(packageName))
                    startLockTask()
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            } else {
                startLockTask()
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun disableStrictKiosk() {
        try {
            stopLockTask()
            runOnUiThread {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }



    private fun enableKioskMode() {
        try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val admin = ComponentName(this, MyDeviceAdminReceiver::class.java)
            if (dpm.isDeviceOwnerApp(packageName)) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    dpm.setLockTaskPackages(admin, arrayOf(packageName))
                    startLockTask()
                }
            } else {
                startLockTask()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun disableKioskMode() {
        try {
            stopLockTask()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
