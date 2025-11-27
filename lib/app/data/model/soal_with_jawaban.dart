// To parse this JSON data, do
//
//     final listSoalWithHasilModel = listSoalWithHasilModelFromJson(jsonString);

import 'dart:convert';

ListSoalWithHasilModel listSoalWithHasilModelFromJson(String str) =>
    ListSoalWithHasilModel.fromJson(json.decode(str));

String listSoalWithHasilModelToJson(ListSoalWithHasilModel data) =>
    json.encode(data.toJson());

class ListSoalWithHasilModel {
  String? message;
  List<SoalWithHasil>? data;

  ListSoalWithHasilModel({
    this.message,
    this.data,
  });

  factory ListSoalWithHasilModel.fromJson(Map<String, dynamic> json) =>
      ListSoalWithHasilModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SoalWithHasil>.from(json["data"]!.map((x) => SoalWithHasil.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SoalWithHasil {
  Soal? soal;
  Hasil? hasil;

  SoalWithHasil({
    this.soal,
    this.hasil,
  });

  factory SoalWithHasil.fromJson(Map<String, dynamic> json) => SoalWithHasil(
        soal: json["soal"] == null ? null : Soal.fromJson(json["soal"]),
        hasil: json["hasil"] == null ? null : Hasil.fromJson(json["hasil"]),
      );

  Map<String, dynamic> toJson() => {
        "soal": soal?.toJson(),
        "hasil": hasil?.toJson(),
      };
}

class Hasil {
  String? kodeUjian;
  String? nis;
  String? kodeSoal;
  int? nomorSoal;
  String? jawabanBenar;
  String? pilihanJawaban;
  String? statusRaguRagu;
  String? statusUpload;
  String? keteranganUpload;

  Hasil({
    this.kodeUjian,
    this.nis,
    this.kodeSoal,
    this.nomorSoal,
    this.jawabanBenar,
    this.pilihanJawaban,
    this.statusRaguRagu,
    this.statusUpload,
    this.keteranganUpload,
  });

  factory Hasil.fromJson(Map<String, dynamic> json) => Hasil(
        kodeUjian: json["kode_ujian"]!,
        nis: json["nis"],
        kodeSoal: json["kode_soal"],
        nomorSoal: json["nomor_soal"],
        jawabanBenar: json["jawaban_benar"],
        pilihanJawaban: json["pilihan_jawaban"]!,
        statusRaguRagu: json["status_ragu_ragu"],
        statusUpload: json["status_upload"],
        keteranganUpload: json["keterangan_upload"],
      );

  Map<String, dynamic> toJson() => {
        "kode_ujian": kodeUjian,
        "nis": nis,
        "kode_soal": kodeSoal,
        "nomor_soal": nomorSoal,
        "jawaban_benar": jawabanBenar,
        "pilihan_jawaban": pilihanJawaban,
        "status_ragu_ragu": statusRaguRagu,
        "status_upload": statusUpload,
        "keterangan_upload": keteranganUpload,
      };
}


class Soal {
  String? kodeSoal;
  DateTime? tanggal;
  String? kodeMapel;
  String? kategori;
  int? jumlahPilihan;
  String? uraianSoal;
  String? jawabanA;
  String? jawabanB;
  String? jawabanC;
  String? jawabanD;
  String? jawabanE;
  String? jawabanBenar;
  String? sourceAudioVideo;
  String? namaFile;
  String? transaksiOleh;

  Soal({
    this.kodeSoal,
    this.tanggal,
    this.kodeMapel,
    this.kategori,
    this.jumlahPilihan,
    this.uraianSoal,
    this.jawabanA,
    this.jawabanB,
    this.jawabanC,
    this.jawabanD,
    this.jawabanE,
    this.jawabanBenar,
    this.sourceAudioVideo,
    this.namaFile,
    this.transaksiOleh,
  });

  factory Soal.fromJson(Map<String, dynamic> json) => Soal(
        kodeSoal: json["kode_soal"],
        tanggal:
            json["tanggal"] == null ? null : DateTime.parse(json["tanggal"]),
        kodeMapel: json["kode_mapel"]!,
        kategori: json["kategori"]!,
        jumlahPilihan: json["jumlah_pilihan"],
        uraianSoal: json["uraian_soal"],
        jawabanA: json["jawaban_a"],
        jawabanB: json["jawaban_b"],
        jawabanC: json["jawaban_c"],
        jawabanD: json["jawaban_d"],
        jawabanE: json["jawaban_e"],
        jawabanBenar: json["jawaban_benar"],
        sourceAudioVideo: json["source_audio_video"],
        namaFile: json["nama_file"],
        transaksiOleh: json["transaksi_oleh"]!,
      );

  Map<String, dynamic> toJson() => {
        "kode_soal": kodeSoal,
        "tanggal": tanggal?.toIso8601String(),
        "kode_mapel": kodeMapel,
        "kategori": kategori,
        "jumlah_pilihan": jumlahPilihan,
        "uraian_soal": uraianSoal,
        "jawaban_a": jawabanA,
        "jawaban_b": jawabanB,
        "jawaban_c": jawabanC,
        "jawaban_d": jawabanD,
        "jawaban_e": jawabanE,
        "jawaban_benar": jawabanBenar,
        "source_audio_video": sourceAudioVideo,
        "nama_file": namaFile,
        "transaksi_oleh": transaksiOleh,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
