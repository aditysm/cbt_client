import 'package:mysql1/mysql1.dart';

class UserUjian {
  final String kodeUjian;
  final String nis;
  final String username;
  final String password;
  final DateTime tanggal;
  final Duration waktuDimulai;
  final Duration waktuBerakhir;
  String statusUjianSiswa;
  final String namaSiswa;
  final String jenisKelamin;
  final Blob? foto;
  final String programKeahlian;
  final String namaUjian;
  final String programKeahlianGabung;
  final String kelas;
  final String kodeGuru;
  final String namaGuru;
  final int jumlahSoal;
  final int jumlahPilihan;
  final String modelDurasi;
  final int durasi;
  final Duration waktuDimulaiUjian;
  final Duration waktuBerakhirUjian;
  final String statusAcakSoal;
  final String statusUjian;
  final String statusTampilHasil;
  final String namaMapel;
  final String namaRuang;

  UserUjian({
    required this.kodeUjian,
    required this.nis,
    required this.tanggal,
    required this.namaRuang,
    required this.username,
    required this.namaGuru,
    required this.password,
    required this.waktuDimulai,
    required this.waktuBerakhir,
    required this.statusUjianSiswa,
    required this.waktuDimulaiUjian,
    required this.namaSiswa,
    required this.jenisKelamin,
    this.foto,
    required this.programKeahlian,
    required this.namaUjian,
    required this.programKeahlianGabung,
    required this.kelas,
    required this.kodeGuru,
    required this.jumlahSoal,
    required this.jumlahPilihan,
    required this.modelDurasi,
    required this.durasi,
    required this.waktuBerakhirUjian,
    required this.statusAcakSoal,
    required this.statusUjian,
    required this.statusTampilHasil,
    required this.namaMapel,
  });

  factory UserUjian.fromJson(Map<String, dynamic> json) {
    return UserUjian(
      kodeUjian: json['KodeUjian'] ?? "",
      nis: json['NIS'] ?? "",
      waktuDimulaiUjian: json['WaktuDimulaiUjian'] ?? Duration(),
      username: json['Username'] ?? "",
      password: json['Password'] ?? "",
      tanggal: json['TanggalUjian'] ?? "",
      namaGuru: json['NamaGuru'] ?? "",
      waktuDimulai: json['WaktuDimulai'] ?? Duration(),
      waktuBerakhir: json['WaktuBerakhir'] ?? Duration(),
      statusUjianSiswa: json['StatusUjianSiswa'] ?? "",
      namaSiswa: json['NamaSiswa'] ?? "",
      jenisKelamin: json['JenisKelamin'] ?? "",
      foto: json['Foto'] ?? Blob,
      programKeahlian: json['ProgramKeahlian'] ?? "",
      namaUjian: json['NamaUjian'] ?? "",
      programKeahlianGabung: json['ProgramKeahlianGabung'] ?? "",
      kelas: json['Kelas'] ?? "",
      kodeGuru: json['KodeGuru'] ?? "",
      jumlahSoal: json['JumlahSoal'] ?? 0,
      jumlahPilihan: json['JumlahPilihan'] ?? 0,
      modelDurasi: json['ModelDurasi'] ?? "",
      durasi: json['Durasi'] ?? Duration(),
      waktuBerakhirUjian: json['WaktuBerakhirUjian'] ?? Duration(),
      statusAcakSoal: json['StatusAcakSoal'] ?? "",
      statusUjian: json['StatusUjian'] ?? "",
      statusTampilHasil: json['StatusTampilHasil'] ?? "",
      namaMapel: json['NamaMapel'] ?? "",
      namaRuang: json['NamaRuang'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'KodeUjian': kodeUjian,
      'NIS': nis,
      'Username': username,
      'Password': password,
      'WaktuDimulai': waktuDimulai,
      'WaktuBerakhir': waktuBerakhir,
      'StatusUjianSiswa': statusUjianSiswa,
      'NamaSiswa': namaSiswa,
      'TanggalUjian': tanggal,
      'NamaGuru': namaGuru,
      'JenisKelamin': jenisKelamin,
      'Foto': foto,
      'ProgramKeahlian': programKeahlian,
      'WaktuDimulaiUjian': waktuDimulaiUjian,
      'NamaUjian': namaUjian,
      'ProgramKeahlianGabung': programKeahlianGabung,
      'Kelas': kelas,
      'KodeGuru': kodeGuru,
      'JumlahSoal': jumlahSoal,
      'JumlahPilihan': jumlahPilihan,
      'ModelDurasi': modelDurasi,
      'Durasi': durasi,
      'WaktuBerakhirUjian': waktuBerakhirUjian,
      'StatusAcakSoal': statusAcakSoal,
      'StatusUjian': statusUjian,
      'StatusTampilHasil': statusTampilHasil,
      'NamaMapel': namaMapel,
      'NamaRuang': namaRuang,
    };
  }

  String get tanggalUjianFormatted {
    return "${tanggal.day.toString().padLeft(2, '0')}/"
        "${tanggal.month.toString().padLeft(2, '0')}/"
        "${tanggal.year}";
  }
}
