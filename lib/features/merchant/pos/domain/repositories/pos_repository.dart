import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_menu_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_order_line_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';

abstract class PosRepository {
  Future<String> getMerchantName();

  Future<String> getMerchantRoleLabel();

  Future<List<PosCategory>> getCategories();

  Future<List<PosMenuItemEntity>> getMenuItems();

  Future<List<PosTableEntity>> getTables();

  Future<bool> checkoutOrder({
    required String? diningTableName,
    required String customerName,
    required List<PosOrderLineEntity> items,
  });
}
