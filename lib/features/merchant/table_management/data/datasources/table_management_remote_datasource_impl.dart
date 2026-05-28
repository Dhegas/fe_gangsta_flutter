import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/datasources/table_management_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/data/models/table_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';

class TableManagementRemoteDataSourceImpl implements TableManagementRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<TableModel>> fetchTables() async {
    final response = await _apiClient.get('/api/v1/partner/dining-tables');
    if (response != null && response['data'] != null) {
      final list = response['data'] as List;
      return list.map((json) => TableModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<TableStatus> fetchTableStatus(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/partner/dining-tables/$id/status');
      if (response != null && response['data'] != null) {
        final statusStr = response['data']['status']?.toString();
        if (statusStr == 'occupied') {
          return TableStatus.occupied;
        }
      }
    } catch (e) {
      print('Error fetching status for table $id: $e');
    }
    return TableStatus.available;
  }

  @override
  Future<TableModel?> createTable(String name) async {
    final response = await _apiClient.post(
      '/api/v1/partner/dining-tables',
      body: {'table_name': name},
    );
    if (response != null && response['data'] != null) {
      return TableModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<TableModel?> updateTable(String id, String name) async {
    final response = await _apiClient.put(
      '/api/v1/partner/dining-tables/$id',
      body: {'table_name': name},
    );
    if (response != null && response['data'] != null) {
      return TableModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<bool> deleteTable(String id) async {
    await _apiClient.delete('/api/v1/partner/dining-tables/$id');
    return true;
  }
}
