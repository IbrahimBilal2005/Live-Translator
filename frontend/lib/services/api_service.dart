import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Upload audio and get transcription/match
  static Future<Map<String, dynamic>> uploadAudio(File file) async {
    final uri = Uri.parse('$baseUrl/audio/transcribe2');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final jsonData = jsonDecode(utf8.decode(res.bodyBytes));
        return jsonData;
      } else {
        return {
          'error': true,
          'message': 'Server responded with status ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': true, 'message': 'Error uploading audio: $e'};
    }
  }

  // Fetch full list of Surahs
  static Future<List<Map<String, dynamic>>> fetchSurahList() async {
    final uri = Uri.parse('$baseUrl/quran/surahs');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception('Failed to load surah list');
      }
    } catch (e) {
      throw Exception('Error fetching surah list: $e');
    }
  }

  // ✅ Fetch one surah by ID (needed by SurahReaderScreen)
  static Future<Map<String, dynamic>> fetchSurahById(int surahId) async {
    final uri = Uri.parse('$baseUrl/quran/surahs/$surahId');
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

  // Fetch a random ayah with utf8 decode
  static Future<Map<String, dynamic>?> fetchRandomAyah() async {
    final uri = Uri.parse('$baseUrl/quran/random-ayah');
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
