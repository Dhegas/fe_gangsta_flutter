class UnifiedDummyStore {
  const UnifiedDummyStore({
    required this.id,
    required this.name,
    required this.description,
    required this.bannerImageUrl,
    required this.ownerName,
    required this.status,
    required this.subscriptionPlan,
    required this.joinDate,
  });

  final String id;
  final String name;
  final String description;
  final String bannerImageUrl;
  final String ownerName;
  final String status;
  final String subscriptionPlan;
  final DateTime joinDate;
}

class UnifiedDummyMenuItem {
  const UnifiedDummyMenuItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.isInStock,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final bool isInStock;
}

class UnifiedDummyStoreData {
  const UnifiedDummyStoreData._();

  static const String merchantStoreId = '';

  static const List<String> merchantTableLabels = [];

  static final List<UnifiedDummyStore> stores = [];

  static UnifiedDummyStore? getStoreById(String storeId) {
    return null;
  }

  static List<UnifiedDummyMenuItem> getMenusByStore(String storeId) {
    return [];
  }

  static Map<String, String> getCategoryMapByStore(String storeId) {
    return {};
  }

  static String encodeQrPayload(String storeId) {
    return 'gangsta://store/$storeId';
  }
}
