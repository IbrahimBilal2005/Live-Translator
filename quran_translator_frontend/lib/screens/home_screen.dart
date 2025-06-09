import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;
  String? _transcription;
  String? _matchedArabic;
  String? _matchedTranslation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await Directory.systemTemp.createTemp();
    String path = '${tempDir.path}/recorded.aac';
    await _recorder.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _filePath = path;
      _transcription = null;
      _matchedArabic = null;
      _matchedTranslation = null;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    if (_filePath != null) {
      final result = await ApiService.uploadAudio(File(_filePath!));
      setState(() {
        if (result['error'] == true) {
          _transcription = result['message'];
        } else {
          _transcription = result['transcription'] ?? "No transcription.";
          _matchedArabic = result['matched_ayah']?['arabic_text'];
          _matchedTranslation = result['matched_ayah']?['translation'];
        }
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quran Audio Matcher")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? "Stop Recording" : "Start Recording"),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            const SizedBox(height: 30),
            if (_transcription != null) ...[
              const Text("📝 Transcription:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text(_transcription!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            if (_matchedArabic != null) ...[
              const Text("📖 Matched Arabic Ayah:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text(_matchedArabic!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
            ],
            const SizedBox(height: 20),
            if (_matchedTranslation != null) ...[
              const Text("🌍 English Translation:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text(_matchedTranslation!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
