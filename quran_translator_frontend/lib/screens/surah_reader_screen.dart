import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({super.key});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  static const double surahNameFontSize = 50.0;
  static const double bismillahFontSize = 20.0;

  List<Map<String, dynamic>> _surahList = [];
  Map<String, dynamic>? _selectedSurahData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSurahList();
  }

  Future<void> _loadSurahList() async {
    try {
      final list = await ApiService.fetchSurahList();
      setState(() => _surahList = list);
    } catch (e) {
      print("❌ Error loading surah list: $e");
    }
  }

  Future<void> _onSurahSelected(int? surahId) async {
    if (surahId == null) return;
    setState(() {
      _isLoading = true;
      _selectedSurahData = null;
    });

    try {
      final surahData = await ApiService.fetchSurahById(surahId);
      print("📦 Surah response: $surahData");
      setState(() => _selectedSurahData = surahData);
    } catch (e) {
      print("❌ Error loading surah: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202125),
      appBar: AppBar(
        title: const Text("Read Surah"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    labelText: "Select a Surah",
                    labelStyle: const TextStyle(color: Colors.white70),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5), width: 1),
                    ),
                    border: const OutlineInputBorder(),
                ),

                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: _surahList.map((surah) {
                  final id = surah['id'];
                  final name = surah['transliteration'] ??
                      surah['translation'] ??
                      surah['name'] ??
                      'Unnamed';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text('$id. $name',
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: _onSurahSelected,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (_selectedSurahData != null)
                Expanded(child: _buildSurahDisplay(_selectedSurahData!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahDisplay(Map<String, dynamic> surahData) {
    final ayahs = surahData['ayahs'] as List<dynamic>;
    final surahName = surahData['surah_name'] ?? '';
    final surahId = surahData['surah'] ?? '';

    return ListView.builder(
      itemCount: ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Text(
                surahName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: surahNameFontSize,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              if (surahId != 9) // Skip Bismillah for Surah At-Tawbah
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

        final ayah = ayahs[index - 1];
        final arabic = ayah['arabic_text'] ?? ayah['text_ar'] ?? '⚠️ Arabic missing';
        final translation = ayah['translation'] ?? '⚠️ Translation missing';
        final reference = "${ayah['surah'] ?? '?'}:${ayah['ayah'] ?? '?'}";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 6),
              child: Text(
                reference,
                style: const TextStyle(fontSize: 13.0, color: Colors.white54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 26.0,
                  fontFamily: 'Amiri',
                  color: Colors.white,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: Text(
                translation,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),
          ],
        );
      },
    );
  }
}
