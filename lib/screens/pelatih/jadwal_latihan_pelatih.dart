import 'package:flutter/material.dart';
import 'package:deperlas_futsal/models/jadwal_model.dart';
import 'package:deperlas_futsal/services/jadwal_service.dart';
import 'rekap_absen.dart';
import 'pelatih_dashboard.dart';
import 'dart:async';
import 'package:deperlas_futsal/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalLatihanPelatihScreen extends StatefulWidget {
  final User user; // Menggunakan model User yang memiliki role

  const JadwalLatihanPelatihScreen({super.key, required this.user});

  @override
  State<JadwalLatihanPelatihScreen> createState() =>
      _JadwalLatihanPelatihScreenState();
}

class _JadwalLatihanPelatihScreenState
    extends State<JadwalLatihanPelatihScreen> {
  late Future<JadwalResponse> _jadwalFuture;
  final JadwalService _jadwalService = JadwalService();
  final Map<String, bool> _isStartedMap = {};
  final Map<String, Timer> _sessionTimers = {};
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    _loadJadwal('REG');
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _sessionTimers.forEach((_, timer) => timer.cancel());
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _loadJadwal(String tipeJadwal) {
    setState(() {
      _jadwalFuture = _jadwalService.fetchJadwal(tipeJadwal);
    });
  }

  // Fungsi cek apakah waktu sekarang di dalam jadwal latihan
  bool _isWithinSchedule(Jadwal jadwal) {
    final now = DateTime.now();
    final start = DateTime.parse('${jadwal.tanggal} ${jadwal.waktuMulai}');
    final end = DateTime.parse('${jadwal.tanggal} ${jadwal.waktuSelesai}');
    return now.isAfter(start) && now.isBefore(end);
  }

  Future<void> _handleStartSession(Jadwal jadwal) async {
    if (widget.user.role != 'pelatih') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya pelatih yang dapat membuka sesi absen.'),
        ),
      );
      return; // Hentikan eksekusi jika bukan pelatih
    }

    try {
      final response = await _jadwalService.bukaAbsen(jadwal.jadwalId);

      if (response.success) {
        setState(() {
          _isStartedMap[jadwal.jadwalId] = true; // Menandai sesi telah dibuka
        });

        // Simpan waktu penutupan di SharedPreferences
        final endTime = DateTime.parse(
          '${jadwal.tanggal} ${jadwal.waktuSelesai}',
        );
        await _saveEndTime(jadwal.jadwalId, endTime);

        // Tidak langsung masuk ke rekap absensi, hanya membuka sesi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi absen telah dibuka.')),
        );

        _setAutoCloseTimer(jadwal);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai sesi: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveEndTime(String jadwalId, DateTime endTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('end_time_$jadwalId', endTime.toIso8601String());
  }

  void _setAutoCloseTimer(Jadwal jadwal) {
    final endTime = DateTime.parse('${jadwal.tanggal} ${jadwal.waktuSelesai}');
    final timer = Timer(endTime.difference(DateTime.now()), () async {
      try {
        final response = await _jadwalService.tutupAbsen(jadwal.jadwalId);
        print('Closed absence for ${jadwal.jadwalId}: ${response.message}');
        setState(() {
          _isStartedMap[jadwal.jadwalId] = false; // Menandai sesi telah ditutup
        });
      } catch (e) {
        print('Error closing absence for ${jadwal.jadwalId}: $e');
      }
    });

    _sessionTimers[jadwal.jadwalId] = timer;
  }

  Future<void> _checkAndCloseAbsences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var jadwalId in _isStartedMap.keys) {
      final endTimeString = prefs.getString('end_time_$jadwalId');
      if (endTimeString != null) {
        final endTime = DateTime.parse(endTimeString);
        if (DateTime.now().isAfter(endTime)) {
          // Tutup absensi jika waktu sudah habis
          try {
            final response = await _jadwalService.tutupAbsen(jadwalId);
            await prefs.remove('end_time_$jadwalId');
            print('Closed absence for $jadwalId: ${response.message}');
            setState(() {
              _isStartedMap[jadwalId] = false; // Menandai sesi telah ditutup
            });
          } catch (e) {
            print('Error closing absence for $jadwalId: $e');
          }
        }
      }
    }
  }

  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndCloseAbsences();
    });
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
                builder: (context) => PelatihDashboard(user: widget.user),
              ),
            );
          },
        ),
        title: const Text(
          'Jadwal Latihan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadJadwal('REG'); // Ganti dengan tipe_jadwal yang diinginkan
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
              final allJadwal = snapshot.data!.data;
              final jadwalList =
                  allJadwal.where((jadwal) {
                    return jadwal.pelatih.any(
                      (p) =>
                          p.nama.toLowerCase() ==
                          widget.user.username.toLowerCase(),
                    );
                  }).toList();
              if (jadwalList.isEmpty) {
                return const Center(
                  child: Text('Tidak ada jadwal untuk Anda.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jadwalList.length,
                itemBuilder: (context, index) {
                  final jadwal = jadwalList[index];
                  final isActive = _isWithinSchedule(jadwal);
                  final isStarted = _isStartedMap[jadwal.jadwalId] ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScheduleCardPelatih(
                      day: jadwal.getDayName(),
                      backgroundColor:
                          isActive ? const Color(0xFF4B0082) : Colors.red,
                      time:
                          '${jadwal.waktuMulai.substring(0, 5)} - ${jadwal.waktuSelesai.substring(0, 5)}',
                      names: jadwal.pelatih.map((p) => p.nama).toList(),
                      lokasi: jadwal.lokasi,
                      isActive: isActive,
                      isStarted: isStarted,
                      isWithinSchedule: isActive,
                      onStartPressed: () {
                        if (!isStarted) {
                          _handleStartSession(jadwal);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sesi sudah dibuka.')),
                          );
                        }
                      },
                      onEnter: () {
                        if (isStarted && widget.user.role == 'pelatih') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RekapAbsensiScreen(
                                    user: widget.user,
                                    jadwalId: jadwal.jadwalId,
                                  ),
                            ),
                          );
                        } else if (widget.user.role == 'pelatih') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pelatih tidak dapat melakukan absensi.',
                              ),
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
}

class ScheduleCardPelatih extends StatelessWidget {
  final String day;
  final Color backgroundColor;
  final String time;
  final List<String> names;
  final String lokasi;
  final bool isActive;
  final bool isStarted;
  final bool isWithinSchedule;
  final VoidCallback? onStartPressed;
  final VoidCallback? onEnter;

  const ScheduleCardPelatih({
    super.key,
    required this.day,
    required this.backgroundColor,
    required this.time,
    required this.names,
    required this.lokasi,
    required this.isActive,
    this.isStarted = false,
    this.isWithinSchedule = false,
    this.onStartPressed,
    this.onEnter,
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
          if (isActive && isWithinSchedule)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: _buttonStyle(isStarted ? Colors.blue : Colors.green),
                onPressed: isStarted ? onEnter : onStartPressed,
                child: Text(
                  isStarted ? 'Masuk' : 'Mulai',
                  style: const TextStyle(color: Colors.white),
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

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}
