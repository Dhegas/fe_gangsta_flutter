import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';

abstract class OrderManagementRepository {
  Future<List<OrderEntity>> getOrders();
  Future<bool> deleteOrder(String id);
  Future<bool> updateOrderStatus(String id, String status);
}
