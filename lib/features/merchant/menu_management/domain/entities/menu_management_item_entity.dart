enum MenuBadge { bestSeller, promo, chefsRecommendation }

extension MenuBadgeLabel on MenuBadge {
  String get label {
    switch (this) {
      case MenuBadge.bestSeller:
        return 'Best Seller';
      case MenuBadge.promo:
        return 'Promo';
      case MenuBadge.chefsRecommendation:
        return 'Chef Recommendation';
    }
  }
}

class MenuVariantOption {
  const MenuVariantOption({
    required this.name,
    required this.priceDelta,
  });

  final String name;
  final double priceDelta;
}

class MenuAddOnOption {
  const MenuAddOnOption({
    required this.name,
    required this.price,
  });

  final String name;
  final double price;
}

class MenuChannelPricing {
  const MenuChannelPricing({
    required this.dineIn,
    required this.takeaway,
    required this.online,
  });

  final double dineIn;
  final double takeaway;
  final double online;
}

class MenuManagementItemEntity {
  const MenuManagementItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.basePrice,
    this.discountedPrice,
    required this.channelPricing,
    required this.imageUrl,
    this.imageAspectRatio = 1,
    this.variants = const [],
    this.addOns = const [],
    this.customNotes = const [],
    this.badges = const [],
    required this.isActive,
    required this.isInStock,
    required this.remainingPortions,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double basePrice;
  final double? discountedPrice;
  final MenuChannelPricing channelPricing;
  final String imageUrl;
  final double imageAspectRatio;
  final List<MenuVariantOption> variants;
  final List<MenuAddOnOption> addOns;
  final List<String> customNotes;
  final List<MenuBadge> badges;
  final bool isActive;
  final bool isInStock;
  final int remainingPortions;
  final int sortOrder;

  double get effectivePrice => discountedPrice ?? basePrice;

  MenuManagementItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    double? basePrice,
    double? discountedPrice,
    bool clearDiscountedPrice = false,
    MenuChannelPricing? channelPricing,
    String? imageUrl,
    double? imageAspectRatio,
    List<MenuVariantOption>? variants,
    List<MenuAddOnOption>? addOns,
    List<String>? customNotes,
    List<MenuBadge>? badges,
    bool? isActive,
    bool? isInStock,
    int? remainingPortions,
    int? sortOrder,
  }) {
    return MenuManagementItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      basePrice: basePrice ?? this.basePrice,
      discountedPrice: clearDiscountedPrice
          ? null
          : discountedPrice ?? this.discountedPrice,
      channelPricing: channelPricing ?? this.channelPricing,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAspectRatio: imageAspectRatio ?? this.imageAspectRatio,
      variants: variants ?? this.variants,
      addOns: addOns ?? this.addOns,
      customNotes: customNotes ?? this.customNotes,
      badges: badges ?? this.badges,
      isActive: isActive ?? this.isActive,
      isInStock: isInStock ?? this.isInStock,
      remainingPortions: remainingPortions ?? this.remainingPortions,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
