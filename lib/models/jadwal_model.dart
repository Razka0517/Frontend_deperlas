class JadwalResponse {
  final bool success;
  final String message;
  final List<Jadwal> data;

  JadwalResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JadwalResponse.fromJson(Map<String, dynamic> json) {
    return JadwalResponse(
      success: json['success'],
      message: json['message'],
      data: List<Jadwal>.from(json['data'].map((x) => Jadwal.fromJson(x))),
    );
  }
}

class Jadwal {
  final String jadwalId;
  final String tipeJadwal;
  final String tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String lokasi;
  final String status;
  final List<Pelatih> pelatih;
  final String timLawan;

  Jadwal({
    required this.jadwalId,
    required this.tipeJadwal,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.lokasi,
    required this.status,
    required this.pelatih,
    required this.timLawan,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      jadwalId: json['jadwal_id'],
      tipeJadwal: json['tipe_jadwal'],
      tanggal: json['tanggal'],
      waktuMulai: json['waktu_mulai'],
      waktuSelesai: json['waktu_selesai'],
      lokasi: json['lokasi'],
      status: json['status'],
      pelatih: List<Pelatih>.from(
        json['pelatih'].map((x) => Pelatih.fromJson(x)),
      ),
      timLawan: json['tim_lawan'] ?? 'Tim Lawan',
    );
  }

  String getDayName() {
    DateTime date = DateTime.parse(tanggal);
    switch (date.weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }
}

class Pelatih {
  final String nama;

  Pelatih({required this.nama});

  factory Pelatih.fromJson(Map<String, dynamic> json) {
    return Pelatih(nama: json['nama']);
  }
}
