import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';

class PosMenuItemModel extends PosMenuItemEntity {
  const PosMenuItemModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.price,
    required super.imageUrl,
    required super.isAvailable,
  });
}
