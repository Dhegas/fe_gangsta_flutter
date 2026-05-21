import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_item_entity.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.notes,
  });

  final String id;
  final String menuId;
  final String menuName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String notes;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      menuName: json['menu_name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString() ?? '',
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      menuId: menuId,
      menuName: menuName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      notes: notes,
    );
  }
}
