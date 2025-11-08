// ignore_for_file: deprecated_member_use

import 'package:aplikasi_cbt/app/controllers/general_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/exam_confirmation_controller.dart';

class ExamConfirmationView extends GetView<ExamConfirmationController> {
  const ExamConfirmationView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamConfirmationController());
    final isDesktop = MediaQuery.of(context).size.width > 1005;
    final padding = isDesktop ? 100.0 : 26.0;
    final double unifiedBorderRadius = 14.0;
    final ujian = LoginController.dataUjian.value;

    final GlobalKey<PopupMenuButtonState<String>> menuKey =
        GlobalKey<PopupMenuButtonState<String>>();
    var foto = LoginController.dataUjian.value?.foto;
    Uint8List? fotoBytes;
    if (foto != null) {
      fotoBytes = Uint8List.fromList(foto.toBytes());
    }

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          if (controller.tombolAktif.value) {
            controller.confirmExam();
          }
        }
      },
      child: Scaffold(
        drawer: isDesktop
            ? null
            : Drawer(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.shade100,
                              child: fotoBytes != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        fotoBytes,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            size: 24,
                                            color: Colors.blue.shade700),
                                      ),
                                    )
                                  : Icon(Icons.person,
                                      size: 24, color: Colors.blue.shade700),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LoginController
                                            .dataUjian.value?.namaSiswa ??
                                        "-",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "NIS: ${LoginController.dataUjian.value?.nis ?? "-"}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.black54,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            GeneralController.logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            fixedSize: Size.fromWidth(Get.width),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text(
                            "Logout",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          toolbarHeight: kToolbarHeight + 20,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? padding : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (isDesktop)
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            menuKey.currentState?.showButtonMenu();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue.shade100,
                                  child: fotoBytes != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            fotoBytes,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              size: 24,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.person,
                                          size: 24,
                                          color: Colors.blue.shade700),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        LoginController
                                                .dataUjian.value?.namaSiswa ??
                                            "-",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "NIS: ${LoginController.dataUjian.value?.nis ?? "-"}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.black54,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: PopupMenuButton<String>(
                          key: menuKey,
                          enabled: false,
                          icon: null,
                          tooltip: "",
                          iconColor: Colors.transparent,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "logout",
                              child: Row(
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text("Logout",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == "logout") {
                              GeneralController.logout();
                            }
                          },
                        ),
                      ),
                    ],
                  )
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
                        maxWidth: isDesktop ? Get.width / 2.5 : Get.width),
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
                            "Konfirmasi Data Ujian",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: isDesktop ? 16 : 12,
                            children: [
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: LoginController
                                            .dataUjian.value?.namaUjian ??
                                        "",
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label: "Nama Ujian",
                                    isMax: true,
                                    icon: Icons.assignment,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: LoginController.mataPelajaran.value,
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label: "Mata Pelajaran",
                                    icon: Icons.menu_book,
                                    isMax: true,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: LoginController
                                            .dataUjian.value?.statusUjian ??
                                        "",
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label: "Status Ujian",
                                    icon: Icons.flag,
                                    isMax: true,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text:
                                        "${DateFormat('dd/MM/yyyy').format(ujian?.tanggal ?? DateTime.now())} "
                                        "/ ${AllMaterial.formatDuration(ujian?.waktuDimulaiUjian)} "
                                        "/ ${ujian?.durasi ?? ""} Menit",
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label:
                                        "Tanggal  /   Waktu Ujian  /   Alokasi Waktu",
                                    icon: Icons.watch_later_rounded,
                                    isMax: true,
                                  ).copyWith(),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: AllMaterial.formatJurusan(
                                        LoginController.dataUjian.value
                                                ?.programKeahlian ??
                                            ""),
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label: "Program Keahlian",
                                    icon: Icons.school,
                                    isMax: true,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: LoginController
                                            .dataUjian.value?.kelas ??
                                        "",
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    label: "Kelas",
                                    isMax: true,
                                    icon: Icons.meeting_room,
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: LoginController
                                            .dataUjian.value?.kodeGuru ??
                                        "",
                                  ),
                                  readOnly: true,
                                  decoration: _inputDecoration(
                                    isDesktop: isDesktop,
                                    isMax: true,
                                    label: "Guru Pengampu",
                                    icon: Icons.person,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 32 : 16),
                          Obx(
                            () => controller.tombolAktif.isFalse
                                ? Text(
                                    controller.pesanStatus.value,
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                          Obx(
                            () => SizedBox(
                              height: controller.tombolAktif.isFalse ? 10 : 0,
                            ),
                          ),
                          Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.tombolAktif.isTrue
                                  ? () {
                                      controller.confirmExam();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                fixedSize: isDesktop
                                    ? null
                                    : Size.fromWidth(Get.width),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      unifiedBorderRadius),
                                ),
                                elevation: 0,
                              ),
                              icon: Icon(Icons.play_arrow_rounded),
                              label: const Text(
                                "Mulai Ujian",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? errorText,
    bool isDesktop = false,
    bool isOdd = false,
    bool isMax = false,
  }) {
    double maxWidth;
    if (isDesktop) {
      maxWidth = isOdd
          ? 200
          : isMax
              ? Get.width
              : 350;
    } else {
      maxWidth = 500;
    }

    return InputDecoration(
      constraints: BoxConstraints(maxWidth: maxWidth),
      labelText: label,
      errorText: (errorText?.isEmpty ?? true) ? null : errorText,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
