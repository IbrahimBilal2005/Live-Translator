import 'package:flutter/material.dart';
import '../constants/styles.dart';

class AyahCard extends StatelessWidget {
  final Map<String, dynamic>? ayah;
  final bool isMatch;

  // Optional for direct input (used by SurahReaderScreen)
  final String? reference;
  final String? arabic;
  final String? translation;

  const AyahCard({
    super.key,
    this.ayah,
    this.reference,
    this.arabic,
    this.translation,
    this.isMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayReference = reference ?? '${ayah?['surah']}:${ayah?['ayah']}';
    final displayArabic = arabic ?? ayah?['arabic_text'] ?? '⚠️ Arabic missing';
    final displayTranslation = translation ?? ayah?['translation'] ?? '⚠️ Translation missing';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 6),
            child: Text(
              displayReference,
              style: const TextStyle(
                fontSize: AppStyles.referenceFontSize,
                color: Colors.white54,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              displayArabic,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppStyles.arabicFontSize,
                fontFamily: 'Amiri',
                color: isMatch ? Colors.greenAccent : Colors.white,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Text(
              displayTranslation,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: AppStyles.translationFontSize,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, thickness: 1),
        ],
      ),
    );
  }
}
