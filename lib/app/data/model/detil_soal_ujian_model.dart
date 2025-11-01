import 'package:aplikasi_cbt/app/data/model/soal_ujian_model.dart';

class UjianDetilSoal {
  final String kodeUjian;
  final int nomorUrut;
  final String kodeSoal;
  final String transaksiOleh;
  final String statusAcak;
  final Soal? soal;

  UjianDetilSoal({
    required this.kodeUjian,
    required this.nomorUrut,
    required this.kodeSoal,
    required this.transaksiOleh,
    required this.statusAcak,
    this.soal,
  });

  factory UjianDetilSoal.fromJson(Map<String, dynamic> map) {
    return UjianDetilSoal(
      kodeUjian: map['uds_KodeUjian']?.toString() ?? '',
      nomorUrut: map['uds_NomorUrut'] is int
          ? map['uds_NomorUrut'] as int
          : int.tryParse(map['uds_NomorUrut']?.toString() ?? '0') ?? 0,
      kodeSoal: map['uds_KodeSoal']?.toString() ?? '',
      transaksiOleh: map['uds_TransaksiOleh']?.toString() ?? '',
      statusAcak: map['uds_StatusAcak']?.toString() ?? '',
      soal: map['s_KodeSoal'] != null
          ? Soal.fromMap({
              'KodeSoal': map['s_KodeSoal'],
              'Tanggal': map['s_Tanggal'],
              'KodeMapel': map['s_KodeMapel'],
              'Kategori': map['s_Kategori'],
              'JumlahPilihan': map['s_JumlahPilihan'],
              'UraianSoal': map['s_UraianSoal'],
              'JawabanA': map['s_JawabanA'],
              'JawabanB': map['s_JawabanB'],
              'JawabanC': map['s_JawabanC'],
              'JawabanD': map['s_JawabanD'],
              'JawabanE': map['s_JawabanE'],
              'JawabanBenar': map['s_JawabanBenar'],
              'SourceAudioVideo': map['s_SourceAudioVideo'],
              'NamaFile': map['s_NamaFile'],
              'TransaksiOleh': map['s_TransaksiOleh'],
            })
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'KodeUjian': kodeUjian,
      'NomorUrut': nomorUrut,
      'KodeSoal': kodeSoal,
      'TransaksiOleh': transaksiOleh,
      'StatusAcak': statusAcak,
      'Soal': soal?.toMap(),
    };
  }
}
