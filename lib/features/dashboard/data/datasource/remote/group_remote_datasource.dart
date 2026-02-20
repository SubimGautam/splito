import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splito_project/features/auth/presentation/providers/dio_provider.dart';
import '../../../domain/model/group.dart';

part 'group_remote_datasource.g.dart';

@riverpod
GroupRemoteDataSource groupRemoteDataSource(GroupRemoteDataSourceRef ref) {
  final dio = ref.watch(dioProvider);
  return GroupRemoteDataSource(dio);
}

class GroupRemoteDataSource {
  final Dio _dio;
  GroupRemoteDataSource(this._dio);

  Future<List<Group>> getGroups() async {
    try {
      final response = await _dio.get('/groups');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => Group.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load groups');
      }
    } catch (e) {
      throw Exception('Failed to load groups: $e');
    }
  }

  Future<Group> createGroup(String name, List<String> members) async {
    try {
      final response = await _dio.post('/groups', data: {
        'name': name,
        'members': members,
      });
      if (response.statusCode == 201 && response.data['success'] == true) {
        return Group.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create group');
      }
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Add other methods: getGroupById, updateGroup, deleteGroup, getGroupWithBalances
}