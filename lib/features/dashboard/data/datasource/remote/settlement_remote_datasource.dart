import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/settlement.dart';
import '../../../../auth/presentation/providers/dio_provider.dart';

final settlementRemoteDataSourceProvider = Provider<SettlementRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementRemoteDataSource(dio);
});

class SettlementRemoteDataSource {
  final Dio _dio;
  SettlementRemoteDataSource(this._dio);

  Future<Settlement> createSettlement({
    required String from,
    required String to,
    required double amount,
    required String groupId,
  }) async {
    final response = await _dio.post('/settlements', data: {
      'from': from,
      'to': to,
      'amount': amount,
      'groupId': groupId,
    });
    if (response.statusCode == 201 && response.data['success'] == true) {
      return Settlement.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create settlement');
    }
  }
}