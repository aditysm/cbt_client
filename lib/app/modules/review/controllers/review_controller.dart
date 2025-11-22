import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  var isLoadingFirst = false.obs;
  var isLoading = false.obs;

  var soalDijawab = 0.obs;
  var soalTidakDijawab = 0.obs;
  var jumlahBenar = 0.obs;
  var jumlahSalah = 0.obs;
  var nilaiAkhir = 0.0.obs;

  final dbService = Get.find<DatabaseService>();

  Future<void> loadHasilUjian() async {
    isLoading.value = true;
    try {
      final dijawabRes = await dbService.query("""
      SELECT COUNT(DISTINCT KodeSoal) as total
      FROM ujian_detil_hasil
      WHERE KodeUjian = ? AND NIS = ? AND TRIM(PilihanJawaban) <> ''
    """, [
        LoginController.dataUjian.value?.kodeUjian,
        LoginController.dataUjian.value?.nis
      ]);

      soalDijawab.value = dijawabRes.first["total"] ?? 0;
      soalTidakDijawab.value =
          ((LoginController.dataUjian.value?.jumlahSoal ?? 0) -
                  soalDijawab.value)
              .clamp(0, (LoginController.dataUjian.value?.jumlahSoal ?? 0));

      final benarRes = await dbService.query("""
      SELECT COUNT(DISTINCT KodeSoal) as total
      FROM ujian_detil_hasil
      WHERE KodeUjian = ? AND NIS = ?
        AND TRIM(PilihanJawaban) <> ''
        AND PilihanJawaban = JawabanBenar
    """, [
        LoginController.dataUjian.value?.kodeUjian,
        LoginController.dataUjian.value?.nis
      ]);

      jumlahBenar.value = benarRes.first["total"] ?? 0;
      jumlahSalah.value = (soalDijawab.value - jumlahBenar.value)
          .clamp(0, (LoginController.dataUjian.value?.jumlahSoal ?? 0));

      if ((LoginController.dataUjian.value?.jumlahSoal ?? 0) > 0) {
        nilaiAkhir.value = double.parse(((jumlahBenar.value /
                    (LoginController.dataUjian.value?.jumlahSoal ?? 0)) *
                100)
            .toStringAsFixed(2));
      } else {
        nilaiAkhir.value = 0.0;
      }

      print("✅ Nilai akhir: ${nilaiAkhir.value}");
    } catch (e) {
      print("❌ Error loadHasilUjian: $e");
    }

    isLoadingFirst.value = true;
    isLoading.value = false;
    update();
  }

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AllMaterial.bindLoadingDialog(isLoading);
    });
    super.onInit();
  }

  @override
  void onClose() {
    soalDijawab.value = 0;
    soalTidakDijawab.value = 0;
    jumlahBenar.value = 0;
    jumlahSalah.value = 0;
    nilaiAkhir.value = 0.0;
    super.onClose();
  }
}
