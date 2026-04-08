import 'package:fe_gangsta_flutter/features/customer/menu/data/datasources/menu_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl(this._localDataSource);

  final MenuLocalDataSource _localDataSource;

  @override
  Future<List<MenuCategory>> getCategories() =>
      _localDataSource.getCategories();

  @override
  Future<List<MenuItemEntity>> getMenuItems() =>
      _localDataSource.getMenuItems();

  @override
  Future<String> getStoreName() => _localDataSource.getStoreName();
}
