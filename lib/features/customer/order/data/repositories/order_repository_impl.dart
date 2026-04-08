import 'package:fe_gangsta_flutter/features/customer/order/data/datasources/order_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._localDataSource);

  final OrderLocalDataSource _localDataSource;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() {
    return _localDataSource.getPaymentMethods();
  }

  @override
  Future<int> getServiceFee() {
    return _localDataSource.getServiceFee();
  }
}
