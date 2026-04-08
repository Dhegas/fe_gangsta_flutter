class CartItemEntity {
  const CartItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final int quantity;

  CartItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
