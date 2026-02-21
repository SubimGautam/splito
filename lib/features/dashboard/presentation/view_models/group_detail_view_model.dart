import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/group_detail.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';

final groupDetailViewModelProvider = StateNotifierProvider<GroupDetailViewModel, AsyncValue<GroupDetail?>>((ref) {
  final dataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupDetailViewModel(dataSource);
});

class GroupDetailViewModel extends StateNotifier<AsyncValue<GroupDetail?>> {
  final GroupRemoteDataSource _dataSource;
  GroupDetailViewModel(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> loadGroupDetail(String groupId) async {
    state = const AsyncValue.loading();
    try {
      final detail = await _dataSource.getGroupWithBalances(groupId);
      state = AsyncValue.data(detail);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}