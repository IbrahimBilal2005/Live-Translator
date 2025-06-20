import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// A service class to handle API requests for the QuranLive app
class ApiService {
  static String get _baseUrl => AppConfig.baseUrl;

  /// Upload an audio file and receive a transcription match
  static Future<Map<String, dynamic>> uploadAudio(File file) async {
    final uri = Uri.parse('$_baseUrl/audio/transcribe2');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        return jsonDecode(utf8.decode(res.bodyBytes));
      } else {
        return {
          'error': true,
          'message': 'Server responded with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Error uploading audio: $e',
      };
    }
  }

  /// Fetch the full list of surahs
  static Future<List<Map<String, dynamic>>> fetchSurahList() async {
    final uri = Uri.parse('$_baseUrl/quran/surahs');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception('Failed to load surah list');
      }
    } catch (e) {
      throw Exception('Error fetching surah list: $e');
    }
  }

  /// Fetch a single surah by ID
  static Future<Map<String, dynamic>> fetchSurahById(int surahId) async {
    final uri = Uri.parse('$_baseUrl/quran/surahs/$surahId');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load surah $surahId');
      }
    } catch (e) {
      throw Exception('Error fetching surah: $e');
    }
  }

  /// Fetch a random ayah
  static Future<Map<String, dynamic>?> fetchRandomAyah() async {
    final uri = Uri.parse('$_baseUrl/quran/random-ayah');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error fetching random ayah: $e');
      return null;
    }
  }
}
