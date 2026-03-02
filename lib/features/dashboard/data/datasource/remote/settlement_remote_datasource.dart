import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/dio_provider.dart';
import '../../../domain/model/settlement.dart';

final settlementRemoteDataSourceProvider = Provider<SettlementRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementRemoteDataSource(dio);
});

class SettlementRemoteDataSource {
  final Dio _dio;
  SettlementRemoteDataSource(this._dio);

  /// Create a new settlement
  Future<Settlement> createSettlement({
    required String from,
    required String to,
    required double amount,
    required String groupId,
  }) async {
    try {
      print("📤 Creating settlement: $from → $to amount: $amount");
      
      final response = await _dio.post('/settlements', data: {
        'from': from,
        'to': to,
        'amount': amount,
        'groupId': groupId,
      });

      print("📥 Settlement response: ${response.statusCode}");
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        return Settlement.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create settlement');
      }
    } on DioException catch (e) {
      print("❌ Dio error creating settlement: ${e.message}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        throw Exception(e.response?.data['message'] ?? 'Server error');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("❌ Unexpected error creating settlement: $e");
      throw Exception('Failed to create settlement: $e');
    }
  }

  /// Get all settlements for a group
  Future<List<Settlement>> getGroupSettlements(String groupId) async {
    try {
      print("📤 Fetching settlements for group: $groupId");
      
      final response = await _dio.get('/settlements/group/$groupId');
      
      print("📥 Settlements response: ${response.statusCode}");
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => Settlement.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get settlements');
      }
    } on DioException catch (e) {
      print("❌ Dio error getting settlements: ${e.message}");
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Server error');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("❌ Unexpected error getting settlements: $e");
      throw Exception('Failed to get settlements: $e');
    }
  }

  /// Delete a settlement (admin only)
  Future<void> deleteSettlement(String settlementId) async {
    try {
      print("📤 Deleting settlement: $settlementId");
      
      final response = await _dio.delete('/settlements/$settlementId');
      
      print("📥 Delete settlement response: ${response.statusCode}");
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete settlement');
      }
    } on DioException catch (e) {
      print("❌ Dio error deleting settlement: ${e.message}");
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Server error');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("❌ Unexpected error deleting settlement: $e");
      throw Exception('Failed to delete settlement: $e');
    }
  }
}