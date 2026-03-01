import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android Emulator
  static const String _baseUrl = 'http://192.168.1.115:5000/api';
  
  static String? _token;

  static void setToken(String token) {
    _token = token;
    print('🔑 ApiService: Token saved');
  }

  static void clearToken() {
    _token = null;
    print('🔑 ApiService: Token cleared');
  }

  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      print('📡 ===== API CALL START =====');
      print('📡 POST: $_baseUrl/$endpoint');
      print('📦 Data: $data');
      
      final url = '$_baseUrl/$endpoint';
      final headers = _getHeaders();
      
      print('📦 Headers: $headers');
      print('📦 Full URL: $url');
      
      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));
      
      stopwatch.stop();
      print('⏱️ Response time: ${stopwatch.elapsedMilliseconds}ms');
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('📡 ===== API CALL END =====');

      return _handleResponse(response);
    } catch (e) {
      print('❌ ===== API ERROR =====');
      print('❌ Error: $e');
      print('❌ =====================');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('📡 GET: $_baseUrl/$endpoint');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        final errorMessage = responseBody['message'] ?? 
                            responseBody['error'] ?? 
                            'Something went wrong (Status: ${response.statusCode})';
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    }
  }
}