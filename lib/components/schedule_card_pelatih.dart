import 'package:flutter/material.dart';

class ScheduleCardPelatih extends StatelessWidget {
  final String day;
  final String time;
  final List<String> names;
  final String location;
  final Color backgroundColor;
  final bool isActive;
  final bool isStarted;
  final VoidCallback onStartPressed;
  final VoidCallback onEnter;

  const ScheduleCardPelatih({
    Key? key,
    required this.day,
    required this.time,
    required this.names,
    required this.location,
    required this.backgroundColor,
    required this.isActive,
    required this.isStarted,
    required this.onStartPressed,
    required this.onEnter,
  }) : super(key: key);

  Color getStatusColor() {
    if (!isActive) return Colors.grey.shade700;
    if (isStarted) return Colors.orange;
    return Colors.redAccent;
  }

  String getStatusText() {
    if (!isActive) return 'Ditutup';
    if (isStarted) return 'Berlangsung';
    return 'Belum Mulai';
  }

  IconData getStatusIcon() {
    if (!isActive) return Icons.lock_outline;
    if (isStarted) return Icons.play_circle_fill;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: backgroundColor.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Hari & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(getStatusIcon(), color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        getStatusText(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Jam
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Lokasi
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Nama Peserta
            Wrap(
              spacing: 8,
              children:
                  names.map((name) {
                    return Chip(
                      label: Text(name),
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(color: Colors.black87),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 14),

            // Aksi
            Row(
              children: [
                if (isActive && !isStarted)
                  ElevatedButton.icon(
                    onPressed: onStartPressed,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (isStarted)
                  ElevatedButton.icon(
                    onPressed: onEnter,
                    icon: const Icon(Icons.meeting_room),
                    label: const Text('Masuk Ruangan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (!isActive)
                  const Text(
                    'Jadwal ditutup',
                    style: TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
