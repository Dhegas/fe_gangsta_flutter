import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final OrderLocalDataSource _localDataSource;
  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() {
    return _localDataSource.getPaymentMethods();
  }

  @override
  Future<int> getServiceFee() {
    return _localDataSource.getServiceFee();
  }

  @override
  Future<OrderEntity> placeOrder({
    required String tenantSlug,
    required String diningTablesId,
    required List<CartItemEntity> items,
    required String orderNote,
  }) async {
    final mappedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'menu_id': item.id,
        'quantity': item.quantity,
        'notes': index == 0 ? orderNote : '',
      };
    }).toList();

    return _remoteDataSource.placeOrder(
      tenantSlug: tenantSlug,
      diningTablesId: diningTablesId,
      items: mappedItems,
    );
  }
}

