import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/data/model/info_login_model.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/student_confirmation/controllers/student_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/student_confirmation/views/student_confirmation_view.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/services/network_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final usernameC = TextEditingController();
  static final usernameF = FocusNode();
  final passwordC = TextEditingController();
  final passwordF = FocusNode();
  final showPassword = false.obs;

  static final infoLogin = Rx<InfoLoginModel?>(null);

  static void startLogin() {
    usernameF.requestFocus();
  }

  final usernameError = "".obs;
  final passwordError = "".obs;
  static final allError = "".obs;

  static var mataPelajaran = "".obs;

  final keterangan = "".obs;

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  @override
  void onInit() {
    usernameC.addListener(
      () {
        if (usernameC.text.isNotEmpty) {
          usernameError.value = '';
          allError.value = '';
        }
      },
    );
    passwordC.addListener(
      () {
        if (passwordC.text.isNotEmpty) {
          passwordError.value = '';
          allError.value = '';
        }
      },
    );

    LoginController.infoLogin.value = null;
    super.onInit();
  }

  bool _validateForm() {
    bool isValid = true;

    String input = usernameC.text.trim();

    if (input.isEmpty) {
      usernameError.value = "Username tidak boleh kosong!";
      usernameF.requestFocus();
      isValid = false;
    } else if (passwordC.text.trim().isEmpty) {
      passwordError.value = "Password tidak boleh kosong!";
      passwordF.requestFocus();
      isValid = false;
    }

    if (!isValid) {
      Future.delayed(const Duration(milliseconds: 300));
      allError.value = "Silahkan periksa kembali input Anda.";
      usernameF.requestFocus();
    }

    return isValid;
  }

  Future<void> login() async {
    usernameF.unfocus();
    passwordF.unfocus();
    isLoading.value = true;
    allError.value = "";
    LoginController.infoLogin.value = null;
    AllMaterial.box.remove("token");
    ExamConfirmationController.dataUjian.value = null;
    ExamConfirmationController.detilSoalUjian.clear();
    StudentConfirmationController.dataSiswa.value = null;
    update();

    if (!_validateForm()) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await HttpService.request(
        url: ApiUrl.loginUrl,
        body: {
          "username": usernameC.text.trim(),
          "password": passwordC.text.trim(),
        },
        type: RequestType.post,
        isLogin: true,
      );

      if (response == null) {
        allError.value = "Login gagal. Server tidak memberikan respon.";
        usernameF.requestFocus();
        return;
      }

      if (response is! Map) {
        allError.value = "Terjadi kesalahan tak terduga dari server.";
        return;
      }

      if (response['access_token'] == null) {
        allError.value =
            (response['message'] ?? "Login gagal. Periksa kembali akun Anda.")
                .toString();
        usernameF.requestFocus();
        return;
      }

      final token = response["access_token"].toString();
      AllMaterial.box.write("token", token);
      AllMaterial.token.value = token;

      final now = DateTime.now();
      final tanggal =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final waktuLogin =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      await isiKeterangan();
      await postInfoLogin(tanggal, waktuLogin);
      await getDateTimeServer();

      if (AllMaterial.dateServer.value.isNotEmpty &&
          AllMaterial.timeServer.value.isNotEmpty) {
        AllMaterial.isServerTimeLoaded.value = true;

        print("SERVER TIME LOADED → OK");
        ToastService.show("Login berhasil. Selamat datang!");
        Get.offAll(() => StudentConfirmationView());
      } else {
        print("SERVER TIME BELUM TERISI!!");
      }

      usernameC.clear();
      passwordC.clear();
    } catch (e) {
      print("❌ login() error: $e");
      allError.value = AllMaterial.getErrorMessageFromException(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> postInfoLogin(
    String tanggal,
    String waktuLogin,
  ) async {
    var response = await HttpService.request(
      url: ApiUrl.infoLoginUrl,
      type: RequestType.post,
      body: {
        "tanggal": tanggal,
        "waktu_login": waktuLogin,
        "keterangan": keterangan.value,
      },
    );

    if (response != null && response["data"] != null) {
      infoLogin.value = InfoLoginModel.fromJson(response);
    }
  }

  Future<void> getDateTimeServer() async {
    var response = await HttpService.request(
      url: ApiUrl.getDateTime,
      type: RequestType.get,
    );

    if (response != null && response["data"] != null) {
      AllMaterial.dateServer.value = response["data"]["date"];
      AllMaterial.timeServer.value = response["data"]["time"];
    }
  }

  Future<void> isiKeterangan() async {
    final host = await NetworkHelper.getHostName();
    final ip = await NetworkHelper.getIPAddress();
    final mac = await NetworkHelper.getMacAddress();

    keterangan.value =
        "Host Name : $host, IP Address : $ip, MAC Address : $mac";
  }
}
