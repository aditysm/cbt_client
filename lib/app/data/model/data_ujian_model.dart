// To parse this JSON data, do
//
//     final dataUjianModel = dataUjianModelFromJson(jsonString);

import 'dart:convert';

DataUjianModel dataUjianModelFromJson(String str) =>
    DataUjianModel.fromJson(json.decode(str));

String dataUjianModelToJson(DataUjianModel data) => json.encode(data.toJson());

class DataUjianModel {
  String? message;
  Data? data;

  DataUjianModel({
    this.message,
    this.data,
  });

  factory DataUjianModel.fromJson(Map<String, dynamic> json) => DataUjianModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? kodeUjian;
  DateTime? tanggal;
  String? namaUjian;
  String? tahunAjaran;
  String? semester;
  String? kodeMapel;
  String? programKeahlian;
  String? kelas;
  String? kodeGuru;
  int? jumlahSoal;
  int? jumlahPilihan;
  String? modelDurasi;
  int? durasi;
  DateTime? tanggalUjian;
  String? waktuDimulai;
  String? waktuBerakhir;
  String? statusAcakSoal;
  String? statusUjian;
  String? statusTampilHasil;
  String? namaRuang;
  int? sesi;
  String? transaksiOleh;
  Mapel? mapel;

  Data({
    this.kodeUjian,
    this.tanggal,
    this.namaUjian,
    this.tahunAjaran,
    this.semester,
    this.kodeMapel,
    this.programKeahlian,
    this.kelas,
    this.kodeGuru,
    this.jumlahSoal,
    this.jumlahPilihan,
    this.modelDurasi,
    this.durasi,
    this.tanggalUjian,
    this.waktuDimulai,
    this.waktuBerakhir,
    this.statusAcakSoal,
    this.statusUjian,
    this.statusTampilHasil,
    this.namaRuang,
    this.sesi,
    this.transaksiOleh,
    this.mapel,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        kodeUjian: json["kode_ujian"],
        tanggal:
            json["tanggal"] == null ? null : DateTime.parse(json["tanggal"]),
        namaUjian: json["nama_ujian"],
        tahunAjaran: json["tahun_ajaran"],
        semester: json["semester"],
        kodeMapel: json["kode_mapel"],
        programKeahlian: json["program_keahlian"],
        kelas: json["kelas"],
        kodeGuru: json["kode_guru"],
        jumlahSoal: json["jumlah_soal"],
        jumlahPilihan: json["jumlah_pilihan"],
        modelDurasi: json["model_durasi"],
        durasi: json["durasi"],
        tanggalUjian: json["tanggal_ujian"] == null
            ? null
            : DateTime.parse(json["tanggal_ujian"]),
        waktuDimulai: json["waktu_dimulai"],
        waktuBerakhir: json["waktu_berakhir"],
        statusAcakSoal: json["status_acak_soal"],
        statusUjian: json["status_ujian"],
        statusTampilHasil: json["status_tampil_hasil"],
        namaRuang: json["nama_ruang"],
        sesi: json["sesi"],
        transaksiOleh: json["transaksi_oleh"],
        mapel: json["mapel"] == null ? null : Mapel.fromJson(json["mapel"]),
      );

  Map<String, dynamic> toJson() => {
        "kode_ujian": kodeUjian,
        "tanggal":
            "${tanggal!.year.toString().padLeft(4, '0')}-${tanggal!.month.toString().padLeft(2, '0')}-${tanggal!.day.toString().padLeft(2, '0')}",
        "nama_ujian": namaUjian,
        "tahun_ajaran": tahunAjaran,
        "semester": semester,
        "kode_mapel": kodeMapel,
        "program_keahlian": programKeahlian,
        "kelas": kelas,
        "kode_guru": kodeGuru,
        "jumlah_soal": jumlahSoal,
        "jumlah_pilihan": jumlahPilihan,
        "model_durasi": modelDurasi,
        "durasi": durasi,
        "tanggal_ujian":
            "${tanggalUjian!.year.toString().padLeft(4, '0')}-${tanggalUjian!.month.toString().padLeft(2, '0')}-${tanggalUjian!.day.toString().padLeft(2, '0')}",
        "waktu_dimulai": waktuDimulai,
        "waktu_berakhir": waktuBerakhir,
        "status_acak_soal": statusAcakSoal,
        "status_ujian": statusUjian,
        "status_tampil_hasil": statusTampilHasil,
        "nama_ruang": namaRuang,
        "sesi": sesi,
        "transaksi_oleh": transaksiOleh,
        "mapel": mapel?.toJson(),
      };
}

class Mapel {
  String? kodeMapel;
  String? namaMapel;
  String? keterangan;

  Mapel({
    this.kodeMapel,
    this.namaMapel,
    this.keterangan,
  });

  factory Mapel.fromJson(Map<String, dynamic> json) => Mapel(
        kodeMapel: json["kode_mapel"],
        namaMapel: json["nama_mapel"],
        keterangan: json["keterangan"],
      );

  Map<String, dynamic> toJson() => {
        "kode_mapel": kodeMapel,
        "nama_mapel": namaMapel,
        "keterangan": keterangan,
      };
}
