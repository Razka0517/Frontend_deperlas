// GANTI seluruh isi file dengan ini
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:deperlas_futsal/models/absen_model.dart';
import 'package:deperlas_futsal/services/jadwal_service.dart';
import 'package:deperlas_futsal/models/user_model.dart';
import 'package:flutter/foundation.dart';

class RekapAbsensiScreen extends StatefulWidget {
  final User user;
  final String jadwalId;

  const RekapAbsensiScreen({
    super.key,
    required this.user,
    required this.jadwalId,
  });

  @override
  State<RekapAbsensiScreen> createState() => _RekapAbsensiScreenState();
}

class _RekapAbsensiScreenState extends State<RekapAbsensiScreen> {
  late Future<List<RekapAbsen>> _rekapFuture;
  final JadwalService _jadwalService = JadwalService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rekapFuture = _jadwalService.getRekapAbsen(widget.jadwalId);
    });
  }

  Future<void> _generateAndDownloadPDF() async {
    try {
      final rekapData = await _rekapFuture;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Rekap Absen Pemain - Jadwal ${widget.jadwalId}',
                    style: pw.TextStyle(fontSize: 24),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Nama Pemain',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Status',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...rekapData.map((absen) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              absen.namaPemain,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              absen.status,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color:
                                    absen.status.toLowerCase() == 'hadir'
                                        ? PdfColors.green
                                        : PdfColors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Dicetak pada: ${DateTime.now().toString().substring(0, 16)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mencetak PDF')));
      }
      if (kDebugMode) debugPrint('Error saat membuat PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Rekap Absen Pemain',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: _generateAndDownloadPDF,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _loadData();
                      },
                      child: FutureBuilder<List<RekapAbsen>>(
                        future: _rekapFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Gagal memuat data absen'),
                                  Text(
                                    snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada data absen untuk jadwal ini',
                              ),
                            );
                          }

                          final rekapData = snapshot.data!;
                          return ListView.builder(
                            itemCount: rekapData.length,
                            itemBuilder: (context, index) {
                              final absen = rekapData[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.person,
                                    color:
                                        absen.status.toLowerCase() == 'hadir'
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                  title: Text(absen.namaPemain),
                                  subtitle: Text('Status: ${absen.status}'),
                                  trailing: Icon(
                                    Icons.circle,
                                    color:
                                        absen.status.toLowerCase() == 'hadir'
                                            ? Colors.green
                                            : Colors.red,
                                    size: 12,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
