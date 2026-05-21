import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';

class OrderManagementState {
  const OrderManagementState({
    required this.orders,
    required this.tables,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<OrderEntity> orders;
  final Map<String, String> tables; // diningTablesId -> tableName
  final bool isLoading;
  final String? errorMessage;

  factory OrderManagementState.initial() {
    return const OrderManagementState(
      orders: [],
      tables: {},
      isLoading: false,
      errorMessage: null,
    );
  }

  OrderManagementState copyWith({
    List<OrderEntity>? orders,
    Map<String, String>? tables,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderManagementState(
      orders: orders ?? this.orders,
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
