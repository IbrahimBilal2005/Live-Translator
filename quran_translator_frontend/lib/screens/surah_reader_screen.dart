import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/api_service.dart';

class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({super.key});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List<Map<String, dynamic>> _surahList = [];
  Map<String, dynamic>? _selectedSurahData;
  bool _isLoading = false;

  static const double surahNameFontSize = 42.0;
  static const double bismillahFontSize = 20.0;
  static const double arabicFontSize = 26.0;
  static const double translationFontSize = 14.0;
  static const Color backgroundColor = Color(0xFF202125);
  static const Color dropdownFillColor = Color(0xFF2C2C2E);

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Read Surah"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownSearch<Map<String, dynamic>>(
              items: _surahList,
              itemAsString: (surah) =>
                  '${surah["id"]}. ${surah["transliteration"] ?? surah["translation"] ?? surah["name"]}',
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                    hintText: "Search Surah...",
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: dropdownFillColor,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent, width: 2),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    ),
                    style: const TextStyle(color: Colors.white),
                ),
                ),

              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                    labelText: "Select a Surah",
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF202125), // Dark grey background
                    border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent), // Green border
                    borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent), // Green border
                    borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent, width: 2), // Thicker green border on focus
                    borderRadius: BorderRadius.circular(8),
                    ),
                ),
                ),

              onChanged: (selected) {
                if (selected != null) {
                  _onSurahSelected(selected["id"]);
                }
              },
             selectedItem: _surahList.any((s) => s["id"] == _selectedSurahData?["surah"])
                ? _surahList.firstWhere((s) => s["id"] == _selectedSurahData?["surah"])
                : null,


              dropdownBuilder: (context, selectedItem) {
                if (selectedItem == null || selectedItem["id"] == null) {
                    return const Text(
                    "Select a Surah",
                    style: TextStyle(color: Colors.white54),
                    );
                }

                final name = selectedItem["transliteration"] ??
                    selectedItem["translation"] ??
                    selectedItem["name"] ??
                    '';

                return Text(
                    '${selectedItem["id"]}. $name',
                    style: const TextStyle(color: Colors.white),
                );
                },

            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_selectedSurahData != null)
              Expanded(child: _buildSurahDisplay(_selectedSurahData!)),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahDisplay(Map<String, dynamic> surahData) {
    final ayahs = surahData['ayahs'] as List<dynamic>;

    return ListView.builder(
      itemCount: ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              Text(
                surahData["surah_name"] ?? '',
                style: TextStyle(
                  fontSize: surahNameFontSize,
                  color: Colors.white,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "﷽",
                style: TextStyle(
                  fontSize: bismillahFontSize,
                  color: Colors.white70,
                  fontFamily: 'Amiri',
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
                style: TextStyle(
                  fontSize: arabicFontSize,
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
                style: TextStyle(fontSize: translationFontSize, color: Colors.white70),
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
