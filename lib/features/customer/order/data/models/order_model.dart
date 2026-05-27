import 'package:fe_gangsta_flutter/features/customer/order/domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.menuId,
    required super.menuName,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
    required super.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      menuId: json['menu_id'] as String? ?? '',
      menuName: json['menu_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unit_price'] as int? ?? 0,
      subtotal: json['subtotal'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.tenantId,
    required super.userId,
    required super.diningTablesId,
    required super.status,
    required super.totalPrice,
    required super.createdAt,
    required super.updatedAt,
    required List<OrderItemModel> super.items,
    super.accessToken,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      diningTablesId: json['dining_tables_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPrice: json['total_price'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      items: items,
      accessToken: json['accessToken'] as String? ?? json['access_token'] as String?,
    );
  }
}
