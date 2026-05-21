import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/datasources/menu_management_local_datasource.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/repositories/menu_management_repository.dart';

class MenuManagementRepositoryImpl implements MenuManagementRepository {
  MenuManagementRepositoryImpl(this._localDataSource);

  final MenuManagementLocalDataSource _localDataSource;

  @override
  Future<List<MenuManagementCategory>> getCategories() {
    return _localDataSource.getCategories();
  }

  @override
  Future<List<MenuManagementItemEntity>> getItems() {
    return _localDataSource.getItems();
  }

  @override
  Future<String> getMerchantName() {
    return _localDataSource.getMerchantName();
  }

  @override
  Future<String> getMerchantRoleLabel() {
    return _localDataSource.getMerchantRoleLabel();
  }

  @override
  Future<MenuManagementCategory?> createCategory(String name) {
    return _localDataSource.createCategory(name);
  }

  @override
  Future<MenuManagementCategory?> updateCategory(String id, String name) {
    return _localDataSource.updateCategory(id, name);
  }

  @override
  Future<bool> deleteCategory(String id) {
    return _localDataSource.deleteCategory(id);
  }

  @override
  Future<bool> toggleCategoryActive(String id, bool isActive) {
    return _localDataSource.toggleCategoryActive(id, isActive);
  }

  @override
  Future<bool> reorderCategories(List<String> orderedIds) {
    return _localDataSource.reorderCategories(orderedIds);
  }
}
