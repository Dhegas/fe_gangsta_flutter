import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: '', // Resolving in repository via lookup
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
