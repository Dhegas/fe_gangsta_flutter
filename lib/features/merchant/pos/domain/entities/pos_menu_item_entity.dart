import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';

class PosMenuItemEntity {
  const PosMenuItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.basePrice,
    this.discountedPrice,
    required this.channelPricing,
    required this.imageUrl,
    this.badges = const [],
    this.variants = const [],
    this.addOns = const [],
    this.customNotes = const [],
    required this.isActive,
    required this.isInStock,
    required this.remainingPortions,
  });

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double basePrice;
  final double? discountedPrice;
  final MenuChannelPricing channelPricing;
  final String imageUrl;
  final List<MenuBadge> badges;
  final List<MenuVariantOption> variants;
  final List<MenuAddOnOption> addOns;
  final List<String> customNotes;
  final bool isActive;
  final bool isInStock;
  final int remainingPortions;

  bool get isAvailable => isActive && isInStock && remainingPortions > 0;

  double resolveUnitPrice(PosSalesChannel channel) {
    switch (channel) {
      case PosSalesChannel.dineIn:
        return channelPricing.dineIn;
      case PosSalesChannel.takeaway:
        return channelPricing.takeaway;
      case PosSalesChannel.online:
        return channelPricing.online;
    }
  }
}
