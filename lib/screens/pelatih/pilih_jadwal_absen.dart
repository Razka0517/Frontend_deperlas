import 'package:flutter/material.dart';
import 'package:deperlas_futsal/models/jadwal_model.dart';
import 'rekap_absen.dart';
import 'package:deperlas_futsal/services/jadwal_service.dart';
import 'package:deperlas_futsal/models/user_model.dart';

class PilihJadwalUntukAbsenScreen extends StatefulWidget {
  final User user;

  const PilihJadwalUntukAbsenScreen({super.key, required this.user});

  @override
  State<PilihJadwalUntukAbsenScreen> createState() =>
      _PilihJadwalUntukAbsenScreenState();
}

class _PilihJadwalUntukAbsenScreenState
    extends State<PilihJadwalUntukAbsenScreen>
    with TickerProviderStateMixin {
  final JadwalService _jadwalService = JadwalService();
  late TabController _tabController;
  late Future<List<Jadwal>> _jadwalRegulerFuture;
  late Future<List<Jadwal>> _jadwalGantiFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _jadwalRegulerFuture = _fetchJadwal('REG');
    _jadwalGantiFuture = _fetchJadwal('PNG');
  }

  Future<List<Jadwal>> _fetchJadwal(String tipe) async {
    final response = await _jadwalService.fetchJadwal(tipe);
    return response.data;
  }

  Widget _buildJadwalList(Future<List<Jadwal>> future) {
    return FutureBuilder<List<Jadwal>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat jadwal.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada jadwal tersedia.'));
        }

        final jadwalList = snapshot.data!;
        return ListView.builder(
          itemCount: jadwalList.length,
          itemBuilder: (context, index) {
            final jadwal = jadwalList[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('${jadwal.getDayName()}, ${jadwal.tanggal}'),
                subtitle: Text(
                  '${jadwal.waktuMulai} - ${jadwal.waktuSelesai} @ ${jadwal.lokasi}',
                ),
                onTap: () {
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
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Jadwal Absen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Reguler'), Tab(text: 'Pengganti')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJadwalList(_jadwalRegulerFuture),
          _buildJadwalList(_jadwalGantiFuture),
        ],
      ),
    );
  }
}
