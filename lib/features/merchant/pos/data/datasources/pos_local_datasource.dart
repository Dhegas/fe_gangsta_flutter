import 'package:fe_gangsta_flutter/features/merchant/pos/data/models/pos_menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class PosLocalDataSource {
  Future<String> getMerchantName() async {
    return UnifiedDummyStoreData.getStoreById(
          UnifiedDummyStoreData.merchantStoreId,
        )?.name ??
        'Merchant';
  }

  Future<String> getMerchantRoleLabel() async {
    return 'Owner';
  }

  Future<List<PosCategory>> getCategories() async {
    final categoryMap = UnifiedDummyStoreData.getCategoryMapByStore(
      UnifiedDummyStoreData.merchantStoreId,
    );

    final categories = <PosCategory>[
      const PosCategory(id: 'all', label: 'All'),
    ];
    categoryMap.forEach((id, name) {
      categories.add(PosCategory(id: id, label: name));
    });
    return categories;
  }

  Future<List<PosMenuItemModel>> getMenuItems() async {
    return UnifiedDummyStoreData.getMenusByStore(
          UnifiedDummyStoreData.merchantStoreId,
        )
        .map(
          (item) => PosMenuItemModel(
            id: item.id,
            name: item.name,
            categoryId: item.categoryId,
            price: item.price.toDouble(),
            imageUrl: item.imageUrl,
            isAvailable: item.isAvailable,
          ),
        )
        .toList();
  }

  Future<List<String>> getTableLabels() async {
    return UnifiedDummyStoreData.merchantTableLabels;
  }
}
