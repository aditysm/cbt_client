import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  var komentarC = TextEditingController();
  final dbService = Get.find<DatabaseService>();
  Future<void> simpanKomentar() async {
    var kodeUjian = LoginController.dataUjian.value?.kodeUjian ?? "";
    var nis = LoginController.dataUjian.value?.nis ?? "";
    try {
      final res = await dbService.execute(
        """
      INSERT INTO komentar (NIS, KodeUjian, Komentar)
      VALUES (?, ?, ?)
      """,
        [nis, kodeUjian, komentarC.text.trim()],
      );

      ToastService.show("Feedback berhasil dikirim. Terima kasih!");
      print("Komentar berhasil disimpan: $res");
    } catch (e) {
      print("Gagal menyimpan komentar: $e");
    }
  }
}
