import 'package:flutter/material.dart';

class RandomAyahCard extends StatelessWidget {
  final Map<String, dynamic> ayahData;
  final VoidCallback? onRefresh;

  const RandomAyahCard({
    super.key,
    required this.ayahData,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = ayahData['arabic_text'] ?? ayahData['text_ar'] ?? '⚠️ Arabic missing';
    final translation = ayahData['translation'] ?? '⚠️ Translation missing';
    final reference = "${ayahData['surah_name']} • ${ayahData['surah']}:${ayahData['ayah']}";

    return Card(
      color: const Color(0xFF2C2C2E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Hourly Reminder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
            const SizedBox(height: 12),
            Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 22, color: Colors.white, height: 2),
            ),
            const SizedBox(height: 10),
            Text(
              translation,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              reference,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.right,
            ),
            if (onRefresh != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, color: Colors.greenAccent),
                  tooltip: 'Refresh Random Ayah',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
