import 'package:flutter/material.dart';

class StatusPrompt extends StatelessWidget {
  final bool isRecording;
  final bool isFindingMatch;
  final String listeningText;

  const StatusPrompt({
    super.key,
    required this.isRecording,
    required this.isFindingMatch,
    required this.listeningText,
  });

  @override
  Widget build(BuildContext context) {
    if (isFindingMatch) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.greenAccent),
          SizedBox(height: 20),
          Text(
            "Finding the matching verse...",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else if (isRecording) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.mic, size: 80, color: Colors.greenAccent),
          const SizedBox(height: 20),
          Text(
            listeningText,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Recite clearly and we'll find the verse.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.mic_none, size: 80, color: Colors.white54),
          SizedBox(height: 20),
          Text(
            "Press the button below and recite a verse.\nWe'll try to find the match for you.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }
}
