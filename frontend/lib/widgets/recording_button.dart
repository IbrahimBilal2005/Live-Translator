import 'package:flutter/material.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white),
        label: Text(
          isRecording ? "Stop Recording" : "Start Recording",
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRecording ? Colors.redAccent : Colors.greenAccent.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
