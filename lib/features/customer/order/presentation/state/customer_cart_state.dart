import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';

class CustomerCartState {
  const CustomerCartState({
    this.isLoading = true,
    this.items = const [],
    this.paymentMethods = const [],
    this.selectedPaymentMethodId,
    this.orderNote = '',
    this.serviceFee = 0,
  });

  final bool isLoading;
  final List<CartItemEntity> items;
  final List<PaymentMethodEntity> paymentMethods;
  final String? selectedPaymentMethodId;
  final String orderNote;
  final int serviceFee;

  CustomerCartState copyWith({
    bool? isLoading,
    List<CartItemEntity>? items,
    List<PaymentMethodEntity>? paymentMethods,
    String? selectedPaymentMethodId,
    String? orderNote,
    int? serviceFee,
  }) {
    return CustomerCartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      orderNote: orderNote ?? this.orderNote,
      serviceFee: serviceFee ?? this.serviceFee,
    );
  }
}
