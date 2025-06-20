import 'package:flutter/material.dart';
import 'bismillah_header.dart';

class SurahHeaderBar extends StatelessWidget {
  final String surahName;
  final VoidCallback onBack;

  const SurahHeaderBar({
    super.key,
    required this.surahName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          label: const Text(
            "Back to search",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
        Center(
          child: BismillahHeader(surahName: surahName),
        ),
      ],
    );
  }
}
