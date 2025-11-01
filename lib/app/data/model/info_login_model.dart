class InfoLogin {
  final DateTime tanggal; // Hanya tanggal
  final String waktuLogin; // Hanya time (HH:mm:ss)
  final String kodeUjian;
  final String nis;
  final String username;
  final String keterangan;

  InfoLogin({
    required this.tanggal,
    required this.waktuLogin,
    required this.kodeUjian,
    required this.nis,
    required this.username,
    required this.keterangan,
  });

  factory InfoLogin.fromJson(Map<String, dynamic> json) {
    return InfoLogin(
      tanggal: DateTime.parse(json['Tanggal']),
      waktuLogin: json['WaktuLogin'], 
      kodeUjian: json['KodeUjian'],
      nis: json['NIS'],
      username: json['Username'],
      keterangan: json['Keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Tanggal':
          tanggal.toIso8601String().split('T').first,
      'WaktuLogin': waktuLogin, 
      'KodeUjian': kodeUjian,
      'NIS': nis,
      'Username': username,
      'Keterangan': keterangan,
    };
  }

  DateTime get waktuLoginDateTime {
    final datePart = tanggal;
    final timeParts = waktuLogin.split(':');
    return DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    );
  }
}
