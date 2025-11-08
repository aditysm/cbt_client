// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:aplikasi_cbt/app/modules/config/views/config_view.dart';
import 'package:aplikasi_cbt/app/utils/app_colors.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

final controller = Get.put(LoginController());

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    controller.usernameF.requestFocus();
    var focus = FocusNode();
    if (AllMaterial.isDesktop) {
      focus.requestFocus();
    }

    return RawKeyboardListener(
      focusNode: focus,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          controller.login();
        }
      },
      child: Scaffold(
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
                              // Logo
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: Image.asset(
                                      "assets/icons/logo-smeda.png"),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Login ke CBT Client',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Harap lengkapi data diri untuk melanjutkan.",
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              Obx(
                                () => TextField(
                                  controller: controller.usernameC,
                                  focusNode: controller.usernameF,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: _inputDecoration(
                                    errorText: controller.usernameError.value,
                                    label: 'Username',
                                    icon: Icons.person,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => TextField(
                                  controller: controller.passwordC,
                                  focusNode: controller.passwordF,
                                  obscureText: !controller.showPassword.value,
                                  style: const TextStyle(color: Colors.black54),
                                  decoration: _inputDecoration(
                                    label: "Password",
                                    icon: Icons.lock_outline,
                                    errorText: controller.passwordError.value,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showPassword.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black54,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                  onSubmitted: (_) => controller.login(),
                                ),
                              ),

                              const SizedBox(height: 32),

                              Obx(
                                () => controller.allError.isEmpty
                                    ? const SizedBox.shrink()
                                    : Text(
                                        controller.allError.value,
                                        style: const TextStyle(
                                            color: Colors.redAccent),
                                      ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: Obx(
                                  () => ElevatedButton.icon(
                                    icon: controller.isLoading.value
                                        ? const SizedBox.shrink()
                                        : const Icon(Icons.login,
                                            color: Colors.white),
                                    label: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
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
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () => controller.login(),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              TextButton(
                                style: TextButton.styleFrom(
                                  fixedSize: Size.fromWidth(Get.width),
                                ),
                                onPressed: () {
                                  String storedKeyword =
                                      AllMaterial.box.read('setting_pass') ??
                                          "";

                                  String typedValue = "";

                                  if (storedKeyword.isEmpty) {
                                    Get.offAll(() => ConfigView());
                                  } else {
                                    AllMaterial.cusDialogInput(
                                      title: "Masukkan Kata Kunci",
                                      onChanged: (value) {
                                        typedValue = value.trim();
                                      },
                                      onTap: () {
                                        if (typedValue == storedKeyword) {
                                          Get.back();
                                          Get.offAll(() => ConfigView());
                                        } else {
                                          ToastService.show(
                                              "Kata kunci tidak sesuai, silakan coba lagi.");
                                        }
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  "Buka halaman Konfigurasi Server",
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red.shade400,
          onPressed: () {
            AllMaterial.exitApp();
          },
          tooltip: "Keluar Aplikasi",
          child: Icon(
            Icons.power_settings_new,
            color: Colors.white,
          ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
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
