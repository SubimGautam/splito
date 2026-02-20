import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api', // For Android emulator
    // baseUrl: 'http://localhost:5000/api', // For iOS simulator
    // baseUrl: 'http://192.168.x.x:5000/api', // For physical device (use your computer's IP)
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Add interceptor to add token to requests
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
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
        return handler.next(error);
      },
    ),
  );

  return dio;
});