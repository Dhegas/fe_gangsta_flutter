import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_category.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/domain/entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<String> getStoreName();

  Future<List<MenuCategory>> getCategories();

  Future<List<MenuItemEntity>> getMenuItems();
}
