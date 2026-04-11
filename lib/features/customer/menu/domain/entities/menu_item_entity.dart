class MenuItemEntity {
  const MenuItemEntity({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
}
