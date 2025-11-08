// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:aplikasi_cbt/app/modules/login/views/login_view.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/config_controller.dart';

final controller = Get.put(ConfigController());

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;
    var box = controller.box;
    if (controller.isLoadingFirst.isFalse) {
      controller.serverNameC.text = box.read('db_server_name') ?? '';
      final host = box.read('db_host') ?? "192.100.0.254";
      final port = box.read('db_port') ?? 3306;
      final user = box.read('db_user') ?? 'cbtclient';
      final password = box.read('db_pass') ?? '12345678@CBTclient';
      final dbName = box.read('db_name') ?? 'dbcbt';
      controller.hostC.text = host;
      controller.port.value = port;
      controller.userC.text = user;
      controller.passC.text = password;
      controller.dbNameC.text = dbName;
      controller.settingPassC.text = box.read('setting_pass') ?? '12345678';
      controller.unlockKeyC.text = box.read('unlock_key') ?? '12345678';
      controller.isLoadingFirst.value = true;
    }
    controller.isTesting.value = false;
    controller.testResult.value = "";

    var focus = FocusNode();
    if (AllMaterial.isDesktop) {
      focus.requestFocus();
    }
    return RawKeyboardListener(
      focusNode: focus,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          controller.testAndSave();
        }
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/login.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(color: Colors.black.withOpacity(0.4)),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
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
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: Image.asset(
                                      "assets/icons/logo-dikbud.png"),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Konfigurasi Aplikasi',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      textAlign: TextAlign.center,
                                      'Siapkan koneksi server dan pengaturan aplikasi.',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: !isDesktop ? 16 : 32),
                              if (AllMaterial.isDesktop)
                                Text(
                                  "Server Connection",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              if (AllMaterial.isDesktop)
                                const SizedBox(height: 12),
                              Obx(
                                () => TextField(
                                  controller: controller.hostC,
                                  focusNode: controller.hostF,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) =>
                                      controller.hostError.value = "",
                                  decoration: _inputDecoration(
                                    label: 'Nama Server',
                                    icon: Icons.house,
                                  ).copyWith(
                                    errorText:
                                        controller.hostError.value.isEmpty
                                            ? null
                                            : controller.hostError.value,
                                  ),
                                ),
                              ),
                              // SizedBox(height: isDesktop ? 16 : 8),
                              // Obx(
                              //   () => TextField(
                              //     controller: controller.portC,
                              //     focusNode: controller.portF,
                              //     keyboardType: TextInputType.number,
                              //     textInputAction: TextInputAction.next,
                              //     onChanged: (v) =>
                              //         controller.portError.value = "",
                              //     decoration: _inputDecoration(
                              //       label: 'Port',
                              //       icon: Icons.how_to_reg_sharp,
                              //     ).copyWith(
                              //       errorText:
                              //           controller.hostError.value.isEmpty
                              //               ? null
                              //               : controller.hostError.value,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: isDesktop ? 16 : 8),
                              Obx(
                                () => TextField(
                                  controller: controller.userC,
                                  focusNode: controller.userF,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) =>
                                      controller.userError.value = "",
                                  decoration: _inputDecoration(
                                    label: 'Username',
                                    icon: Icons.person,
                                  ).copyWith(
                                    errorText:
                                        controller.userError.value.isEmpty
                                            ? null
                                            : controller.userError.value,
                                  ),
                                ),
                              ),
                              SizedBox(height: isDesktop ? 16 : 8),
                              Obx(
                                () => TextField(
                                  controller: controller.passC,
                                  focusNode: controller.passF,
                                  textInputAction: TextInputAction.next,
                                  obscureText: true,
                                  onChanged: (v) =>
                                      controller.passError.value = "",
                                  decoration: _inputDecoration(
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                  ).copyWith(
                                    errorText:
                                        controller.passError.value.isEmpty
                                            ? null
                                            : controller.passError.value,
                                  ),
                                ),
                              ),
                              SizedBox(height: isDesktop ? 16 : 8),
                              Obx(
                                () => TextField(
                                  controller: controller.dbNameC,
                                  focusNode: controller.dbNameF,
                                  onChanged: (v) =>
                                      controller.dbNameError.value = "",
                                  decoration: _inputDecoration(
                                    label: 'Nama Database',
                                    icon: Icons.storage,
                                  ).copyWith(
                                    errorText:
                                        controller.dbNameError.value.isEmpty
                                            ? null
                                            : controller.dbNameError.value,
                                  ),
                                  onSubmitted: (_) => controller.testAndSave(),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (AllMaterial.isDesktop)
                                    const SizedBox(height: 24),
                                  if (AllMaterial.isDesktop)
                                    Text(
                                      "Form Setting",
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  SizedBox(height: isDesktop ? 12 : 8),
                                  Obx(() => TextField(
                                        controller: controller.settingPassC,
                                        focusNode: controller.settingPassF,
                                        onChanged: (v) => controller
                                            .settingPassError.value = "",
                                        decoration: _inputDecoration(
                                          label: 'Settings Password',
                                          icon: Icons.security,
                                        ).copyWith(
                                          errorText: controller.settingPassError
                                                  .value.isEmpty
                                              ? null
                                              : controller
                                                  .settingPassError.value,
                                        ),
                                      )),
                                  SizedBox(height: isDesktop ? 16 : 8),
                                  Obx(
                                    () => TextField(
                                      controller: controller.unlockKeyC,
                                      focusNode: controller.unlockKeyF,
                                      onChanged: (v) =>
                                          controller.unlockKeyError.value = "",
                                      decoration: _inputDecoration(
                                        label: 'CBT Unlock Keys',
                                        icon: Icons.vpn_key_outlined,
                                      ).copyWith(
                                        errorText: controller
                                                .unlockKeyError.value.isEmpty
                                            ? null
                                            : controller.unlockKeyError.value,
                                      ),
                                      onSubmitted: (_) =>
                                          controller.testAndSave(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isDesktop ? 32 : 16),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(
                                  () => ElevatedButton.icon(
                                    icon: controller.isTesting.value
                                        ? const SizedBox.shrink()
                                        : const Icon(Icons.playlist_add_check,
                                            color: Colors.white),
                                    label: controller.isTesting.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Tes & Simpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: controller.isTesting.value
                                        ? null
                                        : () => controller.testAndSave(),
                                  ),
                                ),
                              ),
                              SizedBox(height: isDesktop ? 12 : 6),
                              Obx(() {
                                if (controller.testResult.value.isEmpty) {
                                  return const SizedBox();
                                }
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    color: controller.testResult.value
                                            .contains("Berhasil")
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: controller.testResult.value
                                              .contains("Berhasil")
                                          ? Colors.green.shade200
                                          : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      controller.testResult.value
                                              .contains("Berhasil")
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          controller.testResult.value,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: controller.testResult.value
                                                    .contains("Berhasil")
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: isDesktop ? 12 : 6),
                              TextButton(
                                style: TextButton.styleFrom(
                                  fixedSize: Size.fromWidth(Get.width),
                                ),
                                onPressed: () {
                                  if (controller.settingPassC.text.isNotEmpty) {
                                    box.write('setting_pass',
                                        controller.settingPassC.text.trim());
                                  }

                                  if (controller.unlockKeyC.text.isNotEmpty) {
                                    box.write(
                                      'unlock_key',
                                      controller.unlockKeyC.text.trim(),
                                    );
                                  }

                                  Get.offAll(() => LoginView());
                                },
                                child: Text(
                                  "Buka halaman Login",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText?.isEmpty ?? true ? null : errorText,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
