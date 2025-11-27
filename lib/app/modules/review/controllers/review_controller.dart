import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/data/model/hasil_ujian_model.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  static var isLoading = false.obs;

  static var hasilUjian = Rx<HasilUjianModel?>(null);

  Future<void> loadHasilUjian() async {
    isLoading.value = true;
    try {
      var response = await HttpService.request(
        url: ApiUrl.reviewHasilUrl,
        type: RequestType.get,
      );

      if (response != null && response["data"] != null) {
        hasilUjian.value = HasilUjianModel.fromJson(response);
      }
    } catch (e) {
      print(e.toString());
      ToastService.show(AllMaterial.getErrorMessageFromException(e.toString()));
    }

    isLoading.value = false;
    update();
  }

  @override
  void onInit() async {
    await loadHasilUjian();

    super.onInit();
  }

  @override
  void onClose() {
    hasilUjian.value = null;
    super.onClose();
  }
}
