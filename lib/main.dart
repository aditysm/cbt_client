// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/controllers/connection_controller.dart';
import 'package:aplikasi_cbt/app/controllers/kiosk_controller.dart';
import 'package:aplikasi_cbt/app/controllers/volume_controller.dart';

import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/loading_splash.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  Get.putAsync(() async => ConnectionService().init());
  Get.putAsync<DatabaseService>(() async => DatabaseService(), permanent: true);
  Get.put(VolumeNativeController(), permanent: true);
  await KioskHelper.enableKioskMode();

  if (AllMaterial.isDesktop) {
    await windowManager.ensureInitialized();

    windowManager.waitUntilReadyToShow(
      AllMaterial.windowOptions,
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  } else {
    await AudioPlayer.global.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await GetStorage.init();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CBT Client",
      getPages: AppPages.routes,
      themeMode: ThemeMode.light,
      home: WillPopScope(
        onWillPop: () async => false,
        child: LoadingSplashView(
          title: "Tunggu Sebentar!",
          animationAsset: 'assets/images/loading.json',
          onCompleted: () async {
            try {
              final config = AllMaterial.box.read("db_config");

              if (config != null) {
                final dbService = Get.find<DatabaseService>();
                final box = AllMaterial.box;
                final host =
                    box.read('db_host') ?? AllMaterial.getDefaultDbHost;
                final port = box.read('db_port') ?? 3307;
                final user = box.read('db_user') ?? 'root';
                final password = box.read('db_pass') ?? 'root';
                final dbName = box.read('db_name') ?? 'cbt';

                final connected = await dbService.testConnection(
                  host: host,
                  port: port,
                  user: user,
                  password: password,
                  dbName: dbName,
                );

                if (connected) {
                  Get.offAll(() => LoginView());
                  ToastService.show("✅ Koneksi berhasil, silakan login!");
                } else {
                  Get.offAll(() => LoginView());
                  ToastService.show(
                      "❌ Koneksi gagal, harap konfigurasi ulang!");
                }
              } else {
                ToastService.show(
                  "⚠️ Koneksi tidak ditemukan, harap konfigurasi!",
                );
                Get.offAll(() => LoginView());
              }
            } catch (e) {
              final errorMessage =
                  AllMaterial.getErrorMessageFromException(e.toString());
              ToastService.show("❌ $errorMessage");
              Get.offAll(() => LoginView());
            }
          },
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundAlt,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.text),
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.text, fontSize: 14),
          bodySmall: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
        dividerColor: AppColors.divider,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textInverse,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryYellow,
          surface: AppColors.background,
          onPrimary: AppColors.textInverse,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.text,
          error: AppColors.error,
          onError: AppColors.textInverse,
        ),
      ),
    ),
  );
}
