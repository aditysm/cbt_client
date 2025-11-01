import 'package:aplikasi_cbt/app/modules/exam_confirmation/views/exam_confirmation_view.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:get/get.dart';

class StudentConfirmationController extends GetxController {
  void confirmStudent() {
    AllMaterial.cusDialogValidasi(
      
      onConfirm: () {
        Get.back();
        Get.offAll(() => ExamConfirmationView());
      },
      title: "Konfirmasi Data Siswa",
      subtitle: "Periksa kembali data Anda. "
          "Setelah dikonfirmasi, akses akan ditutup. "
          "Lanjutkan?",
      onCancel: () => Get.back(),
    );
  }
}
