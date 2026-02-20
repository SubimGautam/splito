import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/expense.dart';
import '../../data/datasource/remote/expense_remote_datasource.dart';

final addExpenseViewModelProvider = StateNotifierProvider<AddExpenseViewModel, AsyncValue<Expense?>>((ref) {
  final dataSource = ref.watch(expenseRemoteDataSourceProvider);
  return AddExpenseViewModel(dataSource);
});

class AddExpenseViewModel extends StateNotifier<AsyncValue<Expense?>> {
  final ExpenseRemoteDataSource _dataSource;
  AddExpenseViewModel(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> createExpense({
    required String description,
    required double totalAmount,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> splits,
    required String groupId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final expense = await _dataSource.createExpense(
        description: description,
        totalAmount: totalAmount,
        payments: payments,
        splits: splits,
        groupId: groupId,
      );
      state = AsyncValue.data(expense);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}