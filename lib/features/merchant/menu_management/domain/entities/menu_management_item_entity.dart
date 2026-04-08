class MenuManagementItemEntity {
  const MenuManagementItemEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.imageUrl,
    required this.isInStock,
  });

  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String imageUrl;
  final bool isInStock;

  MenuManagementItemEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? price,
    String? imageUrl,
    bool? isInStock,
  }) {
    return MenuManagementItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isInStock: isInStock ?? this.isInStock,
    );
  }
}
