import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/group.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';

// Add this notifier class
class GroupsViewModelNotifier extends StateNotifier<AsyncValue<List<Group>>> {
  final GroupRemoteDataSource _dataSource;
  
  GroupsViewModelNotifier(this._dataSource) : super(const AsyncValue.loading());

  Future<void> loadGroups() async {
    state = const AsyncValue.loading();
    try {
      final groups = await _dataSource.getGroups();
      state = AsyncValue.data(groups);
    } catch (e, st) {
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

final groupsViewModelProvider = StateNotifierProvider<GroupsViewModelNotifier, AsyncValue<List<Group>>>((ref) {
  final dataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupsViewModelNotifier(dataSource);
});