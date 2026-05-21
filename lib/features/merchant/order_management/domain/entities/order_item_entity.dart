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
  final double unitPrice;
  final double subtotal;
  final String notes;

  OrderItemEntity copyWith({
    String? id,
    String? menuId,
    String? menuName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    String? notes,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
    );
  }
}
