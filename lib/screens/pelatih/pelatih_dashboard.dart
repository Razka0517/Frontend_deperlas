import 'package:flutter/material.dart';
import 'jadwal_latihan_pelatih.dart';
import 'jadwal_pengganti.dart';
import 'jadwal_pertandingan.dart';
import '../login_screen.dart';
import 'pilih_jadwal_absen.dart';
import 'package:deperlas_futsal/models/user_model.dart'; // Pastikan Anda mengimpor model User

class PelatihDashboard extends StatelessWidget {
  final User user; // Menggunakan model User

  const PelatihDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D0074),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D0074),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${user.username} 👋", // Menggunakan username dari objek User
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Image.asset('assets/logo.png', width: 50),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text("Kejuaraan", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/spanduk.png'),
                      ),
                      const SizedBox(height: 20),

                      // Menu Buttons in Wrap - Updated for Coach Dashboard
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          _menuButton(
                            context,
                            iconPath: 'assets/icon_jadwal_latihan.png',
                            label: "Jadwal Latihan",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => JadwalLatihanPelatihScreen(
                                        user: user, // Mengirim objek User
                                      ),
                                ),
                              );
                            },
                          ),
                          _menuButton(
                            context,
                            iconPath: 'assets/icon_jadwal_pengganti.png',
                            label: "Jadwal Pengganti",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => JadwalLatihanPenggantiScreen(
                                        user: user, // Mengirim objek User
                                      ),
                                ),
                              );
                            },
                          ),
                          // New Info Absen button
                          _menuButton(
                            context,
                            iconPath:
                                'assets/icon_info_absen.png', // You'll need to add this asset
                            label: "Info Absen",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PilihJadwalUntukAbsenScreen(
                                        user: user, // Mengirim objek User
                                      ),
                                ),
                              );
                            },
                          ),
                          _menuButton(
                            context,
                            iconPath: 'assets/icon_jadwal_pertandingan.png',
                            label: "Jadwal Pertandingan",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => JadwalPertandinganScreen(
                                        user: user, // Mengirim objek User
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Prestasi Tim",
                        style: TextStyle(fontSize: 18),
                      ), // Changed from "Medali" to "Prestasi Tim"
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/medali1.png', width: 70),
                          Image.asset('assets/medali2.png', width: 70),
                          Image.asset('assets/medali3.png', width: 70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: AssetImage(iconPath),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
