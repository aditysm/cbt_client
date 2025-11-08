// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_cbt/app/data/model/data_ujian_model.dart';
import 'package:aplikasi_cbt/app/data/model/detil_soal_ujian_model.dart';
import 'package:aplikasi_cbt/app/modules/exam_confirmation/controllers/exam_confirmation_controller.dart';
import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aplikasi_cbt/app/utils/app_status_bar.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/exam_room_controller.dart';

final controller = Get.put(ExamRoomController());

class ExamRoomView extends GetView<ExamRoomController> {
  const ExamRoomView({super.key});
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1005;
    final padding = isDesktop ? 100.0 : 26.0;
    final theme = Theme.of(context);
    final GlobalKey<PopupMenuButtonState<String>> menuKey =
        GlobalKey<PopupMenuButtonState<String>>();

    final roomScroll = ScrollController();

    return Obx(
      () {
        final dataSoal = ExamConfirmationController.detilSoalUjian;
        final ujian = LoginController.dataUjian.value;
        var foto = ujian?.foto;

        Uint8List? fotoBytes;
        if (foto != null) {
          fotoBytes = Uint8List.fromList(foto.toBytes());
        }
        if (dataSoal.isEmpty) return SizedBox.shrink();

        final total = dataSoal.length;
        var currentIndex = controller.currentIndex.value;
        return RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              if ((controller.selectedAnswer.isNotEmpty &&
                      controller.isMarkedRagu.isFalse) ||
                  (controller.selectedAnswer.isNotEmpty &&
                      controller.isMarkedRagu.value)) {
                if (currentIndex < total - 1) {
                  controller.nextQuestion();
                }
              }
            } else if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (currentIndex < total - 1) {
                controller.nextQuestion();
              }
            } else if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              if (currentIndex > 0) {
                controller.previousQuestion();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              toolbarHeight: kToolbarHeight + 20,
              title: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isDesktop ? padding : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Image.asset(
                            "assets/icons/logo-dikbud.png",
                            gaplessPlayback: true,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("CBT Client"),
                      ],
                    ),
                    (!isDesktop)
                        ? Row(
                            children: [
                              if (isDesktop)
                                Text(
                                  "Sisa Waktu : ",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Obx(
                                () => Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: controller.isExamEnd.value
                                        ? Colors.red.shade100
                                        : Colors.green.shade100,
                                  ),
                                  child: Obx(() {
                                    final remainingSeconds =
                                        controller.timeLeft.value;

                                    final hours = (remainingSeconds ~/ 3600)
                                        .toString()
                                        .padLeft(2, '0');
                                    final minutes =
                                        ((remainingSeconds % 3600) ~/ 60)
                                            .toString()
                                            .padLeft(2, '0');
                                    final seconds = (remainingSeconds % 60)
                                        .toString()
                                        .padLeft(2, '0');

                                    return Text(
                                      "$hours:$minutes:$seconds",
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: controller.isExamEnd.value
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          )
                        : Row(
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
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                      Icons.person,
                                                      size: 24,
                                                      color:
                                                          Colors.blue.shade700,
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
                                                LoginController.dataUjian.value
                                                        ?.namaSiswa ??
                                                    "-",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                              color: Colors.redAccent,
                                              size: 20),
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
                                      controller.logout();
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
            drawer: isDesktop
                ? null
                : Drawer(
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                                          size: 24,
                                          color: Colors.blue.shade700),
                                ),
                                const SizedBox(width: 12),
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
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Informasi Ujian",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildSummaryCard(Icons.question_answer,
                                    "Jumlah Soal: ${ujian?.jumlahSoal ?? ""}"),
                                _buildSummaryCard(Icons.book,
                                    "Mapel: ${LoginController.mataPelajaran.value}"),
                                _buildSummaryCard(Icons.school,
                                    "Kelas: ${ujian?.kelas ?? ""}"),
                                _buildSummaryCard(Icons.work,
                                    "Program Keahlian: ${ujian?.programKeahlianGabung ?? ""}"),
                                _buildSummaryCard(Icons.person,
                                    "Guru Pengampu: ${ujian?.namaGuru ?? ""}"),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                controller.logout();
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
            body: Column(
              children: [
                Expanded(
                  child: isDesktop
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(padding, 25, padding, 0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _buildQuestionArea(
                                        theme,
                                        isDesktop,
                                        dataSoal[controller.currentIndex.value],
                                      ),
                                    ),
                                    SizedBox(width: 25),
                                    Expanded(
                                      child:
                                          _sideBarArea(theme, ujian, dataSoal),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              _buildAnswerBottomArea(
                                theme,
                                isDesktop,
                                dataSoal[controller.currentIndex.value],
                                currentIndex,
                                total,
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isDesktop ? 16 : 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 8 : 0,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${controller.currentIndex.value + 1} dari ${controller.userUjian?.jumlahSoal ?? "0"} Soal",
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: ElevatedButton.icon(
                                            onPressed: controller
                                                    .semuaTerjawab()
                                                ? () {
                                                    controller.confirmEndExam();
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            icon: const Icon(
                                                Icons.check_circle_outline,
                                                size: 20),
                                            label: const Text(
                                              "Akhiri Ujian",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 0),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        16, 0, 16, isDesktop ? 4 : 2),
                                    child: Scrollbar(
                                      controller: controller.soalController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        controller: controller.soalController,
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: isDesktop ? 20 : 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: List.generate(
                                                dataSoal.length, (index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Obx(() {
                                                  if (controller
                                                          .itemKeys.length <
                                                      controller
                                                          .dataSoal.length) {
                                                    controller.itemKeys
                                                        .add(GlobalKey());
                                                  }
                                                  final soal = controller
                                                      .dataSoal[index];
                                                  final kodeSoal =
                                                      soal?.kodeSoal ?? "";

                                                  final currentAnswer =
                                                      controller.jawabanPerSoal[
                                                          kodeSoal];
                                                  final isAnswered =
                                                      currentAnswer != null &&
                                                          currentAnswer
                                                              .isNotEmpty;

                                                  final isRagu =
                                                      controller.raguPerSoal[
                                                              kodeSoal] ??
                                                          false;

                                                  final isCurrent = controller
                                                          .currentIndex.value ==
                                                      index;

                                                  Color bgColor;
                                                  Color? textColor;
                                                  String tooltip;
                                                  Color borderColor =
                                                      Colors.transparent;
                                                  double borderWidth = 0;

                                                  if (isCurrent) {
                                                    bgColor = AppColors
                                                        .primaryBlue
                                                        .withOpacity(0.1);
                                                    textColor =
                                                        AppColors.primaryBlue;
                                                    borderColor =
                                                        AppColors.primaryBlue;
                                                    borderWidth = 2;
                                                    tooltip =
                                                        "Sedang dikerjakan";
                                                  } else if (isRagu) {
                                                    tooltip = "Ragu-ragu";
                                                    bgColor = Colors.amber[900]!
                                                        .withOpacity(0.4);
                                                    textColor =
                                                        Colors.amber[900]!;
                                                    borderColor =
                                                        Colors.amber[900]!;
                                                    borderWidth = 1.5;
                                                  } else if (isAnswered) {
                                                    tooltip = "Dijawab";
                                                    bgColor =
                                                        AppColors.primaryBlue;
                                                    textColor = Colors.white;
                                                  } else {
                                                    tooltip = "Kosong";
                                                    bgColor = Colors.grey
                                                        .withOpacity(0.1);
                                                    textColor = Colors.grey;
                                                    borderColor = Colors.grey
                                                        .withOpacity(0.6);
                                                    borderWidth = 1;
                                                  }

                                                  return MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: Tooltip(
                                                      message: tooltip,
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: InkWell(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          onTap: () {
                                                            controller
                                                                .currentIndex
                                                                .value = index;
                                                            controller
                                                                .loadSelectedAnswer();
                                                          },
                                                          child: Ink(
                                                            key: controller
                                                                    .itemKeys[
                                                                index],
                                                            width: 45,
                                                            height: 45,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: bgColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    borderColor,
                                                                width:
                                                                    borderWidth,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '${index + 1}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 8),
                                ],
                              ),
                              Expanded(
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  controller: roomScroll,
                                  child: SingleChildScrollView(
                                    controller: roomScroll,
                                    child: Column(
                                      children: [
                                        _buildQuestionArea(
                                            theme,
                                            isDesktop,
                                            dataSoal[
                                                controller.currentIndex.value]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _buildAnswerBottomArea(
                            theme,
                            isDesktop,
                            dataSoal[controller.currentIndex.value],
                            currentIndex,
                            total),
                        SizedBox(height: 5),
                        Obx(() {
                          final isLast =
                              controller.currentIndex.value == total - 1;

                          return ElevatedButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: isLast ||
                                    controller.selectedAnswer.isEmpty ||
                                    (controller.selectedAnswer.isEmpty &&
                                        controller.isMarkedRagu.value)
                                ? null
                                : () {
                                    controller.nextQuestion();
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(isDesktop ? 48 : 40),
                            ),
                            label: Text("Soal Berikutnya"),
                            icon: Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 16,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                AppStatusBar(role: "Siswa", fromUjian: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sideBarArea(
    ThemeData theme,
    UserUjian? ujian,
    RxList<UjianDetilSoal?> dataSoal,
  ) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sisa Waktu : ",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: controller.isExamEnd.value
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                  ),
                  child: Obx(() {
                    final remainingSeconds = controller.timeLeft.value;

                    final hours =
                        (remainingSeconds ~/ 3600).toString().padLeft(2, '0');
                    final minutes = ((remainingSeconds % 3600) ~/ 60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds =
                        (remainingSeconds % 60).toString().padLeft(2, '0');

                    return Text(
                      "$hours:$minutes:$seconds",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: controller.isExamEnd.value
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${controller.currentIndex.value + 1} dari ${controller.userUjian?.jumlahSoal ?? "0"} Soal",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: List.generate(controller.dataSoal.length, (index) {
                  return Obx(() {
                    final soal = controller.dataSoal[index];
                    final kodeSoal = soal?.kodeSoal ?? "";

                    final currentAnswer = controller.jawabanPerSoal[kodeSoal];
                    final isAnswered =
                        currentAnswer != null && currentAnswer.isNotEmpty;

                    final isRagu = controller.raguPerSoal[kodeSoal] ?? false;

                    final isCurrent = controller.currentIndex.value == index;

                    Color bgColor;
                    Color? textColor;
                    String tooltip;
                    Color borderColor = Colors.transparent;
                    double borderWidth = 0;

                    if (isCurrent) {
                      bgColor = AppColors.primaryBlue.withOpacity(0.1);
                      textColor = AppColors.primaryBlue;
                      borderColor = AppColors.primaryBlue;
                      borderWidth = 2;
                      tooltip = "Sedang dikerjakan";
                    } else if (isRagu) {
                      tooltip = "Ragu-ragu";
                      bgColor = Colors.amber[900]!.withOpacity(0.4);
                      borderColor = Colors.amber[900]!;
                      textColor = Colors.amber[900]!;
                      borderWidth = 1.5;
                    } else if (isAnswered) {
                      tooltip = "Dijawab";
                      bgColor = AppColors.primaryBlue;
                      textColor = Colors.white;
                    } else {
                      tooltip = "Kosong";
                      bgColor = Colors.grey.withOpacity(0.1);
                      textColor = Colors.grey;
                      borderColor = Colors.grey.withOpacity(0.6);
                      borderWidth = 1;
                    }

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: tooltip,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              controller.currentIndex.value = index;
                              controller.loadSelectedAnswer();
                            },
                            child: Ink(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: borderColor,
                                  width: borderWidth,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                }),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed:
                controller.semuaTerjawab() ? controller.confirmEndExam : null,
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(Get.width),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              "Akhiri Ujian",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(
      ThemeData theme, bool isDesktop, UjianDetilSoal? data) {
    final src = data?.soal?.sourceAudioVideo ?? "";
    final name = data?.soal?.namaFile ?? "";
    final soal = data?.soal;
    if (soal == null) return const SizedBox();

    final int jumlahPilihan = int.tryParse(soal.jumlahPilihan.toString()) ?? 5;
    final List<String> huruf = ['A', 'B', 'C', 'D', 'E'];

    String cleanHtml(String? html) {
      if (html == null) return "";
      final sanitized = html
          .replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E\xA0-\uFFFF]'), '')
          .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'<html[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'</html>', caseSensitive: false), '')
          .replaceAll(
              RegExp(r'<head[^>]*>.*?</head>',
                  caseSensitive: false, dotAll: true),
              '')
          .replaceAll(RegExp(r'<body[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'</body>', caseSensitive: false), '');
      return sanitized.trim();
    }

    final opsi = <String>[];
    for (int i = 0; i < jumlahPilihan && i < huruf.length; i++) {
      final label = huruf[i];
      final rawJawaban = switch (label) {
        'A' => cleanHtml(soal.jawabanA),
        'B' => cleanHtml(soal.jawabanB),
        'C' => cleanHtml(soal.jawabanC),
        'D' => cleanHtml(soal.jawabanD),
        'E' => cleanHtml(soal.jawabanE),
        _ => "",
      };
      final jawabanDoc = HtmlParser.parseHTML(rawJawaban);

      final bodyElement = jawabanDoc.querySelector('body');
      final jawabanContent = bodyElement?.innerHtml ?? jawabanDoc.innerHtml;
      if ((jawabanContent).trim().isNotEmpty) {
        opsi.add("<b>$label. </b>${jawabanContent.trim()}");
      }
    }

    final rawHtml = soal.uraianSoal;
    final document = HtmlParser.parseHTML(rawHtml);
    final bodyContent = document.innerHtml;

    final htmlData = """
    <div style="font-size:${isDesktop ? 16 : 14}px; line-height:1.6;">
      $bodyContent
      <br><br>
      ${opsi.join("<br><br>")}
    </div>
  """;

    String sanitizeHtmlWithImages(String? html) {
      if (html == null) return "";

      String sanitized = html;

      sanitized = sanitized.replaceAll(
        RegExp(r'[^\x09\x0A\x0D\x20-\x7E\xA0-\uFFFF]'),
        '',
      );

      sanitized = sanitized.replaceAllMapped(
        RegExp(r'data:image\/[a-zA-Z]+;base64,([^"\' '>]+)'),
        (match) {
          final base64data = match.group(1)!;
          final cleanBase64 = base64data
              .replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '')
              .replaceAll('\n', '')
              .replaceAll('\r', '')
              .replaceAll(' ', '');
          return match[0]!.replaceFirst(base64data, cleanBase64);
        },
      );

      sanitized = sanitized
          .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'<html[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'</html>', caseSensitive: false), '')
          .replaceAll(
              RegExp(r'<head[^>]*>.*?</head>',
                  caseSensitive: false, dotAll: true),
              '')
          .replaceAll(RegExp(r'<body[^>]*>', caseSensitive: false), '')
          .replaceAll(RegExp(r'</body>', caseSensitive: false), '');

      return sanitized.trim();
    }

    print(opsi);
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final total = controller.dataSoal.length;
      return Container(
        width: Get.width,
        padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 16 : 8),
        decoration: BoxDecoration(
          color: isDesktop ? Colors.white : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Soal No. ${controller.currentIndex.value + 1}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 16),
                if (!isDesktop)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: "Soal Sebelumnya",
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: currentIndex > 0
                              ? Colors.grey[800]
                              : Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: currentIndex > 0
                            ? controller.previousQuestion
                            : null,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: "Soal Selanjutnya",
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: currentIndex < total - 1
                              ? Colors.grey[800]
                              : Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: currentIndex < total - 1
                            ? controller.nextQuestion
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
            if (isDesktop) const SizedBox(height: 12),
            if (src.isNotEmpty && name.isNotEmpty) _buildMediaWidget(src, name),
            if (src.isNotEmpty && name.isNotEmpty) const SizedBox(height: 12),
            SingleChildScrollView(
              child: Html(
                data: sanitizeHtmlWithImages(htmlData),
                style: {
                  "body": Style(
                    fontSize: FontSize(isDesktop ? 16 : 14),
                    lineHeight: LineHeight.number(1.6),
                    padding: HtmlPaddings.zero,
                    margin: Margins.zero,
                  ),
                  "p": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    display: Display.inline,
                  ),
                  "b": Style(
                    display: Display.inline,
                  ),
                  "img": Style(
                    display: Display.inlineBlock,
                    margin: Margins.only(top: 4, bottom: 4),
                  ),
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnswerBottomArea(
    ThemeData theme,
    bool isDesktop,
    UjianDetilSoal? data,
    int currentIndex,
    int total,
  ) {
    return Container(
      width: Get.width,
      padding:
          EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 16 : 4),
      decoration: BoxDecoration(
        color: isDesktop ? Colors.white : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (isDesktop)
            Obx(() {
              final isFirst = controller.currentIndex.value == 0;
              return ElevatedButton.icon(
                iconAlignment: IconAlignment.start,
                onPressed: isFirst ? null : controller.previousQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                label: const Text("Soal Sebelumnya"),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              );
            }),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isDesktop)
                  Text(
                    "PILIHAN JAWABAN",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                _buildAnswerArea(theme, isDesktop, data, currentIndex, total),
              ],
            ),
          ),
          if (isDesktop)
            Obx(() {
              final isLast = controller.currentIndex.value == total - 1;
              return ElevatedButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: isLast ? null : controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                label: const Text("Soal Selanjutnya"),
                icon: const Icon(Icons.arrow_forward_ios_sharp, size: 16),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(String sourcePath, String fileName) {
    if (fileName.isEmpty && sourcePath.isEmpty) {
      return const SizedBox.shrink();
    }

    final ext = fileName.split('.').last.toLowerCase();
    final bool isBase64Raw =
        RegExp(r'^[A-Za-z0-9+/=]+={0,2}$').hasMatch(sourcePath.trim());
    final bool isDataUri = sourcePath.trim().startsWith("data:");
    final bool isBase64 = isBase64Raw || isDataUri;

    print("isBase64: $isBase64");
    print("fileName: $fileName");
    print("sourcePath length: ${sourcePath.length}");

    final mimeType = ["mp3", "wav", "ogg"].contains(ext)
        ? 'audio/$ext'
        : ["mp4", "webm"].contains(ext)
            ? 'video/$ext'
            : 'application/octet-stream';

    if (isBase64) {
      if (Platform.isAndroid) {
        final htmlContent = """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  background: #f8f9fa;
}

body {
  display: flex;
  justify-content: center;
  align-items: stretch; /* isi penuh tinggi */
}

video, audio {
  width: 100%;
  height: 100%;
  object-fit: contain; /* atau 'cover' kalau ingin full tanpa letterbox */
  border-radius: 0; /* hilangkan radius agar tak tampak jarak */
  outline: none;
  background-color: #000;
}
</style>
</head>
<body>
${mimeType.startsWith("video/") ? """
<video id='media' controls
  controlsList="nodownload noremoteplayback"
  disablePictureInPicture
  playsinline>
</video>
""" : """
<audio id='media' controls controlsList="nodownload noplaybackrate noremoteplayback"></audio>
"""}
<script>
const base64Data = '${sourcePath.replaceAll('\n', '').replaceAll("'", "\\'")}';
const mimeType = '$mimeType';
const media = document.getElementById('media');
media.src = 'data:' + mimeType + ';base64,' + base64Data;

document.addEventListener('contextmenu', event => event.preventDefault());
</script>
</body>
</html>
""";

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString(htmlContent);

        return SizedBox(
          height: mimeType.startsWith('video/') ? 300 : 120,
          child: WebViewWidget(controller: controller),
        );
      } else if (Platform.isWindows) {
        return FutureBuilder<Widget>(
          future: _createTempMediaFile(sourcePath, ext, mimeType, isBase64),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data ?? const Text("Gagal memuat media");
          },
        );
      }
    }

    final fileUrl = "$sourcePath/$fileName";
    if (["mp4", "webm"].contains(ext)) {
      return Html(
        data: '''
      <video controls style="width:100%; border-radius:8px;">
        <source src="$fileUrl" type="video/$ext">
        Browser Anda tidak mendukung tag video.
      </video>
      ''',
      );
    } else if (["mp3", "wav", "ogg"].contains(ext)) {
      return Html(
        data: '''
      <audio controls style="width:100%;">
        <source src="$fileUrl" type="audio/$ext">
        Browser Anda tidak mendukung tag audio.
      </audio>
      ''',
      );
    } else {
      return Text(
        "Format file tidak dikenali${fileName.isEmpty ? "" : ": $fileName"}",
        style: const TextStyle(color: Colors.redAccent),
      );
    }
  }

  Future<Widget> _createTempMediaFile(
    String base64String,
    String ext,
    String mimeType,
    bool isBase64,
  ) async {
    try {
      final bytes = base64.decode(base64String.replaceAll(RegExp(r'\s+'), ''));
      final dir = await getTemporaryDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/temp_media_$timestamp.$ext');

      await file.writeAsBytes(bytes, flush: true);

      if (mimeType.startsWith('audio/')) {
        return _AudioPlayerWidget(filePath: file.path);
      } else if (mimeType.startsWith('video/')) {
        return _VideoPlayerWidget(
          filePath: file.path,
          isBase64: isBase64,
        );
      } else {
        return const Text("Format media tidak dikenali");
      }
    } catch (e) {
      return Text("Error memuat media: $e",
          style: const TextStyle(color: Colors.redAccent));
    }
  }

  Widget _buildAnswerArea(
    ThemeData theme,
    bool isDesktop,
    UjianDetilSoal? data,
    int currentIndex,
    int total,
  ) {
    final opsi = ['A', 'B', 'C', 'D', 'E'];
    final jawabanMap = <String, String>{
      'A': data?.soal?.jawabanA ?? '',
      'B': data?.soal?.jawabanB ?? '',
      'C': data?.soal?.jawabanC ?? '',
      'D': data?.soal?.jawabanD ?? '',
      'E': data?.soal?.jawabanE ?? '',
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 10 : 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double itemWidth = isDesktop
              ? 220
              : (maxWidth - (8 * (opsi.length - 1))) / opsi.length;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: opsi.map((option) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: itemWidth),
                    child: Obx(() {
                      final soal =
                          controller.dataSoal[controller.currentIndex.value];
                      // ignore: unused_local_variable
                      final kodeSoal = soal?.kodeSoal ?? "";
                      final isSelected =
                          controller.selectedAnswer.value == option;
                      final jawabanText = jawabanMap[option] ?? '';
                      if (jawabanText.isEmpty) return const SizedBox.shrink();

                      final Color activeColor = Colors.blueAccent;
                      final Color inactiveColor = Colors.grey.shade500;

                      return Material(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          splashColor: activeColor.withOpacity(0.2),
                          onTap: () => controller.selectAnswer(option),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color:
                                      isSelected ? activeColor : inactiveColor,
                                  size: isDesktop ? 22 : 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? activeColor
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 5),
              Obx(() {
                final soal = controller.dataSoal[controller.currentIndex.value];
                final kodeSoal = soal?.kodeSoal ?? "";
                final isMarked = controller.raguPerSoal[kodeSoal] ?? false;
                final bool raguEnabled =
                    controller.selectedAnswer.value.isNotEmpty;
                final bool isRaguDisabled = !raguEnabled;

                final Color activeColor = Colors.amber[900]!;
                final Color inactiveColor = Colors.grey;

                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth * 0.6),
                  child: Material(
                    color: isRaguDisabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    child: Tooltip(
                      message:
                          raguEnabled ? "Tandai sebagai jawaban ragu-ragu" : "",
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: activeColor.withOpacity(0.2),
                        onTap:
                            raguEnabled ? () => controller.toggleRagu() : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 14),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMarked
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isRaguDisabled
                                    ? inactiveColor
                                    : (isMarked ? activeColor : inactiveColor),
                                size: isDesktop ? 22 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Ragu-ragu",
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: isRaguDisabled
                                      ? Colors.grey.shade600
                                      : (isMarked
                                          ? activeColor
                                          : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  const _AudioPlayerWidget({required this.filePath});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onDurationChanged.listen((d) => setState(() => _total = d));
    _player.onPositionChanged.listen((p) => setState(() => _current = p));
    _player.onPlayerStateChanged.listen(
      (s) => setState(() => _isPlaying = s == ap.PlayerState.playing),
    );
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.audiotrack, size: 40, color: Colors.indigo),
          const SizedBox(height: 8),
          Slider(
            value: _current.inSeconds.toDouble(),
            max: _total.inSeconds.toDouble() == 0
                ? 1
                : _total.inSeconds.toDouble(),
            onChanged: (v) async {
              await _player.seek(Duration(seconds: v.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_current.inMinutes}:${(_current.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 6),
              Text(
                "/ ${_total.inMinutes}:${(_total.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isPlaying ? Colors.redAccent : Colors.indigoAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (_isPlaying) {
                await _player.pause();
              } else {
                await _player.play(DeviceFileSource(widget.filePath));
              }
            },
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            label: Text(
              _isPlaying ? "Pause" : "Putar Audio",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  final bool isBase64;

  const _VideoPlayerWidget({
    required this.filePath,
    required this.isBase64,
  });

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  Player? _player;
  VideoController? _controller;
  String? _tempFilePath;
  // ignore: unused_field
  bool _initialized = false;
  // ignore: unused_field
  bool _isError = false;
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  bool _looksLikeBase64(String input) {
    final isLikelyFilePath =
        input.contains(':\\') || input.contains('/') || input.contains('\\');
    final isLikelyBase64 = input.length > 100 &&
        !isLikelyFilePath &&
        RegExp(r'^[A-Za-z0-9+/=\s]+$').hasMatch(input);
    return isLikelyBase64;
  }

  Future<void> _initPlayer() async {
    try {
      MediaKit.ensureInitialized();

      String source = widget.filePath;
      final shouldDecodeBase64 = widget.isBase64 && _looksLikeBase64(source);

      if (shouldDecodeBase64) {
        try {
          final bytes = base64.decode(source.replaceAll(RegExp(r'\s+'), ''));
          final dir = await getTemporaryDirectory();
          final tempFile = File(
            '${dir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
          );
          await tempFile.writeAsBytes(bytes, flush: true);
          _tempFilePath = tempFile.path;
          source = tempFile.path;
        } catch (e) {
          debugPrint('⚠️ Base64 decode gagal, fallback ke file asli: $e');
        }
      } else {
        debugPrint('ℹ️ Gunakan path/file asli: $source');
      }

      _player = Player();
      _controller = VideoController(_player!);

      await _player!.open(Media(source));

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    if (_tempFilePath != null && widget.isBase64) {
      // ignore: body_might_complete_normally_catch_error
      File(_tempFilePath!).delete().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Video(
            controller: _controller!,
          ),
        ),
      ),
    );
  }
}
