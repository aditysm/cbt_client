import 'package:aplikasi_cbt/app/utils/app_material.dart';

abstract class ApiUrl {
  static String get base =>
      "http://${AllMaterial.baseUrl.value}:${AllMaterial.port.value}";

  // PUBLIC
  static String get getDateTime => "$base/api/datetime";
  static String get testConnection => "$base/api/tes-koneksi";

  // AUTH
  static String get loginUrl => "$base/api/auth/login";
  static String get logoutUrl => "$base/api/auth/logout";

  // SISWA
  static String get konfirmasiDataSiswaUrl =>
      "$base/api/siswa/konfirmasi-data-siswa";
  static String get konfirmasiDataUjianUrl =>
      "$base/api/siswa/konfirmasi-data/ujian";
  static String get cekStatusUjianUrl => "$base/api/siswa/cek/ujian";
  static String get mulaiUjianUrl => "$base/api/siswa/mulai/ujian";
  static String get akhiriUjianUrl => "$base/api/siswa/akhiri/ujian";
  static String get allSoalWithHasilUrl => "$base/api/siswa/ujian/hasil/soal";
  static String get ujianHasilUrl => "$base/api/siswa/ujian/hasil";
  static String get reviewHasilUrl => "$base/api/siswa/ujian/review/hasil";
  static String get infoLoginUrl => "$base/api/siswa/info-login";
  static String get komentarUrl => "$base/api/siswa/komentar";
}
