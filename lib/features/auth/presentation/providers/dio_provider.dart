import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api', // Android emulator
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
    validateStatus: (status) => true, // Don't throw on any status
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      // Try both possible keys
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      
      print('🔑 Token from prefs: $token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('✅ Added token to request');
      } else {
        print('❌ No token found in SharedPreferences');
        // Print all keys for debugging
        print('📋 Available keys: ${prefs.getKeys()}');
      }
      print('🌐 Request: ${options.method} ${options.path}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('✅ Response: ${response.statusCode}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('❌ Error: ${error.message}');
      if (error.response?.statusCode == 401) {
        print('🔴 Unauthorized! Token may be invalid or expired.');
      }
      return handler.next(error);
    },
  ));

  return dio;
});