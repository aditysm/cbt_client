package com.aplikasi_cbt.aplikasi_cbt

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SECURITY_CHANNEL = "aplikasi_cbt/security"
    private val TOAST_CHANNEL = "native_toast"   

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
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
                        runOnUiThread { window.addFlags(WindowManager.LayoutParams.FLAG_SECURE) }
                        result.success(null)
                    }

                    "disableSecureFlag" -> {
                        runOnUiThread { window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE) }
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

        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TOAST_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "show" -> {
                        val message = call.argument<String>("message") ?: ""
                        showNativeToast(message)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    
    private fun showNativeToast(message: String) {
        runOnUiThread {
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
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
            runOnUiThread { window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE) }
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
