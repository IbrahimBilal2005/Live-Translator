import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';


class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({super.key});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  List<Map<String, dynamic>> _surahList = [];
  List<Map<String, dynamic>> _recentSurahs = [];
  Map<String, dynamic>? _selectedSurahData;
  Map<String, dynamic>? _randomAyah;
  bool _isLoading = false;
  bool _showSearchView = true;

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
    _loadRecentSurahs();
    _loadRandomAyah();
  }

  Future<void> _loadSurahList() async {
    try {
      final list = await ApiService.fetchSurahList();
      setState(() => _surahList = list);
    } catch (e) {
      print("❌ Error loading surah list: $e");
    }
  }

  Future<void> _saveRecentSurah(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList('recent_surahs') ?? [];

    final entry = '$id|$name';
    recent.remove(entry);
    recent.insert(0, entry);

    if (recent.length > 7) recent = recent.sublist(0, 7);
    await prefs.setStringList('recent_surahs', recent);
    _loadRecentSurahs();
  }

  Future<void> _loadRecentSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_surahs') ?? [];

    setState(() {
      _recentSurahs = recent.map((e) {
        final parts = e.split('|');
        return {'id': int.parse(parts[0]), 'name': parts[1]};
      }).toList();
    });
  }

  Future<void> _loadRandomAyah() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final lastFetchMillis = prefs.getInt('random_ayah_last_fetch') ?? 0;
    final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    final cached = prefs.getString('random_ayah_cache');

    // ✅ Always restore cached ayah first (even after screen reload)
    if (_randomAyah == null && cached != null) {
      setState(() => _randomAyah = jsonDecode(cached));
    }

    // ✅ Check if refresh is needed
    if (now.difference(lastFetchTime).inMinutes < 60) {
      print("✅ Cached ayah still fresh");
      return;
    }

    // ✅ Fetch new ayah and update cache
    try {
      final data = await ApiService.fetchRandomAyah();
      if (data != null) {
        print("🌐 Fetched fresh random ayah");
        setState(() => _randomAyah = data);
        await prefs.setString('random_ayah_cache', jsonEncode(data));
        await prefs.setInt('random_ayah_last_fetch', now.millisecondsSinceEpoch);
      }
    } catch (e) {
      print("❌ Error fetching ayah: $e");
      // Cached ayah already loaded above, so no fallback needed here
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
      await _saveRecentSurah(surahData['surah'], surahData['surah_name']);
      setState(() {
        _selectedSurahData = surahData;
        _showSearchView = false;
      });
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
        child: _showSearchView
            ? _buildSearchUI()
            : _selectedSurahData != null
                ? _buildSurahDisplay(_selectedSurahData!)
                : const SizedBox(),
      ),
    );
  }

  Widget _buildSearchUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Search the Quran...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          _buildDropdownSearch(),
          const SizedBox(height: 20),
          if (_recentSurahs.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recently viewed",
                    style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _recentSurahs.map((surah) {
                    return ActionChip(
                      label: Text(surah['name'],
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: dropdownFillColor,
                      onPressed: () => _onSurahSelected(surah['id']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          if (_randomAyah != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Hourly Reminder:",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white54),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('random_ayah_last_fetch'); // Invalidate the cache time
                        await _loadRandomAyah(); // Force reload
                      },

                    )
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, bottom: 6),
                        child: Text(
                          "${_randomAyah!['surah'] ?? '?'}:${_randomAyah!['ayah'] ?? '?'}",
                          style: const TextStyle(
                              fontSize: 13.0, color: Colors.white54),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          _randomAyah!['text_ar'] ?? _randomAyah!['arabic_text'] ?? '⚠️ Arabic missing',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl, // <- important
                          style: const TextStyle(
                            fontSize: 26.0, // or arabicFontSize
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
                          _randomAyah!['translation'] ??
                              '⚠️ Translation missing',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: translationFontSize,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }



  Widget _buildDropdownSearch() {
    return DropdownSearch<Map<String, dynamic>>(
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
            border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFF202125),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
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
          return const Text("Search...",
              style: TextStyle(color: Colors.white54));
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
    );
  }

  Widget _buildSurahDisplay(Map<String, dynamic> surahData) {
    final ayahs = surahData['ayahs'] as List<dynamic>;

    return ListView.builder(
      itemCount: ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSurahData = null;
                    _showSearchView = true;
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
                label: const Text("Back to search",
                    style: TextStyle(color: Colors.greenAccent)),
              ),
              Center(
                child: Column(
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
                ),
              ),
            ],
          );
        }

        final ayah = ayahs[index - 1];
        final arabic =
            ayah['arabic_text'] ?? ayah['text_ar'] ?? '⚠️ Arabic missing';
        final translation =
            ayah['translation'] ?? '⚠️ Translation missing';
        final reference =
            "${ayah['surah'] ?? '?'}:${ayah['ayah'] ?? '?'}";

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
                style: TextStyle(
                    fontSize: translationFontSize, color: Colors.white70),
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
