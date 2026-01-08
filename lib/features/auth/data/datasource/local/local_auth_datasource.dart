import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalAuthDataSource {
  Future<void> saveCredentials(String username, String password);
  Future<Map<String, String>?> getCredentials();
  Future<void> clearCredentials();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  static const String _keyUsername = 'registered_username';
  static const String _keyPassword = 'registered_password';

  @override
  Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
  }

  @override
  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final password = prefs.getString(_keyPassword);

    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  @override
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
  }
}