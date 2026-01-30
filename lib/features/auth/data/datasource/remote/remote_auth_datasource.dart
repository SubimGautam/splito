import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splito_project/core/services/api_service.dart';

abstract class RemoteAuthDataSource {
  Future<Map<String, dynamic>> signUp(
    String username,
    String email,
    String password,
    String confirmPassword,
  );

  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> getProfile();
  Future<void> logout();
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  // Helper method for min function
  int min(int a, int b) => a < b ? a : b;

  // Method to save token to SharedPreferences
  Future<void> _saveTokenToSharedPreferences(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('💾 Token saved to SharedPreferences: ${token.substring(0, min(20, token.length))}...');
      
      // Verify it was saved
      final savedToken = prefs.getString('auth_token');
      print('🔍 Token verification: ${savedToken != null ? 'SAVED' : 'NOT SAVED'}');
      if (savedToken != null) {
        print('📏 Saved token length: ${savedToken.length}');
      }
    } catch (e) {
      print('❌ Error saving token to SharedPreferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> signUp(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      print('🚀 ===== REMOTE SIGNUP START =====');
      print('👤 Username: $username');
      print('📧 Email: $email');

      final response = await ApiService.post('auth/register', {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      print('✅ API Response: $response');

      // Fixed: Extract data correctly
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        
        if (data['token'] != null) {
          final token = data['token'] as String;
          
          // ✅ Save to ApiService
          ApiService.setToken(token);
          
          // ✅ CRITICAL: Also save to SharedPreferences
          await _saveTokenToSharedPreferences(token);
          
          print('🔑 Token saved successfully: ${token.substring(0, min(20, token.length))}...');
        } else {
          print('⚠️ Warning: No token in response data');
        }
        
        print('✅ ===== REMOTE SIGNUP SUCCESS =====');
        return data;
      } else {
        throw Exception(response['message'] ?? 'Signup failed');
      }
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

      // Fixed: Extract data correctly
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        
        if (data['token'] != null) {
          final token = data['token'] as String;
          
          // ✅ Save to ApiService
          ApiService.setToken(token);
          
          // ✅ CRITICAL: Also save to SharedPreferences
          await _saveTokenToSharedPreferences(token);
          
          print('🔑 Token saved successfully: ${token.substring(0, min(20, token.length))}...');
        } else {
          print('⚠️ Warning: No token in response data');
          throw Exception('No token received from server');
        }
        
        print('✅ ===== REMOTE LOGIN SUCCESS =====');
        return data;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
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
      
      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      print('❌ Get profile error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    // Clear from ApiService
    ApiService.clearToken();
    
    // Also clear from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('🗑️ Token cleared from SharedPreferences');
    } catch (e) {
      print('❌ Error clearing token from SharedPreferences: $e');
    }
    
    print('👋 User logged out');
  }
}