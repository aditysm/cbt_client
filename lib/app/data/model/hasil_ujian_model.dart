// To parse this JSON data, do
//
//     final hasilUjianModel = hasilUjianModelFromJson(jsonString);

import 'dart:convert';

HasilUjianModel hasilUjianModelFromJson(String str) =>
    HasilUjianModel.fromJson(json.decode(str));

String hasilUjianModelToJson(HasilUjianModel data) =>
    json.encode(data.toJson());

class HasilUjianModel {
  String? message;
  Data? data;

  HasilUjianModel({
    this.message,
    this.data,
  });

  factory HasilUjianModel.fromJson(Map<String, dynamic> json) =>
      HasilUjianModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? jumlahSoal;
  int? jumlahSoalDijawab;
  int? jumlahSoalTidakDijawab;
  int? jumlahBenar;
  int? jumlahSalah;
  double? nilaiAkhir;

  Data({
    this.jumlahSoal,
    this.jumlahSoalDijawab,
    this.jumlahSoalTidakDijawab,
    this.jumlahBenar,
    this.jumlahSalah,
    this.nilaiAkhir,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        jumlahSoal: json["jumlah_soal"],
        jumlahSoalDijawab: json["jumlah_soal_dijawab"],
        jumlahSoalTidakDijawab: json["jumlah_soal_tidak_dijawab"],
        jumlahBenar: json["jumlah_benar"],
        jumlahSalah: json["jumlah_salah"],
        nilaiAkhir: json["nilai_akhir"],
      );

  Map<String, dynamic> toJson() => {
        "jumlah_soal": jumlahSoal,
        "jumlah_soal_dijawab": jumlahSoalDijawab,
        "jumlah_soal_tidak_dijawab": jumlahSoalTidakDijawab,
        "jumlah_benar": jumlahBenar,
        "jumlah_salah": jumlahSalah,
        "nilai_akhir": nilaiAkhir,
      };
}
