import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/group.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';
import 'all_expenses_view_model.dart';

final groupBalancesProvider = FutureProvider<Map<String, double>>((ref) async {
  final groups = await ref.watch(groupRemoteDataSourceProvider).getGroups();
  final expenses = await ref.watch(allExpensesProvider.future);
  final Map<String, double> balances = {};
  for (var group in groups) {
    balances[group.id] = 0.0;
  }
  for (var expense in expenses) {
    final groupId = expense.groupId;
    if (balances.containsKey(groupId)) {
      balances[groupId] = (balances[groupId] ?? 0) + expense.totalAmount;
    }
  }
  return balances;
});