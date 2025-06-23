import 'package:flutter/material.dart';
import 'pemain_dashboard.dart';
import 'package:deperlas_futsal/models/jadwal_model.dart';
import 'package:deperlas_futsal/services/jadwal_service.dart';
import 'package:deperlas_futsal/models/user_model.dart';

class JadwalPenggantiScreen extends StatefulWidget {
  final User user;

  const JadwalPenggantiScreen({super.key, required this.user});

  @override
  State<JadwalPenggantiScreen> createState() => _JadwalLatihanScreenState();
}

class _JadwalLatihanScreenState extends State<JadwalPenggantiScreen> {
  final JadwalService _jadwalService = JadwalService();
  late Future<JadwalResponse> _jadwalFuture;
  final Map<String, bool> _isAbsenMap = {};

  @override
  void initState() {
    super.initState();
    _loadJadwal('PNG');
  }

  void _loadJadwal(String tipeJadwal) {
    setState(() {
      _jadwalFuture = _jadwalService.fetchJadwal(tipeJadwal);
    });
  }

  Future<void> _handleAbsen(String jadwalId) async {
    try {
      final response = await _jadwalService.absenPemain(
        widget.user.userId,
        jadwalId,
      );

      if (response.success) {
        setState(() {
          _isAbsenMap[jadwalId] = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
      } else {
        // Menangani kesalahan dari server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal melakukan absen: ${response.message}')),
        );
      }
    } catch (e) {
      // Menangani kesalahan yang tidak terduga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan absen: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PemainDashboard(user: widget.user),
              ),
            );
          },
        ),
        title: const Text(
          'Jadwal Pengganti',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadJadwal('REG');
        },
        child: FutureBuilder<JadwalResponse>(
          future: _jadwalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Gagal memuat jadwal'),
                    ElevatedButton(
                      onPressed: () => _loadJadwal('REG'),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(child: Text('Tidak ada jadwal tersedia'));
            } else {
              final jadwalList = snapshot.data!.data;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jadwalList.length,
                itemBuilder: (context, index) {
                  final jadwal = jadwalList[index];
                  final isAbsen = _isAbsenMap[jadwal.jadwalId] ?? false;
                  final isOpen = _isWithinSchedule(
                    jadwal,
                  ); // Cek status buka/tutup

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScheduleCard(
                      day: jadwal.getDayName(),
                      backgroundColor:
                          isOpen
                              ? const Color(0xFF4B0082)
                              : Colors.red, // Merah jika tutup
                      time:
                          '${jadwal.waktuMulai.substring(0, 5)} - ${jadwal.waktuSelesai.substring(0, 5)}',
                      names: jadwal.pelatih.map((p) => p.nama).toList(),
                      lokasi: jadwal.lokasi,
                      isActive:
                          isOpen &&
                          !isAbsen, // Hanya aktif jika buka dan belum absen
                      isAbsen: isAbsen,
                      onAbsenPressed: () {
                        if (isOpen && !isAbsen) {
                          _handleAbsen(jadwal.jadwalId);
                        } else if (!isOpen) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Jadwal sudah tutup, tidak bisa absen.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anda sudah melakukan absen'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // Fungsi untuk memeriksa apakah jadwal dalam status buka
  bool _isWithinSchedule(Jadwal jadwal) {
    final now = DateTime.now();
    final start = DateTime.parse('${jadwal.tanggal} ${jadwal.waktuMulai}');
    final end = DateTime.parse('${jadwal.tanggal} ${jadwal.waktuSelesai}');
    return now.isAfter(start) && now.isBefore(end);
  }
}

class ScheduleCard extends StatelessWidget {
  final String day;
  final Color backgroundColor;
  final String time;
  final List<String> names;
  final String lokasi;
  final bool isActive;
  final bool isAbsen;
  final VoidCallback? onAbsenPressed;

  const ScheduleCard({
    super.key,
    required this.day,
    required this.backgroundColor,
    required this.time,
    required this.names,
    required this.lokasi,
    required this.isActive,
    this.isAbsen = false,
    this.onAbsenPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today, day),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time, time),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on, lokasi),
          const SizedBox(height: 12),
          for (var name in names) ...[
            _infoRow(Icons.person, name),
            const SizedBox(height: 8),
          ],
          if (isActive)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onAbsenPressed,
                child: const Text(
                  'Absen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          if (!isActive)
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Absen Ditutup',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Row _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
