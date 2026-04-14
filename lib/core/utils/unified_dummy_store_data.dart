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

class _MenuTemplate {
  const _MenuTemplate({
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
  });

  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final int basePrice;
  final String imageUrl;
}

class UnifiedDummyStoreData {
  const UnifiedDummyStoreData._();

  static const String merchantStoreId = 'bakso-pak-slamet';

  static const List<String> merchantTableLabels = [
    'Takeaway',
    'Table 01',
    'Table 02',
    'Table 03',
    'Table 04',
    'Table 05',
  ];

  static final List<UnifiedDummyStore> stores = [
    UnifiedDummyStore(
      id: 'bakso-pak-slamet',
      name: 'Bakso Pak Slamet',
      description: 'Bakso dan mie ayam legendaris dengan kuah kaldu sapi.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200',
      ownerName: 'Slamet Riyadi',
      status: 'active',
      subscriptionPlan: 'Pro',
      joinDate: DateTime(2024, 1, 10),
    ),
    UnifiedDummyStore(
      id: 'mie-ayam-jakarta',
      name: 'Mie Ayam Jakarta',
      description: 'Mie ayam topping melimpah dan pangsit renyah.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=1200',
      ownerName: 'Budi Santoso',
      status: 'active',
      subscriptionPlan: 'Basic',
      joinDate: DateTime(2024, 3, 18),
    ),
    UnifiedDummyStore(
      id: 'soto-betawi-bang-haji',
      name: 'Soto Betawi Bang Haji',
      description: 'Soto Betawi santan gurih dengan daging sapi empuk.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=1200',
      ownerName: 'Haji Sulaiman',
      status: 'pending',
      subscriptionPlan: 'Pro',
      joinDate: DateTime(2025, 11, 3),
    ),
    UnifiedDummyStore(
      id: 'ayam-geprek-mercon',
      name: 'Ayam Geprek Mercon',
      description: 'Ayam geprek level pedas bertingkat favorit anak muda.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1562967914-608f82629710?w=1200',
      ownerName: 'Wati Susilowati',
      status: 'active',
      subscriptionPlan: 'Enterprise',
      joinDate: DateTime(2024, 8, 12),
    ),
    UnifiedDummyStore(
      id: 'nasi-goreng-bang-udin',
      name: 'Nasi Goreng Bang Udin',
      description: 'Nasi goreng smoky wok hei dengan topping komplet.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=1200',
      ownerName: 'Udin Maulana',
      status: 'inactive',
      subscriptionPlan: 'Basic',
      joinDate: DateTime(2023, 9, 7),
    ),
    UnifiedDummyStore(
      id: 'gudeg-mbak-yuni',
      name: 'Gudeg Mbak Yuni',
      description: 'Gudeg Jogja otentik dengan krecek dan ayam kampung.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=1200',
      ownerName: 'Yuni Kartika',
      status: 'active',
      subscriptionPlan: 'Pro',
      joinDate: DateTime(2025, 2, 14),
    ),
    UnifiedDummyStore(
      id: 'sate-madura-cak-rif',
      name: 'Sate Madura Cak Rif',
      description: 'Sate ayam dan kambing dengan bumbu kacang spesial.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=1200',
      ownerName: 'Arif Rahman',
      status: 'active',
      subscriptionPlan: 'Enterprise',
      joinDate: DateTime(2024, 12, 5),
    ),
    UnifiedDummyStore(
      id: 'martabak-kampoeng',
      name: 'Martabak Kampoeng',
      description: 'Martabak manis dan telur dengan topping premium.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200',
      ownerName: 'Andi Prakoso',
      status: 'pending',
      subscriptionPlan: 'Basic',
      joinDate: DateTime(2026, 4, 2),
    ),
    UnifiedDummyStore(
      id: 'rawon-surabaya-pak-de',
      name: 'Rawon Surabaya Pak De',
      description: 'Rawon khas Jawa Timur dengan kuah hitam kaya rempah.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?w=1200',
      ownerName: 'Dedi Kurniawan',
      status: 'active',
      subscriptionPlan: 'Pro',
      joinDate: DateTime(2025, 6, 21),
    ),
    UnifiedDummyStore(
      id: 'kedai-kopi-hangat',
      name: 'Kedai Kopi Hangat',
      description: 'Kopi susu, pastry, dan menu brunch ringan harian.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200',
      ownerName: 'Sinta Maharani',
      status: 'active',
      subscriptionPlan: 'Enterprise',
      joinDate: DateTime(2024, 10, 30),
    ),
  ];

  static const List<_MenuTemplate> _menuTemplates = [
    _MenuTemplate(
      categoryId: 'main_course',
      categoryName: 'Makanan Utama',
      name: 'Nasi Ayam Bakar',
      description: 'Nasi hangat, ayam bakar bumbu kecap, sambal, dan lalapan.',
      basePrice: 26000,
      imageUrl:
          'https://images.unsplash.com/photo-1604908177078-34e8a10a5f82?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'main_course',
      categoryName: 'Makanan Utama',
      name: 'Mie Ayam Spesial',
      description: 'Mie kenyal, topping ayam manis gurih, plus pangsit rebus.',
      basePrice: 24000,
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'main_course',
      categoryName: 'Makanan Utama',
      name: 'Bakso Urat Jumbo',
      description: 'Bakso urat porsi besar dengan kuah kaldu bening.',
      basePrice: 28000,
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'appetizers',
      categoryName: 'Camilan',
      name: 'Tahu Crispy Cabai Garam',
      description: 'Tahu goreng tepung renyah dengan taburan cabai garam.',
      basePrice: 15000,
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'appetizers',
      categoryName: 'Camilan',
      name: 'Kentang Goreng Keju',
      description: 'Kentang goreng tebal dengan keju dan mayo pedas.',
      basePrice: 17000,
      imageUrl:
          'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'drinks',
      categoryName: 'Minuman',
      name: 'Es Teh Lemon',
      description: 'Teh melati dingin dengan lemon segar.',
      basePrice: 9000,
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'drinks',
      categoryName: 'Minuman',
      name: 'Kopi Susu Gula Aren',
      description: 'Espresso blend house dengan susu segar dan gula aren.',
      basePrice: 22000,
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'drinks',
      categoryName: 'Minuman',
      name: 'Lychee Tea',
      description: 'Teh hitam harum dengan sirup leci dan es batu.',
      basePrice: 18000,
      imageUrl:
          'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'desserts',
      categoryName: 'Dessert',
      name: 'Pisang Bakar Cokelat',
      description: 'Pisang bakar hangat dengan saus cokelat dan keju.',
      basePrice: 16000,
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=1200',
    ),
    _MenuTemplate(
      categoryId: 'desserts',
      categoryName: 'Dessert',
      name: 'Puding Regal',
      description: 'Puding susu lembut dengan topping biskuit regal.',
      basePrice: 14000,
      imageUrl:
          'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=1200',
    ),
  ];

  static UnifiedDummyStore? getStoreById(String storeId) {
    for (final store in stores) {
      if (store.id == storeId) {
        return store;
      }
    }
    return null;
  }

  static List<UnifiedDummyMenuItem> getMenusByStore(String storeId) {
    final index = _storeIndex(storeId);
    if (index == -1) {
      return const <UnifiedDummyMenuItem>[];
    }

    final menuCount = 8 + (index % 3);
    final storeKey = storeId.replaceAll('-', '_');

    return List<UnifiedDummyMenuItem>.generate(menuCount, (i) {
      final template = _menuTemplates[(i + index) % _menuTemplates.length];
      final priceAdjustment = (index % 4) * 1000;

      return UnifiedDummyMenuItem(
        id: '${storeKey}_m${i + 1}',
        categoryId: template.categoryId,
        categoryName: template.categoryName,
        name: template.name,
        description: template.description,
        price: template.basePrice + priceAdjustment,
        imageUrl: template.imageUrl,
        isAvailable: (i + index) % 7 != 0,
        isInStock: (i + index) % 5 != 0,
      );
    });
  }

  static Map<String, String> getCategoryMapByStore(String storeId) {
    final items = getMenusByStore(storeId);
    final categories = <String, String>{};

    for (final item in items) {
      categories[item.categoryId] = item.categoryName;
    }

    return categories;
  }

  static String encodeQrPayload(String storeId) {
    return 'gangsta://store/$storeId';
  }

  static int _storeIndex(String storeId) {
    for (var i = 0; i < stores.length; i++) {
      if (stores[i].id == storeId) {
        return i;
      }
    }
    return -1;
  }
}
