import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  var komentarC = TextEditingController();
  var isLoading = false.obs;

  Future<void> simpanKomentar() async {
    isLoading.value = true;
    try {
      await HttpService.request(
          url: ApiUrl.komentarUrl,
          type: RequestType.post,
          body: {"komentar": komentarC.text.trim()});
    } catch (e) {
      print(e.toString());
      ToastService.show(AllMaterial.getErrorMessageFromException(e.toString()));
    }

    isLoading.value = false;
    update();
  }

  @override
  void onInit() {
    AllMaterial.bindLoadingDialog(isLoading);
    super.onInit();
  }
}
