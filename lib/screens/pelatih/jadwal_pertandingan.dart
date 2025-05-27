import 'package:flutter/material.dart';
import 'package:deperlas_futsal/models/user_model.dart';
import 'package:deperlas_futsal/models/jadwal_model.dart';
import 'package:deperlas_futsal/services/jadwal_service.dart';
import 'pelatih_dashboard.dart';

class JadwalPertandinganScreen extends StatefulWidget {
  final User user;

  const JadwalPertandinganScreen({super.key, required this.user});

  @override
  State<JadwalPertandinganScreen> createState() =>
      _JadwalPertandinganScreenState();
}

class _JadwalPertandinganScreenState extends State<JadwalPertandinganScreen> {
  late Future<JadwalResponse> _jadwalFuture;
  final JadwalService _jadwalService = JadwalService();

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  void _loadJadwal() {
    setState(() {
      _jadwalFuture = _jadwalService.fetchJadwal('PRT');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF320B87),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PelatihDashboard(user: widget.user),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'INFO\nPERTANDINGAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<JadwalResponse>(
                  future: _jadwalFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Gagal memuat jadwal',
                              style: TextStyle(color: Colors.white),
                            ),
                            ElevatedButton(
                              onPressed: _loadJadwal,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada jadwal pertandingan',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.data.length,
                        itemBuilder: (context, index) {
                          final jadwal = snapshot.data!.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: MatchCard(
                              matchTitle: 'Deperlas VS ${jadwal.timLawan}',
                              date: _formatDate(jadwal.tanggal),
                              location: jadwal.lokasi,
                              waktu:
                                  '${jadwal.waktuMulai.substring(0, 5)} - ${jadwal.waktuSelesai.substring(0, 5)}',
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day;
      final month = _getMonthName(date.month);
      final year = date.year;
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}

class MatchCard extends StatelessWidget {
  final String matchTitle;
  final String date;
  final String location;
  final String waktu;

  const MatchCard({
    super.key,
    required this.matchTitle,
    required this.date,
    required this.location,
    required this.waktu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF320B87),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian pertandingan di tengah
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    matchTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Detail tanggal, waktu, lokasi
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(waktu, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
