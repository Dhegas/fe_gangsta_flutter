class OrderItemEntity {
  const OrderItemEntity({
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
  final int unitPrice;
  final int subtotal;
  final String notes;
}

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.diningTablesId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.accessToken,
    this.customerName,
    this.tableName,
  });

  final String id;
  final String tenantId;
  final String userId;
  final String diningTablesId;
  final String status;
  final int totalPrice;
  final String createdAt;
  final String updatedAt;
  final List<OrderItemEntity> items;
  final String? accessToken;
  final String? customerName;
  final String? tableName;
}
