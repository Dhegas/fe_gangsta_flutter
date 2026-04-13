import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';

abstract class MenuRepository {
  Future<List<StoreEntity>> getStores();

  Future<StoreEntity?> getStoreById(String storeId);

  Future<List<MenuCategory>> getCategoriesByStore(String storeId);

  Future<List<MenuItemEntity>> getMenuItemsByStore(String storeId);
}
