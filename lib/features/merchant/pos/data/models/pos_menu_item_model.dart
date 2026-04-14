import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';

class PosMenuItemModel extends PosMenuItemEntity {
  const PosMenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.basePrice,
    super.discountedPrice,
    required super.channelPricing,
    required super.imageUrl,
    super.badges,
    super.variants,
    super.addOns,
    super.customNotes,
    required super.isActive,
    required super.isInStock,
    required super.remainingPortions,
  });
}
