import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/dining_table_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_remote_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/store_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final MenuLocalDataSource _localDataSource;
  final MenuRemoteDataSource _remoteDataSource;

  @override
  Future<List<StoreEntity>> getStores({int page = 1, int limit = 10}) =>
      _remoteDataSource.getPublicTenants(page: page, limit: limit);

  @override
  Future<StoreEntity?> getStoreById(String storeId) async {
    try {
      final stores = await _remoteDataSource.getPublicTenants(page: 1, limit: 100);
      return stores.firstWhere((s) => s.id == storeId);
    } catch (_) {
      return _localDataSource.getStoreById(storeId);
    }
  }

  @override
  Future<List<MenuCategory>> getCategoriesByStore(String storeId) async {
    try {
      final store = await getStoreById(storeId);
      if (store != null && store.slug.isNotEmpty) {
        return await _remoteDataSource.getCategoriesBySlug(store.slug);
      }
    } catch (_) {
      // Fallback to local on error
    }
    return _localDataSource.getCategoriesByStore(storeId);
  }

  @override
  Future<List<MenuItemEntity>> getMenuItemsByStore(String storeId) async {
    try {
      final store = await getStoreById(storeId);
      if (store != null && store.slug.isNotEmpty) {
        final categories = await _remoteDataSource.getCategoriesBySlug(store.slug);
        final categoryMap = {for (final cat in categories) cat.id: cat.name};

        final items = await _remoteDataSource.getMenuItemsBySlug(store.slug);
        return items.map((item) {
          final catName = categoryMap[item.categoryId] ?? '';
          return MenuItemEntity(
            id: item.id,
            categoryId: item.categoryId,
            categoryName: catName,
            name: item.name,
            description: item.description,
            price: item.price,
            imageUrl: item.imageUrl,
          );
        }).toList();
      }
    } catch (_) {
      // Fallback to local on error
    }
    return _localDataSource.getMenuItemsByStore(storeId);
  }

  @override
  Future<List<DiningTableEntity>> getTablesBySlug(String slug) =>
      _remoteDataSource.getTablesBySlug(slug);
}
