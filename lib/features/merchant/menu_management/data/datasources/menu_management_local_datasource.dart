import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/models/menu_management_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';

class MenuManagementLocalDataSource {
  Future<String> getMerchantName() async {
    return UnifiedDummyStoreData.getStoreById(
          UnifiedDummyStoreData.merchantStoreId,
        )?.name ??
        'Merchant';
  }

  Future<String> getMerchantRoleLabel() async {
    return 'Owner';
  }

  Future<List<MenuManagementCategory>> getCategories() async {
    final categoryMap = UnifiedDummyStoreData.getCategoryMapByStore(
      UnifiedDummyStoreData.merchantStoreId,
    );

    final categories = <MenuManagementCategory>[
      const MenuManagementCategory(id: 'all', label: 'All'),
    ];
    categoryMap.forEach((id, name) {
      categories.add(MenuManagementCategory(id: id, label: name));
    });
    return categories;
  }

  Future<List<MenuManagementItemModel>> getItems() async {
    return UnifiedDummyStoreData.getMenusByStore(
          UnifiedDummyStoreData.merchantStoreId,
        )
        .map(
          (item) => MenuManagementItemModel(
            id: item.id,
            name: item.name,
            categoryId: item.categoryId,
            price: item.price.toDouble(),
            imageUrl: item.imageUrl,
            isInStock: item.isInStock,
          ),
        )
        .toList();
  }
}
