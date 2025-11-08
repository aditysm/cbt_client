import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:get/get.dart';

class GeneralController extends GetxController {
  static Future<void> logout({bool fromFeedback = false}) async {
    if (fromFeedback) {
      await Future.delayed(const Duration(milliseconds: 400));
      Get.back();
      Get.offAll(() => LoginView());

      await clearSession();
    } else {
      AllMaterial.cusDialogValidasi(
        title: "Logout",
        subtitle: "Anda akan keluar dari akun saat ini. Lanjutkan?",
        cancelText: "LANJUT",
        confirmText: "BATAL",
        onCancel: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          Get.back();
          await clearSession();
          Get.offAll(() => LoginView());

          ToastService.show("Logout berhasil, Sampai jumpa!");
        },
        onConfirm: () => Get.back(),
      );
    }
  }

  static Future<void> clearSession() async {
    await Future.microtask(
      () {
        AllMaterial.role.value = "";
        LoginController.infoLogin.value = null;
        LoginController.dataUjian.value = null;
        ExamConfirmationController.detilSoalUjian.clear();
      },
    );
  }
}
