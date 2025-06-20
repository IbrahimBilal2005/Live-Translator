import 'package:flutter/material.dart';

class RecentSurahChips extends StatelessWidget {
  final List<Map<String, dynamic>> recentSurahs;
  final void Function(int id) onSurahTap;

  const RecentSurahChips({
    super.key,
    required this.recentSurahs,
    required this.onSurahTap,
  });

  static const Color chipColor = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recently viewed", style: TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: recentSurahs.map((surah) {
            return ActionChip(
              label: Text(surah['name'], style: const TextStyle(color: Colors.white)),
              backgroundColor: chipColor,
              onPressed: () => onSurahTap(surah['id']),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
