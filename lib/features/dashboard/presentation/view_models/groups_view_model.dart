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
      await loadGroups(); // refresh list
    } catch (e) {
      // you could also show a snackbar here, but we'll handle in UI
      rethrow;
    }
  }
}