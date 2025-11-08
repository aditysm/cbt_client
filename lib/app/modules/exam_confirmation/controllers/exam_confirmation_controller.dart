import 'dart:async';

import 'package:aplikasi_cbt/app/data/model/detil_soal_ujian_model.dart';
import 'package:aplikasi_cbt/app/modules/exam_room/views/exam_room_view.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/review/views/review_view.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExamConfirmationController extends GetxController {
  static var detilSoalUjian = RxList<UjianDetilSoal?>([]);
  static var statusUjianSiswa =
      LoginController.dataUjian.value?.statusUjianSiswa ?? "";
  final dbService = Get.find<DatabaseService>();
  final kodeUjian = LoginController.dataUjian.value?.kodeUjian ?? "";
  final ujian = LoginController.dataUjian.value;

  Future<void> loadSoal() async {
    try {
      final ujian = LoginController.dataUjian.value;
      if (ujian == null) {
        ToastService.show("Data ujian tidak ditemukan.");
        return;
      }

      final kodeUjian = ujian.kodeUjian;
      final statusAcakSoal = (ujian.statusAcakSoal).toLowerCase() == "true";
      final jumlahSoal = ujian.jumlahSoal;
      final nis = ujian.nis;
      final username = ujian.username;

      List<Map<String, dynamic>> results = [];

      if (statusAcakSoal) {
        final nonAcak = await dbService.query("""
      SELECT 
        uds.KodeUjian AS uds_KodeUjian,
        uds.NomorUrut AS uds_NomorUrut,
        uds.KodeSoal AS uds_KodeSoal,
        uds.TransaksiOleh AS uds_TransaksiOleh,
        uds.StatusAcak AS uds_StatusAcak,
        s.KodeSoal AS s_KodeSoal,
        s.Tanggal AS s_Tanggal,
        s.KodeMapel AS s_KodeMapel,
        s.Kategori AS s_Kategori,
        s.JumlahPilihan AS s_JumlahPilihan,
        s.UraianSoal AS s_UraianSoal,
        s.JawabanA AS s_JawabanA,
        s.JawabanB AS s_JawabanB,
        s.JawabanC AS s_JawabanC,
        s.JawabanD AS s_JawabanD,
        s.JawabanE AS s_JawabanE,
        s.JawabanBenar AS s_JawabanBenar,
        s.SourceAudioVideo AS s_SourceAudioVideo,
        s.NamaFile AS s_NamaFile,
        s.TransaksiOleh AS s_TransaksiOleh
      FROM ujian_detil_soal uds
      JOIN soal s ON uds.KodeSoal = s.KodeSoal
      WHERE uds.KodeUjian = ?
        AND uds.StatusAcak = 'Tidak Aktif'
      ORDER BY uds.NomorUrut
      LIMIT ?
    """, [kodeUjian, jumlahSoal]);

        results.addAll(nonAcak);

        final remaining = jumlahSoal - results.length;
        if (remaining > 0) {
          final acak = await dbService.query("""
          SELECT 
            uds.KodeUjian AS uds_KodeUjian,
            uds.NomorUrut AS uds_NomorUrut,
            uds.KodeSoal AS uds_KodeSoal,
            uds.TransaksiOleh AS uds_TransaksiOleh,
            uds.StatusAcak AS uds_StatusAcak,
            s.KodeSoal AS s_KodeSoal,
            s.Tanggal AS s_Tanggal,
            s.KodeMapel AS s_KodeMapel,
            s.Kategori AS s_Kategori,
            s.JumlahPilihan AS s_JumlahPilihan,
            s.UraianSoal AS s_UraianSoal,
            s.JawabanA AS s_JawabanA,
            s.JawabanB AS s_JawabanB,
            s.JawabanC AS s_JawabanC,
            s.JawabanD AS s_JawabanD,
            s.JawabanE AS s_JawabanE,
            s.JawabanBenar AS s_JawabanBenar,
            s.SourceAudioVideo AS s_SourceAudioVideo,
            s.NamaFile AS s_NamaFile,
            s.TransaksiOleh AS s_TransaksiOleh
          FROM ujian_detil_soal uds
          JOIN soal s ON uds.KodeSoal = s.KodeSoal
          WHERE uds.KodeUjian = ?
            AND uds.StatusAcak = 'Aktif'
          ORDER BY RAND()
          LIMIT ?
        """, [kodeUjian, remaining]);

          results.addAll(acak);
        }
      } else {
        results = await dbService.query("""
        SELECT 
          uds.KodeUjian AS uds_KodeUjian,
          uds.NomorUrut AS uds_NomorUrut,
          uds.KodeSoal AS uds_KodeSoal,
          uds.TransaksiOleh AS uds_TransaksiOleh,
          uds.StatusAcak AS uds_StatusAcak,
          s.KodeSoal AS s_KodeSoal,
          s.Tanggal AS s_Tanggal,
          s.KodeMapel AS s_KodeMapel,
          s.Kategori AS s_Kategori,
          s.JumlahPilihan AS s_JumlahPilihan,
          s.UraianSoal AS s_UraianSoal,
          s.JawabanA AS s_JawabanA,
          s.JawabanB AS s_JawabanB,
          s.JawabanC AS s_JawabanC,
          s.JawabanD AS s_JawabanD,
          s.JawabanE AS s_JawabanE,
          s.JawabanBenar AS s_JawabanBenar,
          s.SourceAudioVideo AS s_SourceAudioVideo,
          s.NamaFile AS s_NamaFile,
          s.TransaksiOleh AS s_TransaksiOleh
        FROM ujian_detil_soal uds
        JOIN soal s ON uds.KodeSoal = s.KodeSoal
        WHERE uds.KodeUjian = ?
        ORDER BY uds.NomorUrut
        LIMIT ?
      """, [kodeUjian, jumlahSoal]);
      }

      if (results.isEmpty) {
        ToastService.show("Soal tidak ditemukan untuk ujian ini.");
        return;
      }

      final listSoal =
          results.map((row) => UjianDetilSoal.fromJson(row)).toList();
      detilSoalUjian.value = listSoal;

      print("Jumlah soal diambil: ${detilSoalUjian.length}");

      if (ujian.statusUjian != 'Ujian Sedang Berlangsung') {
        await dbService.execute("""
        UPDATE ujian 
        SET StatusUjian = 'Ujian Sedang Berlangsung'
        WHERE KodeUjian = ?
      """, [kodeUjian]);
      }

      final waktuServer = await dbService
          .query("SELECT DATE_FORMAT(SYSDATE(), '%H:%i:%s') AS TimeToDay");
      final waktuMulai = waktuServer.first['TimeToDay'];

      await dbService.execute("""
      UPDATE ujian_detil_siswa
      SET StatusUjianSiswa = 'Sedang Ujian',
          WaktuDimulai = ?
      WHERE KodeUjian = ? AND NIS = ? AND Username = ?
    """, [waktuMulai, kodeUjian, nis, username]);

      LoginController.dataUjian.value?.statusUjianSiswa = "Sedang Ujian";
    } catch (e) {
      print("❌ Load soal error: $e");
      ToastService.show("Terjadi kesalahan saat memuat soal.");
    }
  }

  void confirmExam() async {
    final RxBool siapData = false.obs;
    final RxBool siapAturan = false.obs;

    if (ujian?.statusUjianSiswa == "Sedang Ujian") {
      await loadSoal();
      Get.offAll(() => ExamRoomView());
    } else {
      AllMaterial.cusDialogValidasi(
        title: "Konfirmasi Data Ujian",
        subtitle: "",
        confirmText: "MULAI UJIAN",
        icon: Icons.assignment_turned_in_outlined,
        showCancel: true,
        activeConfirm: false,
        onCancel: () => Get.back(),
        onConfirm: () async {
          Get.back();
          await loadSoal();
          if (detilSoalUjian.isEmpty) {
            Get.offAll(() => ReviewView());
          } else {
            Get.offAll(() => ExamRoomView());
          }
        },
        customContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sebelum memulai ujian, pastikan Anda sudah:",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Obx(() => CheckboxListTile(
                  value: siapData.value,
                  onChanged: (v) {
                    siapData.value = v ?? false;
                    AllMaterial.updateConfirmState(
                        siapData.value && siapAturan.value);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    "Memeriksa identitas dan data ujian sudah benar.",
                  ),
                )),
            Obx(
              () => CheckboxListTile(
                value: siapAturan.value,
                onChanged: (v) {
                  siapAturan.value = v ?? false;
                  AllMaterial.updateConfirmState(
                      siapData.value && siapAturan.value);
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  "Membaca data & siap mengikuti ujian.",
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  final RxBool tombolAktif = false.obs;
  final RxString pesanStatus = "".obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    startRealtimeChecker();
  }

  void startRealtimeChecker() async {
    await cekStatusUjian();

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final ujian = LoginController.dataUjian.value;
      if (ujian == null) return;

      if (ujian.statusUjian == "Selesai" ||
          ujian.statusUjian == "Ujian Sedang Berlangsung") {
        timer?.cancel();
        print("⛔ Realtime checker dihentikan (${ujian.statusUjian})");
        return;
      }

      await cekStatusUjian();
    });
  }

  Future<void> cekStatusUjian() async {
    try {
      final waktuServerResult = await dbService.query(
        "SELECT DATE_FORMAT(SYSDATE(), '%Y-%m-%d %H:%i:%s') AS serverTime",
      );

      if (waktuServerResult.isEmpty) return;
      final now =
          DateTime.parse(waktuServerResult.first['serverTime'] as String);

      final ujian = LoginController.dataUjian.value;
      if (ujian == null) return;

      final modelDurasi = ujian.modelDurasi;
      final tanggalUjian = ujian.tanggal;
      final waktuMulaiUjianStr = ujian.waktuDimulaiUjian;
      final waktuAkhirUjianStr = ujian.waktuBerakhirUjian;

      DateTime? waktuMulaiUjian;
      DateTime? waktuAkhirUjian;
      try {
        final tanggalString =
            tanggalUjian.toLocal().toIso8601String().split('T').first;

        waktuMulaiUjian = DateTime.parse(
            "$tanggalString ${_toTimeString(waktuMulaiUjianStr)}");
        waktuAkhirUjian = DateTime.parse(
            "$tanggalString ${_toTimeString(waktuAkhirUjianStr)}");
      } catch (_) {
        waktuMulaiUjian = null;
        waktuAkhirUjian = null;
      }

      bool aktif = false;
      String info = "";

      print(
          "🕒 Debug: now=$now | mulai=$waktuMulaiUjian | diff=${now.difference(waktuMulaiUjian!).inSeconds}s");

      switch (modelDurasi) {
        case "Flat Time (Mengikuti Waktu Ujian)":
          if (waktuAkhirUjian == null) {
            info = "Waktu ujian tidak valid.";
            aktif = false;
            break;
          }

          if (now.isBefore(waktuMulaiUjian)) {
            aktif = false;
            info = "Ujian belum dimulai.";
          } else if (now.isAfter(waktuAkhirUjian)) {
            aktif = false;
            info = "Ujian sudah selesai.";
          } else {
            timer?.cancel();
            aktif = true;
            info = "";
          }
          break;

        case "Start Time (Mengikuti Waktu Login)":
          if (now.isBefore(waktuMulaiUjian)) {
            aktif = false;
            info = "Ujian belum dimulai.";
          } else {
            timer?.cancel();
            aktif = true;
            info = "";
          }
          break;

        default:
          aktif = false;
          info = "Model durasi tidak dikenali.";
      }

      tombolAktif.value = aktif;
      pesanStatus.value = info;

      print(
          "⏰ [Server: ${DateFormat('HH:mm:ss').format(now)}] [Mulai: ${DateFormat('HH:mm:ss').format(waktuMulaiUjian)}] [Model: $modelDurasi] → Aktif: $aktif, Info: $info");
    } catch (e) {
      pesanStatus.value = "Gagal memeriksa waktu server!";
      tombolAktif.value = false;
      print("❌ Error cekStatusUjian: $e");
    }
  }

  String _toTimeString(dynamic value) {
    if (value is String) {
      return value.split('.').first;
    } else if (value is Duration) {
      final hours = value.inHours.remainder(24).toString().padLeft(2, '0');
      final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
      return "$hours:$minutes:$seconds";
    } else {
      return "00:00:00";
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
