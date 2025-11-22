// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/controllers/connection_controller.dart';
import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/controllers/kiosk_controller.dart';
import 'package:aplikasi_cbt/app/controllers/volume_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';

import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_scroll.dart';
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
  Get.put(GeneralController());
  await KioskHelper.enableKioskMode();

  AllMaterial.box.write('setting_pass', "12345678");

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
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  final dbService = Get.find<DatabaseService>();
  final box = AllMaterial.box;
  final host = box.read('db_host') ?? "192.100.0.254";
  final port = box.read('db_port') ?? 3306;
  final user = box.read('db_user') ?? 'cbtclient';
  final password = box.read('db_pass') ?? '12345678@CBTclient';
  final dbName = box.read('db_name') ?? 'dbcbt';

  await GetStorage.init();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CBT SMKN 2 Mataram",
      getPages: AppPages.routes,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 350),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const NoAlwaysScrollableBehavior(),
          child: child!,
        );
      },
      home: WillPopScope(
        onWillPop: () async => false,
        child: Builder(builder: (context) {
          return LoadingSplashView(
            title: "Tunggu Sebentar!",
            animationAsset: 'assets/images/loading.json',
            onCompleted: () async {
              try {
                final connected = await dbService.testConnection(
                  host: host,
                  port: port,
                  user: user,
                  password: password,
                  dbName: dbName,
                );

                if (connected) {
                  box.write('db_config', "config_success");
                  box.write('db_server_name', dbName);
                  box.write('db_host', host);
                  box.write('db_port', 3306);
                  box.write('db_user', user);
                  box.write('db_pass', password);
                  box.write('db_name', dbName);
                }

                Get.offAll(() => LoginView());

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    AllMaterial.showInfoBottomSheet(
                      title: connected
                          ? "Koneksi Berhasil"
                          : "Sistem tidak dapat mengakses server!",
                      message: connected
                          ? "Server berhasil terhubung. Anda bisa melanjutkan ke proses login."
                          : "Periksa jaringan Anda, atau hubungi operator untuk mendapatkan bantuan.",
                      icon: connected ? Icons.check : Icons.error,
                      color: connected ? Colors.greenAccent : Colors.redAccent,
                      onPressed: () async {
                        if (connected) {
                          Get.back();
                          await Future.delayed(Durations.medium2);
                          LoginController.startLogin();
                        } else {
                          Get.back();
                        }
                      },
                      buttonText: "Tutup",
                    );
                  },
                );
              } catch (e) {
                ToastService.show(
                    AllMaterial.getErrorMessageFromException(e.toString()));
                print(e.toString());
              }
            },
          );
        }),
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
