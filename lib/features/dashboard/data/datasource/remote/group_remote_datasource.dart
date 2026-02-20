import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/group.dart';
import '../../../domain/model/group_detail.dart';
import '../../../../auth/presentation/providers/dio_provider.dart';

final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return GroupRemoteDataSource(dio);
});

class GroupRemoteDataSource {
  final Dio _dio;
  GroupRemoteDataSource(this._dio);

  Future<List<Group>> getGroups() async {
    final response = await _dio.get('/groups');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => Group.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load groups');
    }
  }

  Future<Group> createGroup(String name, List<String> members) async {
    final response = await _dio.post('/groups', data: {'name': name, 'members': members});
    if (response.statusCode == 201 && response.data['success'] == true) {
      return Group.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create group');
    }
  }

  Future<GroupDetail> getGroupWithBalances(String groupId) async {
    final response = await _dio.get('/groups/$groupId/balances');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return GroupDetail.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load group details');
    }
  }
}