import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';

class MenuManagementItemModel extends MenuManagementItemEntity {
  const MenuManagementItemModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.price,
    required super.imageUrl,
    required super.isInStock,
  });
}
