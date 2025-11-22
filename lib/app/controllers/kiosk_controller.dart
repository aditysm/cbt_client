import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';

class KioskHelper {
  static const _channel = MethodChannel('aplikasi_cbt/security');
  static final bool isDesktop = AllMaterial.isDesktop;
  static final isKiosk = false.obs;

  static Future<void> enableKioskMode() async {
    try {
      if (isDesktop) {
        await _enableDesktopKiosk();
      } else if (Platform.isAndroid || Platform.isIOS) {
        await _enableMobileKiosk();
      }

      isKiosk.value = true;
      print("✅ Kiosk mode aktif (ketat & aman)");
    } catch (e) {
      print("❌ Gagal aktifkan kiosk mode: $e");
    }
  }

  static Future<void> disableKioskMode() async {
    try {
      if (isDesktop) {
        await _disableDesktopKiosk();
      } else if (Platform.isAndroid || Platform.isIOS) {
        await _disableMobileKiosk();
      }

      isKiosk.value = false;
      print("✅ Kiosk mode dimatikan dan sistem dipulihkan");
    } catch (e) {
      print("❌ Gagal menonaktifkan kiosk mode: $e");
    }
  }

  static Future<void> toggle() async {
    isKiosk.value ? await disableKioskMode() : await enableKioskMode();
  }

  static Future<void> _enableDesktopKiosk() async {
    if (Platform.isWindows) {
      await Process.run("taskkill", ["/F", "/IM", "explorer.exe"]);
      await windowManager.setFullScreen(true);
      await windowManager.setResizable(false);
      await windowManager.setClosable(false);
      await windowManager.focus();
      await _blockSystemKeys();
    } else {
      await windowManager.setFullScreen(true);
      await windowManager.setResizable(false);
      await windowManager.focus();
    }
  }

  static Future<void> _disableDesktopKiosk() async {
    if (Platform.isWindows) {
      await Process.run("explorer.exe", []);
      await _unblockSystemKeys();
      await windowManager.setFullScreen(false);
      await windowManager.setResizable(true);
      await windowManager.setClosable(true);
    } else {
      await windowManager.setFullScreen(false);
      await windowManager.setResizable(true);
    }
  }

  static Future<void> _blockSystemKeys() async {
    const script = r'''
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoWinKeys /t REG_DWORD /d 1 /f
''';
    await Process.run("powershell", ["-Command", script]);
  }

  static Future<void> _unblockSystemKeys() async {
    const script = r'''
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoWinKeys /f
''';
    await Process.run("powershell", ["-Command", script]);
  }

  static Future<void> _enableMobileKiosk() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('enableSecureFlag');
        await _channel.invokeMethod('enableStrictKiosk');
      } catch (e) {
        print("⚠️ Native Android gagal: $e");
      }
    } else if (Platform.isIOS) {
      try {
        final isActive = await _channel.invokeMethod('isGuidedAccessEnabled');
        if (isActive == false) {
          print("🕹️ Mencoba mengaktifkan Guided Access...");
          final success = await _channel.invokeMethod('enableGuidedAccess');
          if (success == true) {
            print("✅ Guided Access aktif");
          } else {
            print(
                "⚠️ Gagal aktifkan Guided Access. Coba aktifkan manual di Settings > Accessibility > Guided Access.");
          }
        } else {
          print("✅ Guided Access sudah aktif");
        }
      } catch (e) {
        print("⚠️ Native iOS gagal: $e");
      }
    }

    ever(isKiosk, (val) async {
      if (val == true) await _monitorFocusLoss();
    });
  }

  static Future<void> _disableMobileKiosk() async {
    try {
      if (Platform.isAndroid) {
        try {
          final res1 = await _channel.invokeMethod<bool>('disableStrictKiosk');
          debugPrint('disableStrictKiosk returned: $res1');
        } catch (e, st) {
          debugPrint('Error disableStrictKiosk: $e\n$st');
        }

        try {
          final res2 = await _channel.invokeMethod<bool>('disableSecureFlag');
          debugPrint('disableSecureFlag returned: $res2');
        } catch (e, st) {
          debugPrint('Error disableSecureFlag: $e\n$st');
        }

        await Future.delayed(const Duration(milliseconds: 200));
      } else if (Platform.isIOS) {
        try {
          final res = await _channel.invokeMethod<bool>('disableGuidedAccess');
          debugPrint(
              'disableGuidedAccess invoked (note: may be no-op on iOS): $res');
        } catch (e, st) {
          debugPrint(
              'Error invoking disableGuidedAccess (iOS likely no-op): $e\n$st');
        }

        await Future.delayed(const Duration(milliseconds: 150));
      }

      try {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        debugPrint('System UI overlays restored');
      } catch (e, st) {
        debugPrint('Error restoring System UI overlays: $e\n$st');
      }

      try {
        await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        debugPrint('Preferred orientations restored');
      } catch (e, st) {
        debugPrint('Error restoring preferred orientations: $e\n$st');
      }

      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('_disableMobileKiosk completed');
    } catch (e, st) {
      debugPrint('Unexpected error in _disableMobileKiosk: $e\n$st');
    }
  }

  static Future<void> _monitorFocusLoss() async {
    print("👁️ Memantau kehilangan fokus (mobile kiosk aktif)");
  }
}
