import 'dart:io';
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
      print("✅ Kiosk mode aktif (ketat & lintas platform)");
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
      print("✅ Kiosk mode dinonaktifkan dan sistem pulih");
    } catch (e) {
      print("❌ Gagal nonaktifkan kiosk mode: $e");
    }
  }

  static Future<void> toggle() async {
    if (isKiosk.value) {
      await disableKioskMode();
    } else {
      await enableKioskMode();
    }
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
        await _channel.invokeMethod('enableKioskMode');
      } catch (e) {
        print("⚠️ Gagal panggil native Android: $e");
      }
    }

    ever(isKiosk, (val) async {
      if (val == true) {
        await _monitorFocusLoss();
      }
    });
  }

  static Future<void> _disableMobileKiosk() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('disableKioskMode');
        await _channel.invokeMethod('disableSecureFlag');
      } catch (e) {
        print("⚠️ Gagal nonaktifkan native Android: $e");
      }
    }
  }

  static Future<void> _monitorFocusLoss() async {
    print("👁️ Memantau kehilangan fokus (mobile kiosk aktif)");
  }
}
