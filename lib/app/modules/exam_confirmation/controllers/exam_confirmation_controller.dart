import 'dart:async';
import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/data/model/data_ujian_model.dart';
import 'package:aplikasi_cbt/app/data/model/soal_with_jawaban.dart';
import 'package:aplikasi_cbt/app/modules/exam_room/views/exam_room_view.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExamConfirmationController extends GetxController {
  static var dataUjian = Rx<DataUjianModel?>(null);
  static var detilSoalUjian = RxList<Soal?>([]);

  final RxBool isLoadingFirst = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool menungguUjian = false.obs;
  final RxBool mulaiUjian = false.obs;
  final RxString noteUjian = "".obs;
  final RxString statusUjian = "".obs;
  final RxBool tombolAktif = false.obs;
  final RxString pesanStatus = "".obs;

  final isButtonLoading = false.obs;
  final isTimeOut = false.obs;

  Timer? timer;

  Future<void> getDataUjian() async {
    isLoading.value = true;
    isTimeOut.value = false;
    try {
      var response = await HttpService.request(
        url: ApiUrl.konfirmasiDataUjianUrl,
        type: RequestType.get,
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          isTimeOut.value = true;
          ToastService.show(
              "Gagal mengambil data ujian, koneksi terlalu lambat.");
        },
      );

      if (response != null && response["data"] != null) {
        dataUjian.value = DataUjianModel.fromJson(response);
      }
    } catch (e) {
      ToastService.show(HttpService.getErrorMessageFromException(e.toString()));
    } finally {
      isLoading.value = false;
      isLoadingFirst.value = false;
    }
  }

  Future<void> postMulaiUjian() async {
    ToastService.show("Mengarahkan ke ruang ujian. Tunggu sebentar...");
    isLoading.value = true;
    try {
      var response = await HttpService.request(
        url: ApiUrl.mulaiUjianUrl,
        type: RequestType.post,
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          ToastService.show("Koneksi internet terlalu lambat. Coba lagi nanti");
          isLoading.value = false;
        },
      );

      if (response != null && response["data"] != null) {
        Get.offAll(() => ExamRoomView());
      }
    } catch (e) {
      ToastService.show(HttpService.getErrorMessageFromException(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  void startRealtimeChecker() async {
    await cekStatusUjian();

    timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await cekStatusUjian();
    });
  }

  Future<void> cekStatusUjian() async {
    isButtonLoading.value = true;
    try {
      var response = await HttpService.request(
        url: ApiUrl.cekStatusUjianUrl,
        type: RequestType.get,
      );

      if (response == null || response["data"] == null) return;

      final data = response["data"];

      menungguUjian.value = data["menunggu_waktu_ujian"] ?? false;
      mulaiUjian.value = data["mulai_ujian"] ?? false;
      noteUjian.value = data["note"] ?? "";
      statusUjian.value = data["status_ujian"] ?? "";

      print("🔍 menunggu=${menungguUjian.value}, mulai=${mulaiUjian.value}");

      if (mulaiUjian.value == true) {
        tombolAktif.value = true;
        pesanStatus.value = noteUjian.value;

        print("▶️ Ujian dimulai — stop timer");
        timer?.cancel();
        isButtonLoading.value = false;
        return;
      }

      tombolAktif.value = false;

      await cekWaktuMulaiUjian();
    } catch (e) {
      print("❌ Error cekStatusUjian: $e");
      pesanStatus.value = "Gagal memeriksa status ujian.";
    }

    isButtonLoading.value = false;
  }

  Future<void> cekWaktuMulaiUjian() async {
    try {
      final ujian = dataUjian.value?.data;
      if (ujian == null) return;

      final date = AllMaterial.dateServer.value;
      final time = AllMaterial.timeServer.value;

      final serverNow = DateTime.parse("$date $time");

      final tanggalUjian =
          ujian.tanggal?.toLocal().toIso8601String().split('T').first;

      final waktuMulai = DateTime.parse(
        "$tanggalUjian ${_formatTime(ujian.waktuDimulai)}",
      );

      print("⏰ server=$serverNow | mulai=$waktuMulai");

      if (serverNow.isAfter(waktuMulai) ||
          serverNow.isAtSameMomentAs(waktuMulai)) {
        print("🔔 Waktu ujian tiba, cek ulang API!");
        await cekStatusUjian();
      } else {
        pesanStatus.value =
            "Menunggu waktu mulai: ${DateFormat.Hm().format(waktuMulai)}";
      }
    } catch (e) {
      print("❌ Error cekWaktuMulaiUjian: $e");
    }
  }

  String _formatTime(dynamic value) {
    if (value is String) return value.split('.').first;
    return "00:00:00";
  }

  @override
  void onInit() async {
    await getDataUjian();
    startRealtimeChecker();
    AllMaterial.bindLoadingDialog(isLoading);
    super.onInit();
  }

  void confirmExam() async {
    final RxBool siapData = false.obs;
    final RxBool siapAturan = false.obs;

    AllMaterial.cusDialogValidasi(
      title: "Konfirmasi Data Ujian",
      confirmText: "MULAI UJIAN",
      icon: Icons.assignment_turned_in_outlined,
      showCancel: true,
      activeConfirm: false,
      onCancel: () => Get.back(),
      onConfirm: () async {
        Get.back();
        await postMulaiUjian();
      },
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sebelum memulai ujian, pastikan Anda sudah:",
              style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Obx(
            () => CheckboxListTile(
              value: siapData.value,
              onChanged: (v) {
                siapData.value = v ?? false;
                AllMaterial.updateConfirmState(
                    siapData.value && siapAturan.value);
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text("Memeriksa data dengan benar."),
            ),
          ),
          Obx(
            () => CheckboxListTile(
              value: siapAturan.value,
              onChanged: (v) {
                siapAturan.value = v ?? false;
                AllMaterial.updateConfirmState(
                    siapData.value && siapAturan.value);
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text("Siap mengikuti ujian."),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
