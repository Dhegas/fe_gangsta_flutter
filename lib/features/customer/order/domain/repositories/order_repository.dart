import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';

abstract class OrderRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<int> getServiceFee();
}
