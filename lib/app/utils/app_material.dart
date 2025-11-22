// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:aplikasi_cbt/app/controllers/kiosk_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';

abstract class AllMaterial {
  static var box = GetStorage();

  static var role = "".obs;

  static WindowOptions windowOptions = WindowOptions(
    title: 'CBT Client',
    minimumSize: Size(600, 800),
    center: true,
    fullScreen: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static void showInfoBottomSheet({
    required String title,
    required String message,
    IconData icon = Icons.info,
    String buttonText = "OK",
    void Function()? onPressed,
    Color? color,
    Duration? duration,
    bool isDismissible = true,
  }) {
    final ctx = Get.context!;
    final theme = Theme.of(ctx);

    final canDismiss = duration == null ? isDismissible : false;

    Get.bottomSheet(
      isDismissible: canDismiss,
      enableDrag: canDismiss,
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (color ?? Colors.redAccent).withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
                color: color ?? Colors.redAccent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 22),
            if (duration == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (onPressed != null) {
                      onPressed();
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (duration != null) {
      Future.delayed(duration, () {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
      });
    }
  }

  static String getDefaultDbHost() {
    if (kIsWeb || isDesktop) return 'localhost';
    if (Platform.isAndroid) {
      return '127.0.0.1';
    } else if (Platform.isIOS) {
      return '127.0.0.1';
    } else {
      return '10.0.2.2';
    }
  }

  static String getErrorMessageFromException(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('connection') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network is unreachable') ||
        lowerError.contains('remote computer refused the network connection') ||
        lowerError.contains('socketexception') ||
        lowerError.contains('cannot write to socket') ||
        lowerError.contains('socket is closed')) {
      return "Ada masalah koneksi jaringan atau socket terputus. Periksa jaringan & ulangi!";
    }

    if (lowerError.contains('1156') ||
        lowerError.contains('packets out of order') ||
        lowerError.contains('08s01')) {
      return "Koneksi database tidak ditemukan & terputus. Coba lagi nanti!";
    } else if (lowerError.contains('timeout') ||
        lowerError.contains('semaphore timeout')) {
      return "Waktu koneksi habis. Silahkan coba lagi!";
    } else if (lowerError.contains('unauthorized') ||
        lowerError.contains('401') ||
        lowerError.contains('access denied')) {
      return "Akses ditolak. Periksa username dan password!";
    } else if (lowerError.contains('database') &&
        lowerError.contains('unknown')) {
      return "Database tidak ditemukan. Periksa nama database!";
    } else if (lowerError.contains('error 1045')) {
      return "Access denied: Username atau password server salah!";
    } else if (lowerError.contains('error 1049')) {
      return "Database tidak ada (1049). Periksa konfigurasi!";
    } else if (lowerError.contains('error 2003')) {
      return "Tidak bisa terhubung ke server. Periksa host/port!";
    } else if (lowerError.contains('error 1064')) {
      return "Kesalahan sintaks SQL (1064). Periksa query!";
    } else if (lowerError.contains('not found') || lowerError.contains('404')) {
      return "Data tidak ditemukan!";
    } else if (lowerError.contains('server error') ||
        lowerError.contains('500')) {
      return "Terjadi kesalahan pada server. Silahkan coba lagi nanti!";
    } else if (lowerError.contains('no element')) {
      return "User tidak ditemukan. Periksa input Anda!";
    }

    return "Terjadi kesalahan: $error";
  }

  static Future<void> exitApp({bool fromUjian = false}) async {
    return AllMaterial.cusDialogValidasi(
      title: "Keluar dari Aplikasi",
      subtitle: "Apakah Anda yakin ingin menutup aplikasi?",
      confirmText: "LANJUT",
      cancelText: "BATAL",
      onCancel: () => Get.back(),
      onConfirm: () {
        Get.back();

        if (fromUjian) {
          AllMaterial.cusDialogValidasi(
            title: "Progres Ujian akan hilang.",
            subtitle: "Apakah Anda ingin menutup aplikasi sekarang?",
            confirmText: "LANJUT",
            cancelText: "BATAL",
            onCancel: () => Get.back(),
            onConfirm: () {
              Get.back();
              executeExit();
            },
          );
        } else {
          executeExit();
        }
      },
    );
  }

  static void executeExit() async {
    try {
      await KioskHelper.disableKioskMode();
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      } else {
        exit(0);
      }
    } catch (e) {
      exit(0);
    }
  }

  static String formatDuration(Duration? d) {
    if (d == null) return "-";
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  static String formatJurusan(String jurusan) {
    switch (jurusan.toUpperCase()) {
      case 'RPL':
        return "Rekayasa Perangkat Lunak";
      case 'BDG':
        return "Bisnis Digital";
      case 'BRT':
        return "Bisnis Retail";
      case 'ULW':
        return "Usaha Layanan Wisata";
      case 'AKL':
        return "Akuntansi & Keuangan Lembaga";
      case 'LPS':
        return "Layanan Perbankan Syariah";
      case 'MPK':
        return "Manajemen Perkantoran";
      case 'TKJ':
        return "Teknik Komputer & Jaringan";
      default:
        return jurusan;
    }
  }

  static final RxBool _confirmEnabled = true.obs;

  static void updateConfirmState(bool enabled) {
    Future.microtask(() => _confirmEnabled.value = enabled);
  }

  static void cusDialogValidasi({
    required VoidCallback? onConfirm,
    String? title,
    String? subtitle,
    VoidCallback? onCancel,
    bool showCancel = true,
    bool activeConfirm = true,
    IconData icon = Icons.info_outline,
    String confirmText = "LANJUT",
    String cancelText = "BATAL",
    Widget? customContent,
    Color iconColor = Colors.red,
  }) {
    _confirmEnabled.value = activeConfirm;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 32, color: iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (customContent != null)
                  customContent
                else if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15),
                  ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showCancel)
                      TextButton(
                        onPressed: onCancel ?? () => Get.back(),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (showCancel) const SizedBox(width: 12),
                    Obx(
                      () => ElevatedButton(
                        onPressed: _confirmEnabled.value ? onConfirm : null,
                        autofocus: true,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: showCancel,
    );
  }

  static void bindLoadingDialog(RxBool isLoading) {
    ever<bool>(isLoading, (loading) {
      if (loading) {
        if (Get.isDialogOpen != true) {
          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            barrierColor: Colors.black.withOpacity(0.2),
            barrierDismissible: false,
          );
        }
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }
    });
  }

  static void cusDialogInput({
    required String title,
    required ValueChanged<String> onChanged,
    required VoidCallback onTap,
    String hintText = "Masukkan kata kunci...",
    IconData icon = Icons.key,
    String buttonText = "KONFIRMASI",
  }) {
    final textController = TextEditingController();
    final textFocus = FocusNode();

    textFocus.requestFocus();

    InputDecoration inputDecoration({
      required IconData icon,
      String? errorText,
    }) {
      return InputDecoration(
        errorText: (errorText?.isEmpty ?? true) ? null : errorText,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      );
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  controller: textController,
                  focusNode: textFocus,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  autofocus: true,
                  decoration: inputDecoration(icon: icon),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "BATAL",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        onTap.call();
                      },
                      autofocus: true,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "LANJUT",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
