import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/guest_customer_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';

abstract class OrderRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<int> getServiceFee();

  Future<OrderEntity> placeOrder({
    required String tenantSlug,
    required String diningTablesId,
    required List<CartItemEntity> items,
    required String orderNote,
  });

  Future<OrderEntity> placeGuestOrder({
    required String tenantSlug,
    required String diningTableId,
    required List<CartItemEntity> items,
    required String orderNote,
    required GuestCustomerEntity guest,
  });

  Future<List<OrderEntity>> getOrderHistory({required String tenantId});

  Future<OrderEntity> getOrderDetails({
    required String tenantId,
    required String orderId,
  });
}
