import 'package:aplikasi_cbt/app/data/model/data_ujian_model.dart';
import 'package:aplikasi_cbt/app/data/model/info_login_model.dart';
import 'package:aplikasi_cbt/app/modules/student_confirmation/views/student_confirmation_view.dart';
import 'package:aplikasi_cbt/app/services/database_service.dart';
import 'package:aplikasi_cbt/app/services/network_service.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final usernameC = TextEditingController();
  static final usernameF = FocusNode();
  final passwordC = TextEditingController();
  final passwordF = FocusNode();
  final dbService = Get.find<DatabaseService>();
  final showPassword = false.obs;

  static final dataUjian = Rx<UserUjian?>(null);
  static final infoLogin = Rx<InfoLogin?>(null);

  static void startLogin() {
    usernameF.requestFocus();
  }

  final usernameError = "".obs;
  final passwordError = "".obs;
  static final allError = "".obs;

  static var mataPelajaran = "".obs;

  final keterangan = "".obs;

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  @override
  void onInit() {
    usernameC.addListener(() {
      if (usernameC.text.isNotEmpty) {
        usernameError.value = '';
        allError.value = '';
      }
    });
    passwordC.addListener(() {
      if (passwordC.text.isNotEmpty) {
        passwordError.value = '';
        allError.value = '';
      }
    });

    LoginController.infoLogin.value = null;
    LoginController.dataUjian.value = null;
    super.onInit();
  }

  bool _validateForm() {
    bool isValid = true;

    String input = usernameC.text.trim();

    if (input.isEmpty) {
      usernameError.value = "Username tidak boleh kosong!";
      usernameF.requestFocus();
      isValid = false;
    } else if (passwordC.text.trim().isEmpty) {
      passwordError.value = "Password tidak boleh kosong!";
      passwordF.requestFocus();
      isValid = false;
    }

    if (!isValid) {
      Future.delayed(const Duration(milliseconds: 300));
      allError.value = "Silahkan periksa kembali input Anda.";
      usernameF.requestFocus();
    }

    return isValid;
  }

  Future<void> login() async {
    usernameF.unfocus();
    passwordF.unfocus();
    await Future.delayed(Durations.medium2);
    isLoading.value = true;

    if (!_validateForm()) {
      isLoading.value = false;
      return;
    }

    LoginController.infoLogin.value = null;
    LoginController.dataUjian.value = null;
    update();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final test = await dbService.query("SELECT NOW() as waktu;");
      print("Koneksi DB berhasil: $test");
      final results = await dbService.query("""
      select a.KodeUjian,a.NIS,a.Username,a.Password,a.WaktuDimulai,a.WaktuBerakhir,a.StatusUjianSiswa,b.NamaSiswa,b.JenisKelamin,b.Foto,b.ProgramKeahlian,c.NamaUjian,c.ProgramKeahlian as ProgramKeahlianGabung,c.Kelas,c.KodeGuru,c.JumlahSoal,c.JumlahPilihan,c.ModelDurasi,c.Durasi,c.TanggalUjian,c.WaktuDimulai as WaktuDimulaiUjian,c.WaktuBerakhir as WaktuBerakhirUjian,c.StatusAcakSoal,c.StatusUjian,c.StatusTampilHasil,d.NamaMapel from (ujian_detil_siswa a inner join siswa b on a.NIS=b.NIS inner join ujian c on a.KodeUjian=c.KodeUjian inner join mata_pelajaran d on c.KodeMapel=d.KodeMapel) where a.Username= ?
    """, [usernameC.text.trim()]);

      print(results);
      print(usernameC.text.trim());
      print(passwordC.text.trim());
      final data = results.first;

      final statusUjian = data["StatusUjian"] ?? "";

      if (results.isEmpty) {
        allError.value = "Username tidak ditemukan";
        ToastService.show("Username tidak ditemukan");
        usernameF.requestFocus();
        return;
      } else {
        print("statusUjian: $statusUjian");
        if (statusUjian == "Menunggu Konfigurasi" ||
            statusUjian == "Ujian Selesai") {
          allError.value = "Ujian tidak valid!";
          ToastService.show("Ujian tidak valid!");
          usernameF.requestFocus();
          isLoading.value = false;
          return;
        }

        final statusUjianSiswa = data["StatusUjianSiswa"] ?? "";
        print("statusUjianSiswa: $statusUjianSiswa");
        if (statusUjianSiswa == "Selesai Ujian") {
          allError.value = "Username sudah tidak dapat digunakan!";
          ToastService.show("Username sudah tidak dapat digunakan!");
          usernameF.requestFocus();
          isLoading.value = false;
          return;
        }

        final pass = data["Password"] ?? "";
        if ((passwordC.text.trim()) != pass) {
          allError.value = "Password salah!";
          ToastService.show("Password salah!");
          passwordF.requestFocus();
          isLoading.value = false;
          return;
        }
      }

      final firstResult = results.first;
      print("firstResult: $firstResult");
      dataUjian.value = UserUjian.fromJson(firstResult);

      final now = DateTime.now();
      final tanggal =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final waktuLogin =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final kodeUjian = dataUjian.value?.kodeUjian ?? "";
      final nis = dataUjian.value?.nis ?? "";
      final username = dataUjian.value?.username ?? "";

      await isiKeterangan();

      await dbService.execute("""
  INSERT INTO info_login (
    Tanggal, WaktuLogin, KodeUjian, NIS, Username, Keterangan
  ) VALUES (?, ?, ?, ?, ?, ?)
""", [tanggal, waktuLogin, kodeUjian, nis, username, keterangan.value]);

      infoLogin.value = InfoLogin(
        tanggal: DateTime.now(),
        waktuLogin: waktuLogin,
        kodeUjian: kodeUjian,
        nis: nis,
        username: username,
        keterangan: keterangan.value,
      );

      ToastService.show(
          "Login berhasil. Selamat datang, ${dataUjian.value?.namaSiswa}!");
      Get.offAll(() => StudentConfirmationView());
      usernameC.clear();
      passwordC.clear();
      allError.value = "";
    } catch (e) {
      allError.value = AllMaterial.getErrorMessageFromException(e.toString());
    } finally {
      isLoading.value = false;
    }
    update();
  }

  Future<void> isiKeterangan() async {
    final host = await NetworkHelper.getHostName();
    final ip = await NetworkHelper.getIPAddress();
    final mac = await NetworkHelper.getMacAddress();

    keterangan.value =
        "Host Name : $host, IP Address : $ip, MAC Address : $mac";
  }
}
