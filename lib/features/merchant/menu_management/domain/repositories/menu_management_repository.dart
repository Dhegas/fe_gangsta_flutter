import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';

abstract class MenuManagementRepository {
  Future<String> getMerchantName();

  Future<String> getMerchantRoleLabel();

  Future<List<MenuManagementCategory>> getCategories();

  Future<List<MenuManagementItemEntity>> getItems();
}
