// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/modules/feedback/views/feedback_view.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/review_controller.dart';

final controller = Get.put(ReviewController());

class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);
    final padding = isDesktop ? 100.0 : 26.0;
    if (controller.isLoadingFirst.isFalse) {
      controller.loadHasilUjian();
    }

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          _tutupDialog();
        }
      },
      child: Scaffold(
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
                        final maxW =
                            isDesktop ? Get.width * 0.3 : constraints.maxWidth;

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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Review Hasil Ujian",
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
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

                                  // Statistik
                                  Obx(() {
                                    final stats = [
                                      {
                                        "title": "Jumlah Soal :",
                                        "value":
                                            controller.jumlahSoal.toString()
                                      },
                                      {
                                        "title": "Soal Dijawab :",
                                        "value": controller.soalDijawab.value
                                            .toString()
                                      },
                                      {
                                        "title": "Tidak Dijawab :",
                                        "value": controller
                                            .soalTidakDijawab.value
                                            .toString()
                                      },
                                      {
                                        "title": "Jawaban Benar :",
                                        "value": controller.jumlahBenar.value
                                            .toString()
                                      },
                                      {
                                        "title": "Jawaban Salah :",
                                        "value": controller.jumlahSalah.value
                                            .toString()
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
                                  }),

                                  const SizedBox(height: 24),

                                  if (isDesktop)
                                    Align(
                                      alignment: Alignment.center,
                                      child: _NilaiCard(theme: theme),
                                    ),

                                  const SizedBox(height: 30),

                                  ElevatedButton.icon(
                                    onPressed: _tutupDialog,
                                    icon: const Icon(Icons.exit_to_app_rounded),
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
                                        borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  void _tutupDialog() {
    AllMaterial.cusDialogValidasi(
      title: "Menutup Hasil",
      subtitle: "Halaman akan ditutup dan tidak bisa diakses lagi. Lanjutkan?",
      onCancel: () {
        Get.offAll(() => const FeedbackView());
      },
      cancelText: "LANJUT",
      confirmText: "BATAL",
      showCancel: true,
      onConfirm: () => Get.back(),
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
    Color getNilaiColor(double nilai) {
      if (nilai >= 80) return Colors.green.shade600;
      if (nilai >= 60) return Colors.orange.shade600;
      return Colors.orange.shade600;
    }

    return Obx(() {
      final nilai = controller.nilaiAkhir.value;
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
