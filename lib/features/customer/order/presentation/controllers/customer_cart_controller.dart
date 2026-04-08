import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/cart_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/payment_method_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/order/domain/repositories/order_repository.dart';
import 'package:fe_gangsta_flutter/features/customer/order/presentation/state/customer_cart_state.dart';
import 'package:flutter/foundation.dart';

class CustomerCartController extends ChangeNotifier {
  CustomerCartController({
    required this.repository,
    required List<CartItemEntity> initialItems,
  }) : _state = CustomerCartState(items: initialItems);

  final OrderRepository repository;

  CustomerCartState _state;

  CustomerCartState get state => _state;

  Future<void> initialize() async {
    final methods = await repository.getPaymentMethods();
    final serviceFee = await repository.getServiceFee();

    _state = _state.copyWith(
      isLoading: false,
      paymentMethods: methods,
      selectedPaymentMethodId: methods.isEmpty ? null : methods.first.id,
      serviceFee: serviceFee,
    );
    notifyListeners();
  }

  void increaseQty(String itemId) {
    _state = _state.copyWith(
      items: _state.items
          .map(
            (item) => item.id == itemId
                ? item.copyWith(quantity: item.quantity + 1)
                : item,
          )
          .toList(),
    );
    notifyListeners();
  }

  void decreaseQty(String itemId) {
    final updatedItems = _state.items
        .map((item) {
          if (item.id != itemId) {
            return item;
          }
          final newQty = item.quantity - 1;
          if (newQty <= 0) {
            return null;
          }
          return item.copyWith(quantity: newQty);
        })
        .whereType<CartItemEntity>()
        .toList();

    _state = _state.copyWith(items: updatedItems);
    notifyListeners();
  }

  void removeItem(String itemId) {
    _state = _state.copyWith(
      items: _state.items.where((item) => item.id != itemId).toList(),
    );
    notifyListeners();
  }

  void updateOrderNote(String note) {
    _state = _state.copyWith(orderNote: note);
    notifyListeners();
  }

  void updatePaymentMethod(String methodId) {
    _state = _state.copyWith(selectedPaymentMethodId: methodId);
    notifyListeners();
  }

  int get subtotal {
    return _state.items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  PaymentMethodEntity? get selectedPaymentMethod {
    for (final method in _state.paymentMethods) {
      if (method.id == _state.selectedPaymentMethodId) {
        return method;
      }
    }
    return null;
  }

  int get additionalFee {
    final paymentFee = selectedPaymentMethod?.adminFee ?? 0;
    return _state.serviceFee + paymentFee;
  }

  int get totalPayment {
    return subtotal + additionalFee;
  }

  Map<String, int> get quantityMap {
    final map = <String, int>{};
    for (final item in _state.items) {
      map[item.id] = item.quantity;
    }
    return map;
  }
}
