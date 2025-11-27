import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/data/model/data_siswa_model.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/views/exam_confirmation_view.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentConfirmationController extends GetxController {
  static final dataSiswa = Rx<DataSiswaModel?>(null);

  static final isLoading = false.obs;

  Future<void> getDataSiswa() async {
    isLoading.value = true;
    try {
      var response = await HttpService.request(
        url: ApiUrl.konfirmasiDataSiswaUrl,
        type: RequestType.get,
      );

      if (response != null && response["data"] != null) {
        dataSiswa.value = DataSiswaModel.fromJson(response);
      }
    } catch (e) {
      print(e);
      ToastService.show(HttpService.getErrorMessageFromException(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

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

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await getDataSiswa();
      },
    );
    super.onInit();
  }
}
