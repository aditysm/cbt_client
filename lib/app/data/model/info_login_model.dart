// To parse this JSON data, do
//
//     final infoLoginModel = infoLoginModelFromJson(jsonString);

import 'dart:convert';

InfoLoginModel infoLoginModelFromJson(String str) =>
    InfoLoginModel.fromJson(json.decode(str));

String infoLoginModelToJson(InfoLoginModel data) => json.encode(data.toJson());

class InfoLoginModel {
  String? message;
  Data? data;

  InfoLoginModel({
    this.message,
    this.data,
  });

  factory InfoLoginModel.fromJson(Map<String, dynamic> json) => InfoLoginModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  DateTime? tanggal;
  String? waktuLogin;
  String? kodeUjian;
  String? nis;
  String? username;
  String? keterangan;

  Data({
    this.tanggal,
    this.waktuLogin,
    this.kodeUjian,
    this.nis,
    this.username,
    this.keterangan,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        tanggal:
            json["tanggal"] == null ? null : DateTime.parse(json["tanggal"]),
        waktuLogin: json["waktu_login"],
        kodeUjian: json["kode_ujian"],
        nis: json["nis"],
        username: json["username"],
        keterangan: json["keterangan"],
      );

  Map<String, dynamic> toJson() => {
        "tanggal":
            "${tanggal!.year.toString().padLeft(4, '0')}-${tanggal!.month.toString().padLeft(2, '0')}-${tanggal!.day.toString().padLeft(2, '0')}",
        "waktu_login": waktuLogin,
        "kode_ujian": kodeUjian,
        "nis": nis,
        "username": username,
        "keterangan": keterangan,
      };
}
