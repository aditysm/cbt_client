import 'dart:async';
import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/data/api/api_url.dart';
import 'package:aplikasi_cbt/app/data/model/soal_with_jawaban.dart';
import 'package:aplikasi_cbt/app/modules/feedback/views/feedback_view.dart';
import 'package:aplikasi_cbt/app/modules/review/views/review_view.dart';
import 'package:aplikasi_cbt/app/services/http_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:intl/intl.dart';

class ExamRoomController extends GetxController with WidgetsBindingObserver {
  final currentIndex = 0.obs;
  final dataSoal = RxList<Soal?>([]);

  final jawabanPerSoal = <String, String>{}.obs;
  final raguPerSoal = <String, bool>{}.obs;

  final RxBool setuju = false.obs;

  static var isLoading = false.obs;
  static var isActionLoading = false.obs;
  final selectedAnswer = ''.obs;

  final isAppActive = true.obs;

  final soalController = ScrollController();
  final isExamEnd = false.obs;

  final modelDurasi =
      ExamConfirmationController.dataUjian.value?.data?.modelDurasi ?? "";

  final isMarkedRagu = false.obs;
  Timer? _timer;
  final timeLeft = 0.obs;

  final itemKeys = <GlobalKey>[];

  Future<void> loadDataFromApi() async {
    isLoading.value = true;
    try {
      final response = await HttpService.request(
        url: ApiUrl.allSoalWithHasilUrl,
        type: RequestType.get,
      );

      if (response != null && response["data"] != null) {
        final model = ListSoalWithHasilModel.fromJson(response);

        jawabanPerSoal.clear();
        raguPerSoal.clear();
        dataSoal.clear();
        itemKeys.clear();

        final Map<String, Soal> uniqueSoal = {};
        final Map<String, String> uniqueJawaban = {};
        final Map<String, bool> uniqueRagu = {};

        for (final item in model.data ?? []) {
          final soal = item.soal;
          final hasil = item.hasil;

          if (soal == null) continue;

          final kode = soal.kodeSoal?.trim() ?? '';
          if (kode.isEmpty) continue;

          if (!uniqueSoal.containsKey(kode)) {
            uniqueSoal[kode] = soal;
            uniqueJawaban[kode] = hasil?.pilihanJawaban ?? '';
            uniqueRagu[kode] =
                (hasil?.statusRaguRagu ?? "").toLowerCase() == "true";
          }
        }

        dataSoal.assignAll(uniqueSoal.values);
        jawabanPerSoal.assignAll(uniqueJawaban);
        raguPerSoal.assignAll(uniqueRagu);

        print("dataSoal.length: ${dataSoal.length}");
      }

      itemKeys.addAll(List.generate(dataSoal.length, (_) => GlobalKey()));

      print("Final loaded soal: ${dataSoal.length}");
      print("Final loaded jawaban: ${jawabanPerSoal.length}");
      print("Final loaded ragu: ${raguPerSoal.length}");
    } catch (e) {
      print("❌ loadDataFromApi error: $e");
    }

    isLoading.value = false;
  }

  Timer? _exitTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("STATE: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        isAppActive.value = true;
        print("App aktif kembali");

        _exitTimer?.cancel();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        isAppActive.value = false;

        _exitTimer?.cancel();
        _exitTimer = Timer(const Duration(milliseconds: 600), () {
          if (!isAppActive.value) {
            print("User benar-benar meninggalkan aplikasi → exit");
            GeneralController.logout(autoLogout: true);
            AllMaterial.executeExit();
          }
        });
        break;
    }
  }

  @override
  void onInit() async {
    WidgetsBinding.instance.addObserver(this);
    await loadDataFromApi();

    if (dataSoal.isNotEmpty) {
      loadSelectedAnswer();
    }

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
            );
          }
        }
      },
    );

    final now = DateTime.now();
    int remainingSeconds = 0;

    if (modelDurasi == "Flat Time (Mengikuti Waktu Ujian)") {
      if (ExamConfirmationController.dataUjian.value?.data?.waktuBerakhir !=
          null) {
        final waktuBerakhirStr =
            ExamConfirmationController.dataUjian.value!.data!.waktuBerakhir!;
        final format = DateFormat("yyyy-MM-dd HH:mm:ss");
        final waktuBerakhir = format.parse(waktuBerakhirStr);

        final nowServer = AllMaterial.currentServerDateTime.value;
        remainingSeconds = waktuBerakhir.difference(nowServer).inSeconds;
        if (remainingSeconds < 0) remainingSeconds = 0;
      }
    } else {
      final durasiMenit =
          ExamConfirmationController.dataUjian.value?.data?.durasi ?? 0;
      final waktuAkhir = now.add(Duration(minutes: durasiMenit));
      remainingSeconds = waktuAkhir.difference(now).inSeconds;
    }

    timeLeft.value = remainingSeconds;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (timeLeft.value > 0) {
          timeLeft.value--;
        } else {
          finishExam(otomatis: true);
        }
      },
    );

    super.onInit();
  }

  Future<void> selectAnswer(String option) async {
    isActionLoading.value = true;

    if (selectedAnswer.value == option) {
      print("❗ Jawaban sama, abaikan...");
      isActionLoading.value = false;
      return;
    }

    try {
      if (dataSoal.isEmpty) return;

      final soal = dataSoal[currentIndex.value];
      final kodeSoal = soal?.kodeSoal?.trim() ?? "";

      jawabanPerSoal[kodeSoal] = option;
      selectedAnswer.value = option;

      final bool isRagu = raguPerSoal[kodeSoal] ?? false;
      var response = await HttpService.request(
        url: "${ApiUrl.ujianHasilUrl}/${currentIndex.value + 1}",
        type: RequestType.put,
        body: {
          "pilihan_jawaban": option,
          "status_ragu_ragu": isRagu ? "True" : "False",
          "status_upload": null,
          "keterangan_upload": null,
        },
      );

      if (response["message"]
              .toString()
              .contains("status ujian telah dirubah") &&
          response["code"] == 409) {
        await finishExam(diubahAdmin: true);
        isActionLoading.value = false;
      }
    } catch (e) {
      print("❌ selectAnswer error: $e");
    } finally {
      isActionLoading.value = false;
    }
  }

  void toggleRagu() async {
    if (dataSoal.isEmpty) return;

    final soal = dataSoal[currentIndex.value];
    final kode = soal?.kodeSoal ?? "";

    final newValue = !(raguPerSoal[kode] ?? false);
    raguPerSoal[kode] = newValue;

    await HttpService.request(
      url: "${ApiUrl.ujianHasilUrl}/${currentIndex.value + 1}",
      type: RequestType.put,
      body: {
        "status_ragu_ragu": newValue ? "True" : "False",
      },
    );

    loadSelectedAnswer();
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
    if (dataSoal.isEmpty) return;

    final soal = dataSoal[currentIndex.value];
    final kodeSoal = soal?.kodeSoal?.trim();

    if (kodeSoal == null || kodeSoal.isEmpty) return;

    selectedAnswer.value = jawabanPerSoal[kodeSoal] ?? '';
    isMarkedRagu.value = raguPerSoal[kodeSoal] ?? false;

    jawabanPerSoal.putIfAbsent(kodeSoal, () => "");
    raguPerSoal.putIfAbsent(kodeSoal, () => false);

    print(
      "Load soal $kodeSoal: jawaban='${selectedAnswer.value}', ragu=${isMarkedRagu.value}",
    );
  }

  bool isFinishing = false;

  Future<void> finishExam({
    bool otomatis = false,
    bool diubahAdmin = false,
  }) async {
    if (isFinishing) return;
    isFinishing = true;

    try {
      void goToFinishPage() {
        final tampilHasil = (ExamConfirmationController
                    .dataUjian.value?.data?.statusTampilHasil ??
                "true")
            .toLowerCase();

        if (tampilHasil == "true") {
          Get.offAll(() => ReviewView());
        } else {
          Get.offAll(() => FeedbackView());
        }

        clearSession();
      }

      if (diubahAdmin) {
        _timer?.cancel();
        isExamEnd.value = true;

        AllMaterial.cusDialogValidasi(
          onConfirm: () {
            Get.back();
            goToFinishPage();
          },
          title: "Ujian dinyatakan selesai!",
          showCancel: false,
          subtitle:
              "Maaf, sesi ujian telah dihentikan karena status ujian diubah oleh administrator.",
          iconColor: Colors.redAccent,
          icon: Icons.lock_clock_outlined,
          confirmText: "Akhiri",
        );

        return;
      }

      final response = await HttpService.request(
        url: ApiUrl.akhiriUjianUrl,
        type: RequestType.post,
      );

      if (response != null && response["data"] != null) {
        _timer?.cancel();
        isExamEnd.value = true;

        if (otomatis) {
          AllMaterial.cusDialogValidasi(
            onConfirm: () => Get.back(),
            title: "Ujian dinyatakan selesai!",
            showCancel: false,
            subtitle:
                "Waktu ujian telah habis.\nSemua jawaban berhasil disimpan.",
            iconColor: Colors.redAccent,
            icon: Icons.lock_clock_outlined,
            confirmText: "Akhiri",
          );
        }

        goToFinishPage();
      } else {
        ToastService.show("Gagal mengakhiri ujian. Coba lagi nanti!");
      }
    } catch (e) {
      ToastService.show(
        "Terjadi kesalahan saat mengakhiri ujian: ${e.toString()}",
      );
    } finally {
      isFinishing = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    clearSession();
    super.onClose();
  }

  bool semuaTerjawab() {
    final jumlahSoal =
        ExamConfirmationController.dataUjian.value?.data?.jumlahSoal ?? 0;
    if (jawabanPerSoal.length != jumlahSoal) return false;
    return !jawabanPerSoal.values.any((j) => j.trim().isEmpty);
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

  void confirmEndExam() {
    setuju.value = false;
    AllMaterial.updateConfirmState(false);
    AllMaterial.cusDialogValidasi(
      title: "Konfirmasi Akhiri Ujian",
      confirmText: "AKHIRI",
      icon: Icons.warning_amber_rounded,
      showCancel: true,
      onCancel: () => Get.back(),
      onConfirm: () async {
        if (setuju.value) {
          Get.back();
          await finishExam();
        }
      },
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dengan mencentang pilihan SETUJU dan menekan tombol AKHIRI, "
            "Anda akan keluar dari ujian, dan tidak dapat kembali.",
          ),
          SizedBox(height: 3),
          Obx(
            () {
              final jumlahRagu =
                  raguPerSoal.entries.where((e) => e.value).length;

              return jumlahRagu == 0
                  ? const SizedBox()
                  : Text(
                      "Jumlah soal ragu-ragu: $jumlahRagu",
                      style: TextStyle(color: Colors.amber[900]),
                    );
            },
          ),
          SizedBox(height: 8),
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
                "Saya setuju dengan konfirmasi di atas.",
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
}
