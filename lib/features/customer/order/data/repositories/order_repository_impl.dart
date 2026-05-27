import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
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

  @override
  Future<OrderEntity> placeGuestOrder({
    required String tenantSlug,
    required String diningTableId,
    required List<CartItemEntity> items,
    required String orderNote,
    required GuestCustomerEntity guest,
  }) async {
    final mappedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'menuId': item.id,
        'quantity': item.quantity,
        'notes': index == 0 ? orderNote : '',
      };
    }).toList();

    final resultOrder = await _remoteDataSource.placeGuestOrder(
      tenantSlug: tenantSlug,
      diningTableId: diningTableId,
      items: mappedItems,
      fullName: guest.fullName,
      phoneNumber: guest.phoneNumber,
      email: guest.email,
      password: guest.password,
    );

    // Reconstruct full item lists locally for structural receipt presentation
    final orderItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return OrderItemEntity(
        id: '',
        menuId: item.id,
        menuName: item.name,
        quantity: item.quantity,
        unitPrice: item.price,
        subtotal: item.price * item.quantity,
        notes: index == 0 ? orderNote : '',
      );
    }).toList();

    return OrderEntity(
      id: resultOrder.id,
      tenantId: resultOrder.tenantId,
      userId: resultOrder.userId,
      diningTablesId: resultOrder.diningTablesId,
      status: resultOrder.status,
      totalPrice: resultOrder.totalPrice,
      createdAt: resultOrder.createdAt,
      updatedAt: resultOrder.updatedAt,
      items: orderItems,
      accessToken: resultOrder.accessToken,
    );
  }
}

