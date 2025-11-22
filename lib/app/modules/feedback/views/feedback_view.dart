// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../controllers/feedback_controller.dart';

final controller = Get.put(FeedbackController());

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final padding = 26.0;
    final double unifiedBorderRadius = 14.0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: kToolbarHeight + 20,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isDesktop ? Get.width / 3 : Get.width),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Feedback User",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Terima kasih telah menyelesaikan ujian. \nMohon luangkan waktu untuk mengisi komentar atau saran pada kolom di bawah untuk membantu kami meningkatkan kualitas ujian.",
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          maxLines: 5,
                          controller: controller.komentarC,
                          decoration: InputDecoration(
                            hintText: "Masukkan feedback Anda di sini...",
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (controller.komentarC.text.trim().isEmpty) {
                              AllMaterial.cusDialogValidasi(
                                title: "Menutup Feedback",
                                subtitle:
                                    "Halaman akan ditutup dan tidak bisa diakses lagi. Lanjutkan?",
                                onConfirm: () async {
                                  Get.back();
                                  await GeneralController.logout(
                                      fromFeedback: true);
                                },
                                confirmText: "LANJUT",
                                cancelText: "BATAL",
                                showCancel: true,
                                onCancel: () => Get.back(),
                              );
                            } else {
                              await controller.simpanKomentar();
                              await GeneralController.logout(
                                  fromFeedback: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromWidth(Get.width),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                unifiedBorderRadius,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "KEMBALI KE LOGIN",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AppStatusBar(role: "Siswa"),
        ],
      ),
    );
  }
}
