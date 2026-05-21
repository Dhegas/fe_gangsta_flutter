import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/data/datasources/order_management_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/data/models/order_model.dart';

class OrderManagementRemoteDataSourceImpl implements OrderManagementRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<OrderModel>> fetchOrders() async {
    final response = await _apiClient.get('/api/v1/orders');
    if (response != null && response['data'] != null) {
      final list = response['data'] as List;
      return list
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> deleteOrder(String id) async {
    await _apiClient.delete('/api/v1/orders/$id');
    return true;
  }
}
