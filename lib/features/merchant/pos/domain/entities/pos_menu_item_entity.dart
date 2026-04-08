class PosMenuItemEntity {
  const PosMenuItemEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String imageUrl;
  final bool isAvailable;
}
