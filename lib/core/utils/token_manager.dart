// utils/token_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Singleton instance
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();
  
  // Save token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print("✅ Token saved successfully");
    } catch (e) {
      print("❌ Error saving token: $e");
      rethrow;
    }
  }
  
  // Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token == null) {
        print("⚠️ No token found in SharedPreferences");
      } else {
        print("✅ Token retrieved (length: ${token.length})");
      }
      
      return token;
    } catch (e) {
      print("❌ Error getting token: $e");
      return null;
    }
  }
  
  // Clear token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print("🗑️ Token cleared");
    } catch (e) {
      print("❌ Error clearing token: $e");
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Save user data
  Future<void> saveUserData(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
      print("✅ User data saved");
    } catch (e) {
      print("❌ Error saving user data: $e");
    }
  }
  
  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      print("❌ Error getting user data: $e");
      return null;
    }
  }
}