import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<OrderModel> placeOrder({
    required String tenantSlug,
    required String diningTablesId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/orders/tenant/$tenantSlug',
        body: {
          'dining_tables_id': diningTablesId,
          'items': items,
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null) {
            return OrderModel.fromJson(data);
          }
        }
        final message = response['message'] as String? ?? 'Gagal membuat pesanan';
        throw ApiException(message);
      }
      throw ApiException('Response tidak valid dari server');
    } catch (e) {
      rethrow;
    }
  }
}
