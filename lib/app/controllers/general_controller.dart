import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/modules/review/controllers/review_controller.dart';
import 'package:aplikasi_cbt/app/modules/student_confirmation/controllers/student_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:get/get.dart';

class GeneralController extends GetxController {
  final loginC = Get.put(LoginController());

  static var isLoading = false.obs;

  static Future<void> logout({
    bool fromFeedback = false,
    bool fromUjian = false,
    bool autoLogout = false,
  }) async {
    if (fromFeedback || autoLogout) {
      await clearSession();
      Get.offAll(() => LoginView());
      return;
    }

    AllMaterial.cusDialogValidasi(
      title: "Logout",
      subtitle: "Anda akan keluar dari akun saat ini. Lanjutkan?",
      confirmText: "LANJUT",
      cancelText: "BATAL",
      onConfirm: () async {
        Get.back();
        if (fromUjian) {
          AllMaterial.cusDialogValidasi(
            title: "Keluar sekarang",
            subtitle: "Progres ujian Anda akan hilang. Lanjutkan?",
            confirmText: "LANJUT",
            cancelText: "BATAL",
            onCancel: () => Get.back(),
            onConfirm: () async {
              Get.back();
              await executeLogout();
            },
          );
        } else {
          await executeLogout();
        }
      },
      onCancel: () => Get.back(),
    );
  }

  static Future<void> executeLogout() async {
    isLoading.value = true;

    int? statusCode;
    try {
      await HttpService.request(
        url: ApiUrl.logoutUrl,
        type: RequestType.post,
        onStatus: (code) => statusCode = code,
      );

      if (statusCode != null && statusCode == 200) {
        await clearSession();
        Get.offAll(() => LoginView());
        ToastService.show("Logout berhasil, Sampai jumpa!");
      } else {
        ToastService.show("Logout gagal, coba lagi nanti!");
      }
    } catch (e) {
      ToastService.show(AllMaterial.getErrorMessageFromException(e.toString()));
    }

    isLoading.value = false;
  }

  static Future<void> clearSession() async {
    AllMaterial.role.value = "";
    AllMaterial.box.remove("token");

    ExamConfirmationController.dataUjian.value = null;
    ExamConfirmationController.detilSoalUjian.clear();
    StudentConfirmationController.dataSiswa.value = null;
    ReviewController.hasilUjian.value = null;

    AllMaterial.currentServerDateTime.value = DateTime.now();
    AllMaterial.isServerTimeLoaded.value = false;
    AllMaterial.timeServer.value = "";
    AllMaterial.dateServer.value = "";
  }

  @override
  void onInit() {
    AllMaterial.bindLoadingDialog(isLoading);
    super.onInit();
  }
}
