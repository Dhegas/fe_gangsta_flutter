import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';

abstract class MenuManagementRepository {
  Future<String> getMerchantName();

  Future<String> getMerchantRoleLabel();

  Future<List<MenuManagementCategory>> getCategories();

  Future<List<MenuManagementItemEntity>> getItems();

  Future<MenuManagementCategory?> createCategory(String name);

  Future<MenuManagementCategory?> updateCategory(String id, String name);

  Future<bool> deleteCategory(String id);

  Future<bool> toggleCategoryActive(String id, bool isActive);

  Future<bool> reorderCategories(List<String> orderedIds);

  Future<MenuManagementItemEntity?> createItem({
    required String name,
    required String description,
    required double price,
    required String? categoryId,
    required String imageUrl,
  });

  Future<MenuManagementItemEntity?> updateItem({
    required String id,
    required String name,
    required String description,
    required double price,
    required String? categoryId,
    required String imageUrl,
  });

  Future<bool> deleteItem(String id);

  Future<bool> toggleItemAvailable(String id, bool isAvailable);
}
