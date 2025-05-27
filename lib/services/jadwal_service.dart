import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/jadwal_model.dart';
import 'package:deperlas_futsal/models/absen_model.dart';

class JadwalService {
  final String baseUrl = 'https://deperlas.noxhub.web.id/api';

  Future<JadwalResponse> fetchJadwal(String tipeJadwal) async {
    final url = '$baseUrl/jadwal?tipe_jadwal=$tipeJadwal';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return JadwalResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Gagal memuat jadwal (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil jadwal: $e');
    }
  }

  Future<AbsenResponse> bukaAbsen(String jadwalId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal/$jadwalId/buka-absen'),
      );
      if (response.statusCode == 200) {
        return AbsenResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Gagal membuka absen (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuka absen: $e');
    }
  }

  Future<AbsenResponse> tutupAbsen(String jadwalId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal/$jadwalId/tutup-absen'),
      );
      if (response.statusCode == 200) {
        return AbsenResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Gagal menutup absen (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menutup absen: $e');
    }
  }

  Future<AbsenResponse> absenPemain(String userId, String jadwalId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absen'),
        body: json.encode({
          'user_id': userId,
          'jadwal_id': jadwalId,
          'status': 'Hadir',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return AbsenResponse.fromJson(json.decode(response.body));
      } else {
        final body = json.decode(response.body);

        // Tangkap pesan spesifik jika pemain sudah absen
        final String errorMessage =
            body['message']?.toString().toLowerCase() ?? '';

        if (errorMessage.contains('sudah') || errorMessage.contains('absen')) {
          throw Exception('Kamu sudah melakukan absen hari ini.');
        }

        throw Exception(
          'Gagal melakukan absen: ${body['message'] ?? response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat melakukan absen: $e');
    }
  }

  Future<List<RekapAbsen>> getRekapAbsen(String jadwalId) async {
    final url = '$baseUrl/rekap-absen/$jadwalId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return List<RekapAbsen>.from(
            jsonResponse['data'].map((x) => RekapAbsen.fromJson(x)),
          );
        } else {
          throw Exception(
            'Gagal mengambil rekap absen: ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception(
          'Gagal mengambil rekap absen (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil rekap absen: $e');
    }
  }
}
