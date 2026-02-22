import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/user.dart';
import '../../../../auth/presentation/providers/dio_provider.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSource(dio);
});

class UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSource(this._dio);

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load user');
    }
  }
}