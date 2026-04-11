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
}
