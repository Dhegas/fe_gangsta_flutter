import 'package:fe_gangsta_flutter/features/merchant/order_management/data/models/order_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/order_management/domain/entities/order_entity.dart';

class OrderModel {
  const OrderModel({
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
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final itemsList = rawItems != null
        ? rawItems.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>)).toList()
        : <OrderItemModel>[];

    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      diningTablesId: json['dining_tables_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedDate,
      items: itemsList,
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      tenantId: tenantId,
      diningTablesId: diningTablesId,
      status: status,
      totalPrice: totalPrice,
      createdAt: createdAt,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}
