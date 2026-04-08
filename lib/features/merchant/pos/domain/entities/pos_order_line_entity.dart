class PosOrderLineEntity {
  const PosOrderLineEntity({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String itemId;
  final String name;
  final double unitPrice;
  final int quantity;

  PosOrderLineEntity copyWith({
    String? itemId,
    String? name,
    double? unitPrice,
    int? quantity,
  }) {
    return PosOrderLineEntity(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
