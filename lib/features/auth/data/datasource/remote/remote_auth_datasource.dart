import 'package:splito_project/core/services/api_service.dart';

abstract class RemoteAuthDataSource {
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> getProfile();
  Future<void> logout();
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      print('🚀 ===== REMOTE SIGNUP START =====');
      print('📧 Email: $email');
      print('🔑 Password length: ${password.length} characters');
      
      final response = await ApiService.post('auth/register', {
        'email': email,
        'password': password,
      });

      print('✅ API Response: $response');
      
      final data = response['data'] as Map<String, dynamic>;
      if (data['token'] != null) {
        ApiService.setToken(data['token'] as String);
        print('🔑 Token saved successfully');
      }

      print('✅ ===== REMOTE SIGNUP SUCCESS =====');
      return data;
    } catch (e) {
      print('❌ ===== REMOTE SIGNUP FAILED =====');
      print('❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      print('🚀 ===== REMOTE LOGIN START =====');
      print('📧 Email: $email');
      
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      print('✅ API Response: $response');
      
      final data = response['data'] as Map<String, dynamic>;
      if (data['token'] != null) {
        ApiService.setToken(data['token'] as String);
        print('🔑 Token saved successfully');
      }

      print('✅ ===== REMOTE LOGIN SUCCESS =====');
      return data;
    } catch (e) {
      print('❌ ===== REMOTE LOGIN FAILED =====');
      print('❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('👤 Getting user profile...');
      final response = await ApiService.get('auth/profile');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ Get profile error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    ApiService.clearToken();
    print('👋 User logged out');
  }
}