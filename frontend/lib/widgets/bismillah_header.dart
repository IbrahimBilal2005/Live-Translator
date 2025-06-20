import 'package:flutter/material.dart';
import '../constants/styles.dart';

class BismillahHeader extends StatelessWidget {
  final String surahName;

  const BismillahHeader({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          surahName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppStyles.surahNameFontSize,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "﷽",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppStyles.bismillahFontSize,
            fontFamily: 'Amiri',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
