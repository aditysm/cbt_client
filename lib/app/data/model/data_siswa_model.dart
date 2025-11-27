// To parse this JSON data, do
//
//     final dataSiswaModel = dataSiswaModelFromJson(jsonString);

import 'dart:convert';

DataSiswaModel dataSiswaModelFromJson(String str) =>
    DataSiswaModel.fromJson(json.decode(str));

String dataSiswaModelToJson(DataSiswaModel data) => json.encode(data.toJson());

class DataSiswaModel {
  String? message;
  Data? data;

  DataSiswaModel({
    this.message,
    this.data,
  });

  factory DataSiswaModel.fromJson(Map<String, dynamic> json) => DataSiswaModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? nis;
  String? namaSiswa;
  String? jenisKelamin;
  DateTime? tanggalLahir;
  String? agama;
  String? alamat;
  String? nisn;
  String? programKeahlian;
  String? kelas;
  String? keterangan;
  List<dynamic>? foto;

  Data({
    this.nis,
    this.namaSiswa,
    this.jenisKelamin,
    this.tanggalLahir,
    this.agama,
    this.alamat,
    this.nisn,
    this.programKeahlian,
    this.kelas,
    this.keterangan,
    this.foto,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        nis: json["nis"],
        namaSiswa: json["nama_siswa"],
        jenisKelamin: json["jenis_kelamin"],
        tanggalLahir: json["tanggal_lahir"] == null
            ? null
            : DateTime.parse(json["tanggal_lahir"]),
        agama: json["agama"],
        alamat: json["alamat"],
        nisn: json["nisn"],
        programKeahlian: json["program_keahlian"],
        kelas: json["kelas"],
        keterangan: json["keterangan"],
        foto: json["foto"],
      );

  Map<String, dynamic> toJson() => {
        "nis": nis,
        "nama_siswa": namaSiswa,
        "jenis_kelamin": jenisKelamin,
        "tanggal_lahir":
            "${tanggalLahir!.year.toString().padLeft(4, '0')}-${tanggalLahir!.month.toString().padLeft(2, '0')}-${tanggalLahir!.day.toString().padLeft(2, '0')}",
        "agama": agama,
        "alamat": alamat,
        "nisn": nisn,
        "program_keahlian": programKeahlian,
        "kelas": kelas,
        "keterangan": keterangan,
        "foto": foto,
      };
}
