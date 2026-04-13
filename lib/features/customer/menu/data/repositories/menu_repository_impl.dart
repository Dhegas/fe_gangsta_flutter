import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl(this._localDataSource);

  final MenuLocalDataSource _localDataSource;

  @override
  Future<List<StoreEntity>> getStores() => _localDataSource.getStores();

  @override
  Future<StoreEntity?> getStoreById(String storeId) =>
      _localDataSource.getStoreById(storeId);

  @override
  Future<List<MenuCategory>> getCategoriesByStore(String storeId) =>
      _localDataSource.getCategoriesByStore(storeId);

  @override
  Future<List<MenuItemEntity>> getMenuItemsByStore(String storeId) =>
      _localDataSource.getMenuItemsByStore(storeId);
}
