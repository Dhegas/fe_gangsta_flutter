import 'package:fe_gangsta_flutter/features/merchant/order_management/data/models/order_model.dart';

abstract class OrderManagementRemoteDataSource {
  Future<List<OrderModel>> fetchOrders();
  Future<bool> deleteOrder(String id);
}
