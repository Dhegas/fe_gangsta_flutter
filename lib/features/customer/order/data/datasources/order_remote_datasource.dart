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
        body: {'dining_tables_id': diningTablesId, 'items': items},
      );

      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null) {
            return OrderModel.fromJson(data);
          }
        }
        final message =
            response['message'] as String? ?? 'Gagal membuat pesanan';
        throw ApiException(message);
      }
      throw ApiException('Response tidak valid dari server');
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderModel> placeGuestOrder({
    required String tenantSlug,
    required String diningTableId,
    required List<Map<String, dynamic>> items,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/public/tenant/$tenantSlug/orders',
        body: {
          'diningTableId': diningTableId,
          'items': items,
          'customer': {
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            if (email != null && email.isNotEmpty) 'email': email,
            if (password != null && password.isNotEmpty) 'password': password,
          },
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null) {
            return OrderModel(
              id: data['orderId'] as String? ?? '',
              status: data['status'] as String? ?? 'pending',
              totalPrice: data['totalPrice'] as int? ?? 0,
              tenantId: '',
              userId: '',
              diningTablesId: diningTableId,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
              items: const [],
              accessToken: data['accessToken'] as String?,
            );
          }
        }
        final message =
            response['message'] as String? ?? 'Gagal membuat pesanan tamu';
        throw ApiException(message);
      }
      throw ApiException('Response tidak valid dari server');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getOrderHistory({required String tenantId}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/orders',
        tenantId: tenantId,
      );

      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final dataList = response['data'] as List<dynamic>? ?? [];
          return dataList
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        final message =
            response['message'] as String? ?? 'Gagal mengambil riwayat pesanan';
        throw ApiException(message);
      }
      throw ApiException('Response tidak valid dari server');
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderModel> getOrderDetails({
    required String tenantId,
    required String orderId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/orders/$orderId',
        tenantId: tenantId,
      );

      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null) {
            return OrderModel.fromJson(data);
          }
        }
        final message =
            response['message'] as String? ?? 'Gagal mengambil detail pesanan';
        throw ApiException(message);
      }
      throw ApiException('Response tidak valid dari server');
    } catch (e) {
      rethrow;
    }
  }
}
