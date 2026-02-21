import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/expense.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';
import '../../data/datasource/remote/expense_remote_datasource.dart';

final allExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final groups = await ref.watch(groupRemoteDataSourceProvider).getGroups();
  final expenses = <Expense>[];
  for (var group in groups) {
    // If you have an endpoint to get all expenses, use it. Otherwise, we need group detail.
    // For simplicity, we'll assume we can fetch group detail which includes expenses.
    // But group detail requires groupId and returns GroupDetail with expenses list.
    // To avoid many calls, we can create a dedicated endpoint later. For now, we'll fetch each group's detail.
    final detail = await ref.watch(groupRemoteDataSourceProvider).getGroupWithBalances(group.id);
    expenses.addAll(detail.expenses);
  }
  // Sort by date descending
  expenses.sort((a, b) => b.date.compareTo(a.date));
  return expenses;
});

final deleteExpenseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.watch(expenseRemoteDataSourceProvider));
});

class DeleteExpense {
  final ExpenseRemoteDataSource _dataSource;
  DeleteExpense(this._dataSource);

  Future<void> call(String expenseId) => _dataSource.deleteExpense(expenseId);
}