import 'package:fe_gangsta_flutter/features/customer/menu/data/models/menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';

class MenuLocalDataSource {
  static const List<StoreEntity> _stores = [
    StoreEntity(
      id: 'bakso-pak-slamet',
      name: 'Bakso Pak Slamet',
      description: 'Bakso dan mie ayam favorit keluarga.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200',
    ),
    StoreEntity(
      id: 'soto-mbah-sari',
      name: 'Soto Mbah Sari',
      description: 'Soto khas dengan kuah rempah hangat.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=1200',
    ),
    StoreEntity(
      id: 'kopi-kedai-hangat',
      name: 'Kedai Hangat',
      description: 'Kopi, snack, dan menu ringan kekinian.',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200',
    ),
  ];

  static const Map<String, List<MenuItemModel>> _storeMenus = {
    'bakso-pak-slamet': [
      MenuItemModel(
        id: 'm1',
        categoryId: 'bakso',
        categoryName: 'Bakso',
        name: 'Bakso Urat Jumbo',
        description: 'Bakso urat kenyal dengan kuah kaldu sapi gurih.',
        price: 26000,
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=1200',
      ),
      MenuItemModel(
        id: 'm2',
        categoryId: 'bakso',
        categoryName: 'Bakso',
        name: 'Bakso Telur Spesial',
        description: 'Bakso isi telur, bihun, sawi, dan bawang goreng.',
        price: 24000,
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=1200',
      ),
      MenuItemModel(
        id: 'm3',
        categoryId: 'mie',
        categoryName: 'Mie',
        name: 'Mie Ayam Komplit',
        description: 'Mie kenyal, ayam manis gurih, pangsit, dan sawi.',
        price: 22000,
        imageUrl:
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200',
      ),
      MenuItemModel(
        id: 'm4',
        categoryId: 'minuman',
        categoryName: 'Minuman',
        name: 'Es Teh Manis',
        description: 'Teh melati dingin, manis dan segar.',
        price: 7000,
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=1200',
      ),
    ],
    'soto-mbah-sari': [
      MenuItemModel(
        id: 's1',
        categoryId: 'soto',
        categoryName: 'Soto',
        name: 'Soto Ayam Kampung',
        description: 'Soto ayam kuah bening, koya, dan telur rebus.',
        price: 23000,
        imageUrl:
            'https://images.unsplash.com/photo-1604908177078-34e8a10a5f82?w=1200',
      ),
      MenuItemModel(
        id: 's2',
        categoryId: 'soto',
        categoryName: 'Soto',
        name: 'Soto Daging',
        description: 'Potongan daging sapi empuk dengan kuah rempah.',
        price: 29000,
        imageUrl:
            'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=1200',
      ),
      MenuItemModel(
        id: 's3',
        categoryId: 'lauk',
        categoryName: 'Lauk',
        name: 'Perkedel Kentang',
        description: 'Perkedel lembut sebagai pelengkap soto.',
        price: 6000,
        imageUrl:
            'https://images.unsplash.com/photo-1514517220017-8ce97a34a7b6?w=1200',
      ),
      MenuItemModel(
        id: 's4',
        categoryId: 'minuman',
        categoryName: 'Minuman',
        name: 'Teh Hangat',
        description: 'Teh hangat manis cocok untuk cuaca dingin.',
        price: 6000,
        imageUrl:
            'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=1200',
      ),
    ],
    'kopi-kedai-hangat': [
      MenuItemModel(
        id: 'k1',
        categoryId: 'kopi',
        categoryName: 'Kopi',
        name: 'Kopi Susu Gula Aren',
        description: 'Espresso, susu, dan gula aren asli.',
        price: 22000,
        imageUrl:
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
      ),
      MenuItemModel(
        id: 'k2',
        categoryId: 'kopi',
        categoryName: 'Kopi',
        name: 'Americano',
        description: 'Kopi hitam ringan dengan aroma kuat.',
        price: 18000,
        imageUrl:
            'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=1200',
      ),
      MenuItemModel(
        id: 'k3',
        categoryId: 'snack',
        categoryName: 'Snack',
        name: 'Croffle Coklat',
        description: 'Croffle renyah dengan saus coklat premium.',
        price: 17000,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200',
      ),
      MenuItemModel(
        id: 'k4',
        categoryId: 'non-kopi',
        categoryName: 'Non Kopi',
        name: 'Matcha Latte',
        description: 'Matcha creamy dengan rasa manis seimbang.',
        price: 24000,
        imageUrl:
            'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=1200',
      ),
    ],
  };

  Future<List<StoreEntity>> getStores() async {
    return _stores;
  }

  Future<StoreEntity?> getStoreById(String storeId) async {
    for (final store in _stores) {
      if (store.id == storeId) {
        return store;
      }
    }
    return null;
  }

  Future<List<MenuCategory>> getCategoriesByStore(String storeId) async {
    final items = _storeMenus[storeId] ?? const <MenuItemModel>[];
    final categories = <MenuCategory>[
      const MenuCategory(id: 'all', name: 'Semua'),
    ];
    final seen = <String>{'all'};

    for (final item in items) {
      if (!seen.contains(item.categoryId)) {
        categories.add(
          MenuCategory(id: item.categoryId, name: item.categoryName),
        );
        seen.add(item.categoryId);
      }
    }
    return categories;
  }

  Future<List<MenuItemModel>> getMenuItemsByStore(String storeId) async {
    return _storeMenus[storeId] ?? const <MenuItemModel>[];
  }
}
