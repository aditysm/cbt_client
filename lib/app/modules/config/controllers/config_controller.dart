import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ConfigController extends GetxController {
  final box = GetStorage();
  final dbService = Get.find<DatabaseService>();

  final isLoadingFirst = false.obs;

  final host = "".obs;
  final port = 3306.obs;

  var isLoading = false.obs;

  final hostC = TextEditingController();
  final hostF = FocusNode();
  final portC = TextEditingController();
  final portF = FocusNode();

  final serverNameC = TextEditingController();
  final serverNameF = FocusNode();

  final userC = TextEditingController();
  final userF = FocusNode();

  final passC = TextEditingController();
  final passF = FocusNode();

  final dbNameC = TextEditingController();
  final dbNameF = FocusNode();

  final settingPassC = TextEditingController();
  final settingPassF = FocusNode();

  final unlockKeyC = TextEditingController();
  final unlockKeyF = FocusNode();

  final serverNameError = "".obs;
  final userError = "".obs;
  final passError = "".obs;
  final dbNameError = "".obs;
  final settingPassError = "".obs;
  final hostError = "".obs;
  final portError = "".obs;
  final unlockKeyError = "".obs;
  final allError = "".obs;

  @override
  void onInit() {
    super.onInit();

    serverNameC.addListener(() {
      if (serverNameC.text.isNotEmpty) serverNameError.value = "";
    });

    userC.addListener(() {
      if (userC.text.isNotEmpty) userError.value = "";
    });
    hostC.addListener(() {
      if (hostC.text.isNotEmpty) hostError.value = "";
    });
    portC.addListener(() {
      if (portC.text.isNotEmpty) portError.value = "";
    });

    passC.addListener(() {
      if (passC.text.isNotEmpty) passError.value = "";
    });

    dbNameC.addListener(() {
      if (dbNameC.text.isNotEmpty) dbNameError.value = "";
    });

    settingPassC.addListener(() {
      if (settingPassC.text.isNotEmpty) settingPassError.value = "";
    });

    unlockKeyC.addListener(() {
      if (unlockKeyC.text.isNotEmpty) unlockKeyError.value = "";
    });
  }

  var isTesting = false.obs;
  var testResult = ''.obs;

  Future<void> testAndSave() async {
    isTesting.value = true;
    testResult.value = '';

    try {
      final success = await dbService.testConnection(
        host: hostC.text.isEmpty
            ? AllMaterial.getDefaultDbHost()
            : hostC.text.trim(),
        port: 3306,
        user: userC.text.trim(),
        password: passC.text.trim(),
        dbName: dbNameC.text.trim(),
      );

      isTesting.value = false;

      if (success) {
        box.write('db_config', "config_success");
        box.write('db_server_name', serverNameC.text.trim());
        box.write(
            'db_host',
            hostC.text.isEmpty
                ? AllMaterial.getDefaultDbHost()
                : hostC.text.trim());
        box.write(
          'db_port',
          3306,
        );
        box.write('db_user', userC.text.trim());
        box.write('db_pass', passC.text.trim());
        box.write('db_name', dbNameC.text.trim());

        if (settingPassC.text.isNotEmpty) {
          box.write('setting_pass', settingPassC.text.trim());
        }

        if (unlockKeyC.text.isNotEmpty) {
          box.write('unlock_key', unlockKeyC.text.trim());
        }

        testResult.value =
            "Berhasil terhubung ke ${dbNameC.text.isNotEmpty ? dbNameC.text.trim() : "3306"}";
      } else {
        testResult.value = "Koneksi gagal, silakan periksa konfigurasi Anda!";
      }
    } catch (e) {
      testResult.value = AllMaterial.getErrorMessageFromException(e.toString());
      // testResult.value = e.toString();
      isTesting.value = false;
    }
  }
}
