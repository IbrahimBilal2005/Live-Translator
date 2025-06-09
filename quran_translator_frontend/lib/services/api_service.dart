import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> uploadAudio(File file) async {
    final uri = Uri.parse('http://10.0.2.2:8000/audio/transcribe2');

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
}
