import 'dart:async';
import 'package:aplikasi_cbt/app/data/model/data_ujian_model.dart';
import 'package:aplikasi_cbt/app/modules/feedback/views/feedback_view.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/modules/review/views/review_view.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';

class ExamRoomController extends GetxController {
  final currentIndex = 0.obs;
  final dataSoal = ExamConfirmationController.detilSoalUjian;
  final dbService = Get.find<DatabaseService>();
  final jawabanPerSoal = <String, String>{}.obs;
  final raguPerSoal = <String, bool>{}.obs;

  final selectedAnswer = ''.obs;
  final soalController = ScrollController();

  final isExamEnd = false.obs;

  final modelDurasi = LoginController.dataUjian.value?.modelDurasi ?? "";

  final isMarkedRagu = false.obs;
  Timer? _timer;
  final timeLeft = 0.obs;
  late final UserUjian? userUjian;

  final itemKeys = <GlobalKey>[];

  Future<void> loadJawabanDariDb() async {
    final kodeUjian = LoginController.dataUjian.value?.kodeUjian;
    final nis = LoginController.dataUjian.value?.nis;

    if (kodeUjian == null || nis == null) return;

    try {
      final results = await dbService.query("""
      SELECT KodeSoal, PilihanJawaban, StatusRaguRagu
      FROM ujian_detil_hasil
      WHERE KodeUjian = ? AND NIS = ?
    """, [kodeUjian, nis]);

      for (final row in results) {
        final kodeSoal = row["KodeSoal"].toString();
        final jawaban = row["PilihanJawaban"]?.toString() ?? "";
        final ragu = row["StatusRaguRagu"]?.toString() == "Ragu";

        jawabanPerSoal[kodeSoal] = jawaban;
        raguPerSoal[kodeSoal] = ragu;
      }

      print(
          "✅ Jawaban dari DB berhasil dipulihkan: ${jawabanPerSoal.length} soal");
    } catch (e) {
      print("❌ Error load jawaban dari DB: $e");
    }
  }

  @override
  void onInit() async {
    super.onInit();

    userUjian = LoginController.dataUjian.value;
    final waktuServerResult = await dbService.query(
      "SELECT DATE_FORMAT(SYSDATE(), '%Y-%m-%d %H:%i:%s') AS serverTime",
    );

    DateTime now;
    if (waktuServerResult.isNotEmpty) {
      final serverTimeStr = waktuServerResult.first['serverTime'] as String;
      now = DateTime.parse(serverTimeStr);
    } else {
      now = DateTime.now();
    }
    int remainingSeconds = 0;

    loadJawabanDariDb().then((_) {
      loadSelectedAnswer();
    });

    ever(
      currentIndex,
      (idx) {
        if (idx >= 0 && idx < itemKeys.length) {
          final context = itemKeys[idx].currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.3,
              alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
            );
          }
        }
      },
    );

    if (modelDurasi == "Flat Time (Mengikuti Waktu Ujian)") {
      if (userUjian?.waktuDimulaiUjian != null &&
          userUjian?.waktuBerakhirUjian != null) {
        final waktuMulai = userUjian!.waktuDimulaiUjian;
        final waktuBerakhir = userUjian!.waktuBerakhirUjian;

        final totalDurasi = waktuBerakhir.inSeconds - waktuMulai.inSeconds;

        remainingSeconds = waktuBerakhir.inSeconds;

        if (remainingSeconds < 0) remainingSeconds = 0;

        if (remainingSeconds > totalDurasi) {
          remainingSeconds = totalDurasi;
        }
      }
    } else if (modelDurasi == "Start Time (Mengikuti Waktu Login)") {
      final durasiMenit = userUjian?.durasi ?? 0;

      final waktuLogin = now;

      final waktuAkhir = waktuLogin.add(Duration(minutes: durasiMenit));

      remainingSeconds = waktuAkhir.difference(now).inSeconds;

      if (remainingSeconds < 0) remainingSeconds = 0;
    }

    timeLeft.value = remainingSeconds > 0 ? remainingSeconds : 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        finishExam(otomatis: true);
      }
    });

    loadSelectedAnswer();
  }

  Future<void> selectAnswer(String option) async {
    final soal = dataSoal[currentIndex.value];
    final kodeSoal = soal?.kodeSoal ?? "";

    final kodeUjian = userUjian?.kodeUjian;
    final nis = userUjian?.nis;

    if (kodeUjian == null || nis == null) {
      print("❌ KodeUjian atau NIS null, tidak bisa simpan jawaban");
      return;
    }

    try {
      final globalStatus = await dbService.query("""
    SELECT StatusUjian FROM ujian WHERE KodeUjian = ?
  """, [kodeUjian]);

      if (globalStatus.isNotEmpty &&
          globalStatus.first['StatusUjian'] == 'Ujian Selesai') {
        print("⚠️ Ujian telah ditutup oleh administrator (global).");
        await finishExam(fromStatus: true, otomatis: true);
        return;
      }

      final siswaStatus = await dbService.query("""
  SELECT StatusUjianSiswa FROM ujian_detil_siswa
  WHERE KodeUjian = ? AND NIS = ?
  LIMIT 1
""", [kodeUjian, nis]);

      if (siswaStatus.isEmpty) {
        print("Data siswa belum terdaftar di ujian_detil_siswa ($nis)");
      } else {
        final status = siswaStatus.first['StatusUjianSiswa']?.toString() ?? '';
        print("Status siswa $nis di ujian $kodeUjian: $status");

        if (status.trim().toLowerCase() == 'selesai ujian') {
          print("Siswa $nis sudah menyelesaikan ujian ini.");
          await finishExam(fromStatus: true, otomatis: true);
          return;
        }
      }

      jawabanPerSoal[kodeSoal] = option;
      selectedAnswer.value = option;
      print("Soal $kodeSoal jawaban: $option");
      print("Jumlah jawaban tersimpan: ${jawabanPerSoal.length}");

      final existing = await dbService.query("""
    SELECT 1 FROM ujian_detil_hasil
    WHERE KodeUjian = ? AND NIS = ? AND KodeSoal = ?
  """, [kodeUjian, nis, kodeSoal]);

      if (existing.isEmpty) {
        await dbService.execute("""
      INSERT INTO ujian_detil_hasil
        (KodeUjian, NIS, NomorSoal, KodeSoal, JawabanBenar, PilihanJawaban,
         StatusRaguRagu, StatusUpload, KeteranganUpload)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, [
          kodeUjian,
          nis,
          soal?.nomorUrut,
          kodeSoal,
          soal?.soal?.jawabanBenar,
          option,
          raguPerSoal[kodeSoal] == true ? 'Ragu' : 'Tidak Ragu',
          'Belum',
          '',
        ]);
        print("✅ Jawaban soal $kodeSoal berhasil disimpan (insert)");
      } else {
        await dbService.execute("""
      UPDATE ujian_detil_hasil
      SET PilihanJawaban = ?, StatusRaguRagu = ?
      WHERE KodeUjian = ? AND NIS = ? AND KodeSoal = ?
    """, [
          option,
          raguPerSoal[kodeSoal] == true ? 'Ragu' : 'Tidak Ragu',
          kodeUjian,
          nis,
          kodeSoal,
        ]);
        print("✅ Jawaban soal $kodeSoal berhasil diupdate");
      }
    } catch (e) {
      print("❌ Error selectAnswer untuk soal $kodeSoal: $e");
    }
  }

  void toggleRagu() {
    final soal = dataSoal[currentIndex.value];
    final kodeSoal = soal?.kodeSoal ?? "";

    isMarkedRagu.value = !(raguPerSoal[kodeSoal] ?? false);
    raguPerSoal[kodeSoal] = isMarkedRagu.value;

    print("Soal $kodeSoal ragu: ${isMarkedRagu.value}");
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      loadSelectedAnswer();
    }
  }

  void nextQuestion() {
    if (currentIndex.value < dataSoal.length - 1) {
      currentIndex.value++;
      loadSelectedAnswer();
    }
  }

  void loadSelectedAnswer() {
    final soal = dataSoal[currentIndex.value];
    final kodeSoal = soal?.kodeSoal ?? "";

    selectedAnswer.value = jawabanPerSoal[kodeSoal] ?? '';
    isMarkedRagu.value = raguPerSoal[kodeSoal] ?? false;

    jawabanPerSoal.putIfAbsent(kodeSoal, () => '');
    raguPerSoal.putIfAbsent(kodeSoal, () => false);

    print(
        "Soal $kodeSoal loaded: jawaban='${selectedAnswer.value}', ragu=${isMarkedRagu.value}");
  }

  Future<void> finishExam(
      {bool otomatis = false, bool fromStatus = false}) async {
    _timer?.cancel();
    isExamEnd.value = true;

    final kodeUjian = LoginController.dataUjian.value?.kodeUjian;
    final nis = LoginController.dataUjian.value?.nis;

    print("DEBUG UPDATE ujian_detil_siswa => kodeUjian=$kodeUjian, nis=$nis");

    if (kodeUjian == null || nis == null) {
      print("❌ kodeUjian atau NIS null, tidak bisa update");
      return;
    }

    try {
      await dbService.execute("""
      UPDATE ujian_detil_siswa
      SET StatusUjianSiswa = 'Selesai Ujian'
      WHERE KodeUjian = ? AND NIS = ?
    """, [kodeUjian, nis]);

      print("✅ Update berhasil");
      var tampilHasil =
          LoginController.dataUjian.value?.statusTampilHasil ?? "True";
      if (otomatis) {
        AllMaterial.cusDialogValidasi(
          title: "Ujian Telah Selesai",
          subtitle: fromStatus
              ? "Status ujian telah diubah oleh Administrator."
              : "Waktu ujian sudah habis.\n\n"
                  "Segala perubahan tidak dapat dilakukan lagi. "
                  "Silahkan tekan \"AKHIRI\" untuk menyimpan jawaban Anda.",
          showCancel: false,
          icon: Icons.lock_clock_outlined,
          confirmText: "AKHIRI",
          onConfirm: () async {
            Get.back();
            final kodeUjian = LoginController.dataUjian.value?.kodeUjian;
            final nis = LoginController.dataUjian.value?.nis;

            await dbService.execute("""
            UPDATE ujian_detil_siswa
            SET StatusUjianSiswa = 'Selesai Ujian'
            WHERE KodeUjian = ? AND NIS = ?
          """, [kodeUjian, nis]);

            if (tampilHasil.toLowerCase().contains("true")) {
              Get.offAll(() => ReviewView());
            } else {
              Get.offAll(() => FeedbackView());
            }
            Future.delayed(Duration(milliseconds: 300), () {
              clearSession();
            });
          },
        );
        return;
      }

      if (tampilHasil.toLowerCase().contains("true")) {
        Get.offAll(() => ReviewView());
      } else {
        Get.offAll(() => FeedbackView());
      }
      Future.delayed(Duration(milliseconds: 300), () {
        clearSession();
      });

      LoginController.dataUjian.value?.statusUjianSiswa = "Selesai Ujian";
      update();
    } catch (e) {
      print("❌ Error saat update: $e");
    }
  }

  @override
  void onClose() async {
    _timer?.cancel();
    await Future.delayed(Durations.medium2);
    await Future.microtask(
      () => clearSession(),
    );
    super.onClose();
  }

  void confirmEndExam() {
    final RxBool setuju = false.obs;

    AllMaterial.cusDialogValidasi(
      title: "Konfirmasi Akhiri Ujian",
      subtitle: "",
      confirmText: "AKHIRI",
      icon: Icons.warning_amber_rounded,
      showCancel: true,
      activeConfirm: false,
      onCancel: () => Get.back(),
      onConfirm: () async {
        Get.back();
        await finishExam();
      },
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dengan mencentang pilihan SETUJU dan menekan tombol AKHIRI, "
            "maka anda akan keluar dari ujian. Anda tidak dapat masuk kembali "
            "ke ujian tersebut.",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 5),
          Obx(
            () {
              var jumlahRagu = raguPerSoal.entries.where((e) => e.value).length;

              if (jumlahRagu == 0) {
                return SizedBox();
              }
              return Text(
                "Jumlah soal dijawab ragu-ragu: "
                "$jumlahRagu",
                style: TextStyle(
                  color: Colors.amber[900],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => CheckboxListTile(
              value: setuju.value,
              onChanged: (v) {
                setuju.value = v ?? false;
                AllMaterial.updateConfirmState(setuju.value);
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
              title: const Text(
                "Saya setuju dengan konfirmasi di atas",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    AllMaterial.cusDialogValidasi(
      title: "Logout",
      subtitle:
          "Anda akan keluar dari akun saat ini & kehilangan progres ujian. Lanjutkan?",
      confirmText: "BATAL",
      cancelText: "LANJUT",
      onCancel: () async {
        Get.offAll(() => LoginView());
        await Future.delayed(Durations.medium2);
        await Future.microtask(
          () => clearSession(),
        );
        ToastService.show("Logout berhasil, Sampai jumpa!");
      },
      onConfirm: () => Get.back(),
    );
  }

  bool semuaTerjawab() {
    final jumlahSoal = LoginController.dataUjian.value?.jumlahSoal ?? 0;
    if (jawabanPerSoal.length != jumlahSoal) return false;

    return !jawabanPerSoal.values.any((jawaban) => jawaban.trim().isEmpty);
  }

  void clearSession() {
    dataSoal.clear();
    itemKeys.clear();
    jawabanPerSoal.clear();
    raguPerSoal.clear();
    currentIndex.value = 0;
    isExamEnd.value = false;
    selectedAnswer.value = "";
  }
}
