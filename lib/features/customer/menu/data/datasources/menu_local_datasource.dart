import 'package:fe_gangsta_flutter/features/customer/menu/data/models/menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class MenuLocalDataSource {
  Future<List<StoreEntity>> getStores() async {
    return UnifiedDummyStoreData.stores
        .map(
          (store) => StoreEntity(
            id: store.id,
            name: store.name,
            description: store.description,
            bannerImageUrl: store.bannerImageUrl,
          ),
        )
        .toList();
  }

  Future<StoreEntity?> getStoreById(String storeId) async {
    final store = UnifiedDummyStoreData.getStoreById(storeId);
    if (store == null) {
      return null;
    }

    return StoreEntity(
      id: store.id,
      name: store.name,
      description: store.description,
      bannerImageUrl: store.bannerImageUrl,
    );
  }

  Future<List<MenuCategory>> getCategoriesByStore(String storeId) async {
    final items = UnifiedDummyStoreData.getMenusByStore(storeId);
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
    return UnifiedDummyStoreData.getMenusByStore(storeId)
        .map(
          (item) => MenuItemModel(
            id: item.id,
            categoryId: item.categoryId,
            categoryName: item.categoryName,
            name: item.name,
            description: item.description,
            price: item.price,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();
  }
}
