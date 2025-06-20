import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../constants/styles.dart';
import '../services/api_service.dart';
import '../widgets/ayah_card.dart';
import '../widgets/bismillah_header.dart';
import '../widgets/recording_button.dart';
import '../widgets/status_prompt.dart';

class AudioMatcherScreen extends StatefulWidget {
  const AudioMatcherScreen({super.key});

  @override
  State<AudioMatcherScreen> createState() => _AudioMatcherScreenState();
}

class _AudioMatcherScreenState extends State<AudioMatcherScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isRecording = false;
  bool _isFindingMatch = false;
  String? _filePath;
  String? _transcription;
  Map<String, dynamic>? _matchedAyah;
  List<dynamic>? _fullSurah;

  String _listeningText = "Listening";
  Timer? _dotTimer;
  int _dotCount = 0;

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

    _dotCount = 0;
    _listeningText = "Listening";
    _dotTimer?.cancel();
    _dotTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
        _listeningText = "Listening" + "." * _dotCount;
      });
    });

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
    _dotTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isFindingMatch = true;
    });

    if (_filePath != null) {
      final result = await ApiService.uploadAudio(File(_filePath!));
      setState(() {
        _isFindingMatch = false;
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
    _dotTimer?.cancel();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: StatusPrompt(
                isRecording: _isRecording,
                isFindingMatch: _isFindingMatch,
                listeningText: _listeningText,
              ),
            ),
          ),
          RecordingButton(
            isRecording: _isRecording,
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
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
          if (_matchedAyah != null)
            BismillahHeader(surahName: _matchedAyah!['surah_name'] ?? '')
          else
            Expanded(
              child: Center(
                child: Text(
                  "No match found. Please try again.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_fullSurah != null && _matchedAyah != null)
            Expanded(child: _buildAyahList()),
          RecordingButton(
            isRecording: _isRecording,
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
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

        return AyahCard(ayah: ayah, isMatch: isMatch);
      },
    );
  }
}
