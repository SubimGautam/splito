import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/group_detail.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';

class GroupDetailViewModel extends StateNotifier<AsyncValue<GroupDetail?>> {
  final GroupRemoteDataSource _dataSource;
  GroupDetailViewModel(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> loadGroupDetail(String groupId) async {
    print('🔄 Loading group detail for $groupId');
    state = const AsyncValue.loading();
    try {
      final detail = await _dataSource.getGroupWithBalances(groupId);
      print('✅ Detail loaded: ${detail.group.name}');
      state = AsyncValue.data(detail);
    } catch (e, st) {
      print('❌ Error loading group detail: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final groupDetailViewModelProvider = StateNotifierProvider<GroupDetailViewModel, AsyncValue<GroupDetail?>>((ref) {
  final dataSource = ref.watch(groupRemoteDataSourceProvider);
  return GroupDetailViewModel(dataSource);
});