// audio_matcher_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../services/api_service.dart';

class AudioMatcherScreen extends StatefulWidget {
  const AudioMatcherScreen({super.key});

  @override
  State<AudioMatcherScreen> createState() => _AudioMatcherScreenState();
}

class _AudioMatcherScreenState extends State<AudioMatcherScreen> {
  // === Constants ===
  static const double arabicFontSize = 26.0;
  static const double translationFontSize = 14.0;
  static const double surahNameFontSize = 50.0;
  static const double bismillahFontSize = 20.0;
  static const double referenceFontSize = 13.0;

  // === Recorder and Scroll Setup ===
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  // === State Variables ===
  bool _isRecording = false;
  String? _filePath;
  String? _transcription;
  Map<String, dynamic>? _matchedAyah;
  List<dynamic>? _fullSurah;

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
    final tempDir = await Directory.systemTemp.createTemp();
    final path = '${tempDir.path}/recorded.aac';

    await _recorder.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _filePath = path;
      _transcription = null;
      _matchedAyah = null;
      _fullSurah = null;
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
          _matchedAyah = result['matched_ayah'];
          _fullSurah = result['full_surah'];
        }
      });
      _scrollToMatchedAyah();
    }
  }

  void _scrollToMatchedAyah() {
    if (_matchedAyah == null || _fullSurah == null) return;
    final index = _fullSurah!.indexWhere(
      (ayah) => ayah['arabic_text'] == _matchedAyah!['arabic_text'],
    );

    if (index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_itemScrollController.isAttached) {
            _itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              alignment: 0.3,
            );
          }
        });
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
    final bool showResult = _transcription != null || _matchedAyah != null;

    return Scaffold(
      backgroundColor: const Color(0xFF202125),
      appBar: AppBar(
        title: const Text("Audio Matcher"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: Navigator.of(context).canPop()
            ? const BackButton(color: Colors.white)
            : null,
      ),
      body: showResult ? _buildResultsView() : _buildInitialPrompt(),
    );
  }

  Widget _buildInitialPrompt() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          _buildRecordingButton(),
        ],
      ),
    );
  }

  Widget _buildRecordingButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: Text(_isRecording ? "Stop Recording" : "Start Recording"),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRecording ? Colors.redAccent : Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        onPressed: _isRecording ? _stopRecording : _startRecording,
      ),
    );
  }

  Widget _buildResultsView() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMatchedAyah());

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_matchedAyah != null) _buildMatchedHeader(),
          Expanded(child: _buildAyahList()),
          _buildRecordingButton(),
        ],
      ),
    );
  }

  Widget _buildMatchedHeader() {
    return Column(
      children: [
        Text(
          _matchedAyah!['surah_name'] ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: surahNameFontSize,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bismillahFontSize,
            fontFamily: 'Amiri',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAyahList() {
    return ScrollablePositionedList.builder(
      itemCount: _fullSurah?.length ?? 0,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        final ayah = _fullSurah![index];
        final isMatch = _matchedAyah != null &&
            _matchedAyah!['arabic_text'] == ayah['arabic_text'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 6),
                child: Text(
                  '${ayah['surah']}:${ayah['ayah']}',
                  style: const TextStyle(
                    fontSize: referenceFontSize,
                    color: Colors.white54,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  ayah['arabic_text'],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: arabicFontSize,
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
                  ayah['translation'],
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: translationFontSize,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, thickness: 1),
            ],
          ),
        );
      },
    );
  }
}
