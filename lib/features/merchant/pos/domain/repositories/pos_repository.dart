import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';

abstract class PosRepository {
  Future<String> getMerchantName();

  Future<String> getMerchantRoleLabel();

  Future<List<PosCategory>> getCategories();

  Future<List<PosMenuItemEntity>> getMenuItems();

  Future<List<String>> getTableLabels();
}
