import 'package:aplikasi_cbt/app/data/model/detil_soal_ujian_model.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:get/get.dart';

class GeneralController extends GetxController {
  static var loginC = Get.put(LoginController());
  static var examCC = Get.put(ExamConfirmationController());
  static Future<void> logout(
      {bool fromFeedback = false, bool otomatis = false}) async {
    if (fromFeedback || otomatis) {
      await Future.delayed(const Duration(milliseconds: 400));
      Get.back();
      Get.offAll(() => LoginView());

      await clearSession();
    } else {
      AllMaterial.cusDialogValidasi(
        title: "Logout",
        subtitle: "Anda akan keluar dari akun saat ini. Lanjutkan?",
        confirmText: "LANJUT",
        cancelText: "BATAL",
        onConfirm: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          Get.back();
          await clearSession();
          Get.offAll(() => LoginView());

          ToastService.show("Logout berhasil, Sampai jumpa!");
        },
        onCancel: () => Get.back(),
      );
    }
  }

  static Future<void> clearSession() async {
    await Future.microtask(
      () async {
        AllMaterial.role.value = "";
        LoginController.infoLogin.value = null;
        LoginController.dataUjian.value = null;
        ExamConfirmationController.statusUjianSiswa = "";
        ExamConfirmationController.detilSoalUjian.assignAll(<UjianDetilSoal>[]);
        loginC.refresh();
        loginC.update();
        examCC.refresh();
        examCC.update();
      },
    );
  }
}
