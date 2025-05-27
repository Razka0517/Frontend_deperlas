class AbsenResponse {
  final bool success;
  final String message;

  AbsenResponse({required this.success, required this.message});

  factory AbsenResponse.fromJson(Map<String, dynamic> json) {
    return AbsenResponse(success: json['success'], message: json['message']);
  }
}

class RekapAbsen {
  final String namaPemain;
  final String userId;
  final String status; // status = 'Hadir' atau 'Tidak Hadir'

  RekapAbsen({
    required this.namaPemain,
    required this.userId,
    required this.status,
  });

  factory RekapAbsen.fromJson(Map<String, dynamic> json) {
    return RekapAbsen(
      namaPemain: json['nama'] ?? 'Tidak Diketahui',
      userId: json['user_id'] ?? 'Tidak Diketahui',
      status: json['status'] ?? 'Tidak Hadir',
    );
  }
}
