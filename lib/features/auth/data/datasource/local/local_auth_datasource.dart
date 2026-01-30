// features/auth/data/datasource/local/local_auth_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSourceImpl {
  // For saving credentials (optional)
  Future<void> saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      print("💾 Credentials saved locally");
    } catch (e) {
      print("❌ Error saving credentials: $e");
    }
  }
  
  // Get saved credentials
  Future<Map<String, String>?> getCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      print("❌ Error getting credentials: $e");
      return null;
    }
  }
  
  // Clear all auth data
  Future<void> clearAllAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      print("🗑️ All auth data cleared");
    } catch (e) {
      print("❌ Error clearing auth data: $e");
    }
  }
}