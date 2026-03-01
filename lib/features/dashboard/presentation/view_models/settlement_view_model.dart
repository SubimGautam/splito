import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/remote/settlement_remote_datasource.dart';

final settlementViewModelProvider = Provider<SettlementViewModel>((ref) {
  final dataSource = ref.watch(settlementRemoteDataSourceProvider);
  return SettlementViewModel(dataSource);
});

class SettlementViewModel {
  final SettlementRemoteDataSource _dataSource;
  SettlementViewModel(this._dataSource);

  Future<void> createSettlement({
    required String from,
    required String to,
    required double amount,
    required String groupId,
  }) async {
    try {
      await _dataSource.createSettlement(
        from: from,
        to: to,
        amount: amount,
        groupId: groupId,
      );
    } catch (e) {
      throw Exception('Failed to create settlement: $e');
    }
  }
}