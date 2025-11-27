import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ConfigController extends GetxController {
  final box = GetStorage();

  final isLoadingFirst = false.obs;

  final host = "".obs;
  final port = AllMaterial.port.value.obs;

  var isLoading = false.obs;

  final showPassword = false.obs;
  final showSettingsPassword = false.obs;

  final hostC = TextEditingController();
  final hostF = FocusNode();
  final portC = TextEditingController();
  final portF = FocusNode();

  final settingPassC = TextEditingController();
  final settingPassF = FocusNode();

  final serverNameError = "".obs;
  final userError = "".obs;
  final passError = "".obs;
  final dbNameError = "".obs;
  final settingPassError = "".obs;
  final hostError = "".obs;
  final portError = "".obs;
  final allError = "".obs;

  @override
  void onInit() {
    super.onInit();

    hostC.addListener(() {
      if (hostC.text.isNotEmpty) hostError.value = "";
    });
    portC.addListener(() {
      if (portC.text.isNotEmpty) portError.value = "";
    });

    settingPassC.addListener(() {
      if (settingPassC.text.isNotEmpty) settingPassError.value = "";
    });
  }

  var isTesting = false.obs;
  var testResult = ''.obs;

  Future<void> testAndSave() async {
    isTesting.value = true;
    testResult.value = '';

    try {
      final response = await HttpService.request(
        url: ApiUrl.testConnection,
        type: RequestType.get,
        onStuck: (error) {
          print("onStuck: $error");
          testResult.value =
              AllMaterial.getErrorMessageFromException(error.toString());
        },
        onError: (error) {
          print("onError: $error");
          testResult.value =
              AllMaterial.getErrorMessageFromException(error.toString());
        },
      );

      if (response != null &&
          response["data"] != null &&
          response["data"].toString().toLowerCase().contains("succes")) {
        box.write(
          'db_host',
          hostC.text.trim().isEmpty ? AllMaterial.baseUrl : hostC.text.trim(),
        );
        box.write(
          'db_port',
          portC.text.trim().isEmpty
              ? AllMaterial.port.value
              : portC.text.trim(),
        );

        AllMaterial.baseUrl.value = box.read('db_host');
        AllMaterial.port.value = box.read('db_port');
        AllMaterial.canLogin.value = true;
        LoginController.allError.value = "";

        if (settingPassC.text.isNotEmpty) {
          box.write('setting_pass', settingPassC.text.trim());
        }

        testResult.value = "Berhasil terhubung, silahkan buka halaman Login!";
      }
    } catch (e) {
      testResult.value = AllMaterial.getErrorMessageFromException(e.toString());
    } finally {
      isTesting.value = false;
    }
  }
}
