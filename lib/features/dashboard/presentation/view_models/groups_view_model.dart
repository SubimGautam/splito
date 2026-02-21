import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/group.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';

final groupsViewModelProvider = StateNotifierProvider<GroupsViewModel, AsyncValue<List<Group>>>((ref) {
  final dataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupsViewModel(dataSource);
});

class GroupsViewModel extends StateNotifier<AsyncValue<List<Group>>> {
  final GroupRemoteDataSource _dataSource;
  GroupsViewModel(this._dataSource) : super(const AsyncValue.loading());

  Future<void> loadGroups() async {
    print('loadGroups called');
    state = const AsyncValue.loading();
    try {
      final groups = await _dataSource.getGroups();
      print('loadGroups success, count: ${groups.length}');
      state = AsyncValue.data(groups);
    } catch (e, st) {
      print('loadGroups error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGroup(String name, List<String> members) async {
    try {
      await _dataSource.createGroup(name, members);
      await loadGroups();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _dataSource.deleteGroup(groupId);
      await loadGroups();
    } catch (e) {
      rethrow;
    }
  }
}