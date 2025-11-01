class Soal {
  final String kodeSoal;
  final DateTime tanggal;
  final String kodeMapel;
  final String kategori;
  final int jumlahPilihan;
  final String uraianSoal;
  final String jawabanA;
  final String jawabanB;
  final String jawabanC;
  final String jawabanD;
  final String jawabanE;
  final String jawabanBenar;
  final String sourceAudioVideo;
  final String namaFile;
  final String transaksiOleh;

  Soal({
    required this.kodeSoal,
    required this.tanggal,
    required this.kodeMapel,
    required this.kategori,
    required this.jumlahPilihan,
    required this.uraianSoal,
    required this.jawabanA,
    required this.jawabanB,
    required this.jawabanC,
    required this.jawabanD,
    required this.jawabanE,
    required this.jawabanBenar,
    required this.sourceAudioVideo,
    required this.namaFile,
    required this.transaksiOleh,
  });

  factory Soal.fromMap(Map<String, dynamic> map) {
    return Soal(
      kodeSoal: map['KodeSoal']?.toString() ?? '',
      tanggal: map['Tanggal'] is DateTime
          ? map['Tanggal'] as DateTime
          : DateTime.tryParse(map['Tanggal']?.toString() ?? '') ??
              DateTime(1970),
      kodeMapel: map['KodeMapel']?.toString() ?? '',
      kategori: map['Kategori']?.toString() ?? '',
      jumlahPilihan: map['JumlahPilihan'] is int
          ? map['JumlahPilihan'] as int
          : int.tryParse(map['JumlahPilihan']?.toString() ?? '0') ?? 0,
      uraianSoal: map['UraianSoal']?.toString() ?? '',
      jawabanA: map['JawabanA']?.toString() ?? '',
      jawabanB: map['JawabanB']?.toString() ?? '',
      jawabanC: map['JawabanC']?.toString() ?? '',
      jawabanD: map['JawabanD']?.toString() ?? '',
      jawabanE: map['JawabanE']?.toString() ?? '',
      jawabanBenar: map['JawabanBenar']?.toString() ?? '',
      sourceAudioVideo: map['SourceAudioVideo']?.toString() ?? '',
      namaFile: map['NamaFile']?.toString() ?? '',
      transaksiOleh: map['TransaksiOleh']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'KodeSoal': kodeSoal,
      'Tanggal': tanggal.toIso8601String(),
      'KodeMapel': kodeMapel,
      'Kategori': kategori,
      'JumlahPilihan': jumlahPilihan,
      'UraianSoal': uraianSoal,
      'JawabanA': jawabanA,
      'JawabanB': jawabanB,
      'JawabanC': jawabanC,
      'JawabanD': jawabanD,
      'JawabanE': jawabanE,
      'JawabanBenar': jawabanBenar,
      'SourceAudioVideo': sourceAudioVideo,
      'NamaFile': namaFile,
      'TransaksiOleh': transaksiOleh,
    };
  }
}
