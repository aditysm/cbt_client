import 'package:aplikasi_cbt/app/modules/feedback/views/feedback_view.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/review_controller.dart';

class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final controller = Get.put(ReviewController());
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);
    final padding = isDesktop ? 100.0 : 26.0;

    return Obx(
      () {
        if (ReviewController.isLoading.value) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(child: _shimmerReviewPage()),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 30,
                        child: Image.asset(
                          "assets/icons/logo-smeda.png",
                          gaplessPlayback: true,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("CBT Client"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxW = isDesktop
                              ? Get.width * 0.3
                              : constraints.maxWidth;

                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxW),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "Review Hasil Ujian",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (!isDesktop)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 24),
                                        child: _NilaiCard(theme: theme),
                                      ),
                                    Obx(
                                      () {
                                        final stats = [
                                          {
                                            "title": "Jumlah Soal :",
                                            "value": (ReviewController
                                                        .hasilUjian
                                                        .value
                                                        ?.data
                                                        ?.jumlahSoal ??
                                                    0)
                                                .toString(),
                                          },
                                          {
                                            "title": "Soal Dijawab :",
                                            "value": (ReviewController
                                                        .hasilUjian
                                                        .value
                                                        ?.data
                                                        ?.jumlahSoalDijawab ??
                                                    0)
                                                .toString(),
                                          },
                                          {
                                            "title": "Tidak Dijawab :",
                                            "value": (ReviewController
                                                        .hasilUjian
                                                        .value
                                                        ?.data
                                                        ?.jumlahSoalTidakDijawab ??
                                                    0)
                                                .toString(),
                                          },
                                          {
                                            "title": "Jawaban Benar :",
                                            "value": (ReviewController
                                                        .hasilUjian
                                                        .value
                                                        ?.data
                                                        ?.jumlahBenar ??
                                                    0)
                                                .toString(),
                                          },
                                          {
                                            "title": "Jawaban Salah :",
                                            "value": (ReviewController
                                                        .hasilUjian
                                                        .value
                                                        ?.data
                                                        ?.jumlahSalah ??
                                                    0)
                                                .toString(),
                                          },
                                        ];

                                        return Wrap(
                                          runSpacing: 8,
                                          children: stats
                                              .map((s) => _StatRow(
                                                    title: s["title"]!,
                                                    value: s["value"]!,
                                                    theme: theme,
                                                  ))
                                              .toList(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    if (isDesktop)
                                      Align(
                                        alignment: Alignment.center,
                                        child: _NilaiCard(theme: theme),
                                      ),
                                    const SizedBox(height: 30),
                                    ElevatedButton.icon(
                                      onPressed: _tutupDialog,
                                      icon:
                                          const Icon(Icons.exit_to_app_rounded),
                                      label: const Text(
                                        "TUTUP HALAMAN",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const AppStatusBar(role: "Siswa"),
              ],
            ),
          ),
        );
      },
    );
  }

  void _tutupDialog() {
    AllMaterial.cusDialogValidasi(
      title: "Menutup Hasil",
      subtitle: "Halaman akan ditutup dan tidak bisa diakses lagi. Lanjutkan?",
      onConfirm: () {
        Get.offAll(() => const FeedbackView());
      },
      confirmText: "LANJUT",
      cancelText: "BATAL",
      showCancel: true,
      onCancel: () => Get.back(),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final String value;
  final ThemeData theme;

  const _StatRow({
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              )),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NilaiCard extends StatelessWidget {
  final ThemeData theme;

  const _NilaiCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    Color getNilaiColor(double nilai, {double kkm = 50}) {
      if (nilai >= 80) return Colors.green.shade600;
      if (nilai >= kkm) return Colors.orange.shade600;
      return Colors.red.shade600;
    }

    return Obx(() {
      final nilai = double.parse(
          ReviewController.hasilUjian.value?.data?.nilaiAkhir?.toString() ??
              "0");
      final warna = getNilaiColor(nilai);

      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [warna.withOpacity(0.8), warna],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Text(
                "NILAI AKHIR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                nilai.toStringAsFixed(2).replaceAll(".", ","),
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: warna,
                  fontSize: 36,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

Widget _shimmerReviewPage() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 28,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 30),
          _ShimmerNilaiCard(),
          const SizedBox(height: 24),
          Column(
            children: List.generate(5, (i) => const _ShimmerStatRow())
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: e,
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _ShimmerNilaiCard(),
          const SizedBox(height: 30),
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShimmerStatRow extends StatelessWidget {
  const _ShimmerStatRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Container(
            height: 18,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerNilaiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 38,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
