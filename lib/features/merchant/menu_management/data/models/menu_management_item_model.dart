import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';

class MenuManagementItemModel extends MenuManagementItemEntity {
  const MenuManagementItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.basePrice,
    super.discountedPrice,
    required super.channelPricing,
    required super.imageUrl,
    super.imageAspectRatio,
    super.variants,
    super.addOns,
    super.customNotes,
    super.badges,
    required super.isActive,
    required super.isInStock,
    required super.remainingPortions,
    required super.sortOrder,
  });
}
