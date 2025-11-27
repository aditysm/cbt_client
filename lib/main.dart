// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/controllers/connection_controller.dart';
import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/controllers/kiosk_controller.dart';
import 'package:aplikasi_cbt/app/controllers/volume_controller.dart';
import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_scroll.dart';
import 'package:aplikasi_cbt/app/utils/loading_splash.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  await GetStorage.init();

  Get.putAsync(() async => ConnectionService().init());
  Get.put(VolumeNativeController(), permanent: true);
  Get.put(GeneralController());

  WakelockPlus.enable();


  await KioskHelper.enableKioskMode();

  AllMaterial.box.write('setting_pass', "12345678");
  AllMaterial.box.remove("token");

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
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  runApp(AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: _StartupScreen(),
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
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
    );
  }
}

class _StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingSplashView(
        title: "Tunggu Sebentar!",
        animationAsset: 'assets/images/loading.json',
        onCompleted: () async {
          try {
            await checkConnection();
          } catch (e) {
            ToastService.show(
              AllMaterial.getErrorMessageFromException(e.toString()),
            );
          }
        },
      ),
    );
  }
}

Future<void> checkConnection() async {
  int? statusCode;

  final response = await HttpService.request(
    url: ApiUrl.testConnection,
    type: RequestType.get,
    onError: (_) => _showErrorBuilderSheet(),
    onStuck: (error) => print(error),
    onStatus: (code) {
      statusCode = code;
    },
  );

  if (response == null || statusCode == null || statusCode! >= 400) {
    LoginController.allError.value =
        "Ada masalah dengan koneksi, periksa konfigurasi & coba lagi nanti!";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorBuilderSheet();
    });

    Get.offAll(() => LoginView());
    return;
  }

  if (statusCode == 401) {
    await GeneralController.logout(autoLogout: true);
    ToastService.show("Sesi habis, silahkan login kembali!");

    Get.offAll(() => LoginView());
    return;
  }

  if (statusCode == 403) {
    _showErrorBuilderSheet();
    Get.offAll(() => LoginView());
    return;
  }

  AllMaterial.canLogin.value = true;

  Get.offAll(() => LoginView());

  WidgetsBinding.instance.addPostFrameCallback(
    (_) => _showSuccessBuilderSheet(),
  );
}

void _showErrorBuilderSheet() {
  AllMaterial.showInfoBottomSheet(
    title: "Sistem tidak dapat mengakses server!",
    message:
        "Periksa jaringan Anda, atau hubungi operator untuk mendapatkan bantuan.",
    icon: Icons.error,
    color: Colors.redAccent,
    onPressed: () => Get.back(),
    buttonText: "Tutup",
  );
}

void _showSuccessBuilderSheet() {
  AllMaterial.showInfoBottomSheet(
    title: "Koneksi Berhasil",
    message:
        "Koneksi berhasil terhubung. Anda bisa melanjutkan ke proses login.",
    icon: Icons.check,
    color: Colors.green,
    onPressed: () async {
      Get.back();
      await Future.delayed(Durations.medium2);
      LoginController.startLogin();
    },
    buttonText: "Tutup",
  );
}
