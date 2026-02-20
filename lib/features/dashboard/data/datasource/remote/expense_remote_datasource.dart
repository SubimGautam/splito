import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/expense.dart';
import '../../../../auth/presentation/providers/dio_provider.dart';

final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpenseRemoteDataSource(dio);
});

class ExpenseRemoteDataSource {
  final Dio _dio;
  ExpenseRemoteDataSource(this._dio);

  Future<Expense> createExpense({
    required String description,
    required double totalAmount,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> splits,
    required String groupId,
  }) async {
    final response = await _dio.post('/expenses', data: {
      'description': description,
      'totalAmount': totalAmount,
      'payments': payments,
      'splits': splits,
      'groupId': groupId,
    });
    if (response.statusCode == 201 && response.data['success'] == true) {
      return Expense.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create expense');
    }
  }
}