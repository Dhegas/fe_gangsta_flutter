import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_item_entity.dart';

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.tenantId,
    required this.diningTablesId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String tenantId;
  final String diningTablesId;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItemEntity> items;

  OrderEntity copyWith({
    String? id,
    String? tenantId,
    String? diningTablesId,
    String? status,
    double? totalPrice,
    DateTime? createdAt,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      diningTablesId: diningTablesId ?? this.diningTablesId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
