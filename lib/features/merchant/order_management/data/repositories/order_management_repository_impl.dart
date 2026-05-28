import 'package:fe_gangsta_flutter/features/merchant/order_management/data/datasources/order_management_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/repositories/order_management_repository.dart';

class OrderManagementRepositoryImpl implements OrderManagementRepository {
  const OrderManagementRepositoryImpl({required this.remoteDataSource});

  final OrderManagementRemoteDataSource remoteDataSource;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final models = await remoteDataSource.fetchOrders();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<bool> deleteOrder(String id) async {
    return remoteDataSource.deleteOrder(id);
  }

  @override
  Future<bool> updateOrderStatus(String id, String status) async {
    return remoteDataSource.updateOrderStatus(id, status);
  }
}
