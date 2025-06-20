import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/styles.dart';
import '../services/api_service.dart';
import '../widgets/ayah_card.dart';
import '../widgets/bismillah_header.dart';
import '../widgets/status_prompt.dart';
import '../widgets/surah_dropdown_search.dart';
import '../widgets/recent_surah_chips.dart';

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

  static const Color backgroundColor = Color(0xFF202125);

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
    if (_randomAyah == null && cached != null) {
      setState(() => _randomAyah = jsonDecode(cached));
    }
    if (now.difference(lastFetchTime).inMinutes < 60) return;
    try {
      final data = await ApiService.fetchRandomAyah();
      if (data != null) {
        setState(() => _randomAyah = data);
        await prefs.setString('random_ayah_cache', jsonEncode(data));
        await prefs.setInt('random_ayah_last_fetch', now.millisecondsSinceEpoch);
      }
    } catch (e) {
      print("❌ Error fetching ayah: $e");
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          SurahDropdownSearch(
            surahList: _surahList,
            onSurahSelected: _onSurahSelected,
          ),
          const SizedBox(height: 20),
          if (_recentSurahs.isNotEmpty)
            RecentSurahChips(
              recentSurahs: _recentSurahs,
              onSurahTap: _onSurahSelected,
            ),
          if (_randomAyah != null)
            StatusPrompt(
              ayahData: _randomAyah!,
              onRefresh: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('random_ayah_last_fetch');
                await _loadRandomAyah();
              },
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
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
                label: const Text("Back to search", style: TextStyle(color: Colors.greenAccent)),
              ),
              Center(
                child: BismillahHeader(surahName: surahData["surah_name"] ?? ''),
              ),
            ],
          );
        }

        final ayah = ayahs[index - 1];
        return AyahCard(
          reference: "${ayah['surah']}:${ayah['ayah']}",
          arabic: ayah['arabic_text'] ?? ayah['text_ar'] ?? '⚠️ Arabic missing',
          translation: ayah['translation'] ?? '⚠️ Translation missing',
        );
      },
    );
  }
}
