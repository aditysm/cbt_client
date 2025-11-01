import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  var jumlahSoal = LoginController.dataUjian.value?.jumlahSoal ?? 0;
  var isLoadingFirst = false.obs;

  var soalDijawab = 0.obs;
  var soalTidakDijawab = 0.obs;
  var jumlahBenar = 0.obs;
  var jumlahSalah = 0.obs;
  var nilaiAkhir = 0.0.obs;

  final dbService = Get.find<DatabaseService>();

  Future<void> loadHasilUjian() async {
    var kodeUjian = LoginController.dataUjian.value?.kodeUjian ?? "";
    var nis = LoginController.dataUjian.value?.nis ?? "";
    try {
      final dijawabRes = await dbService.query(
        """
        SELECT COUNT(*) as total 
        FROM ujian_detil_hasil 
        WHERE KodeUjian = ? AND NIS = ? AND TRIM(PilihanJawaban) <> ''
        """,
        [kodeUjian, nis],
      );
      soalDijawab.value = dijawabRes.first["total"] ?? 0;

      soalTidakDijawab.value = jumlahSoal - soalDijawab.value;

      final benarRes = await dbService.query(
        """
        SELECT COUNT(*) as total 
        FROM ujian_detil_hasil 
        WHERE KodeUjian = ? AND NIS = ? 
          AND TRIM(PilihanJawaban) <> '' 
          AND PilihanJawaban = JawabanBenar
        """,
        [kodeUjian, nis],
      );
      jumlahBenar.value = benarRes.first["total"] ?? 0;

      jumlahSalah.value = soalDijawab.value - jumlahBenar.value;

      if (jumlahSoal > 0) {
        nilaiAkhir.value = double.parse(
            ((jumlahBenar.value / jumlahSoal) * 100).toStringAsFixed(2));

        print(nilaiAkhir.value);
      } else {
        nilaiAkhir.value = 0.0;
      }
    } catch (e) {
      print("Error loadHasilUjian: $e");
    }
    isLoadingFirst.value = true;
    update();
  }
}
