import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/models/menu_management_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
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
    final rawItems = UnifiedDummyStoreData.getMenusByStore(
          UnifiedDummyStoreData.merchantStoreId,
        );

    return rawItems
        .map(
          (item) {
            final index = rawItems.indexOf(item);
            return MenuManagementItemModel(
            id: item.id,
            name: item.name,
            description:
                'Racikan spesial ${item.name} dengan cita rasa khas merchant untuk operasional harian.',
            categoryId: item.categoryId,
            basePrice: item.price.toDouble(),
            discountedPrice: index.isEven ? item.price.toDouble() * 0.9 : null,
            channelPricing: MenuChannelPricing(
              dineIn: item.price.toDouble(),
              takeaway: item.price.toDouble() + 1000,
              online: item.price.toDouble() + 2500,
            ),
            imageUrl: item.imageUrl,
            imageAspectRatio: 1,
            variants: const [
              MenuVariantOption(name: 'Regular', priceDelta: 0),
              MenuVariantOption(name: 'Jumbo', priceDelta: 5000),
            ],
            addOns: const [
              MenuAddOnOption(name: 'Ekstra Telur', price: 4000),
              MenuAddOnOption(name: 'Ekstra Daging', price: 7000),
            ],
            customNotes: const ['Pedas', 'Sedang', 'Tidak Pedas', 'Tanpa Bawang'],
            badges: index % 3 == 0
                ? const [MenuBadge.bestSeller]
                : index % 3 == 1
                    ? const [MenuBadge.promo]
                    : const [MenuBadge.chefsRecommendation],
            isActive: true,
            isInStock: item.isInStock,
            remainingPortions: item.isInStock ? 20 - (index % 8) : 0,
            sortOrder: index,
          );
          },
        )
        .toList();
  }
}
