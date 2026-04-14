import 'package:fe_gangsta_flutter/features/merchant/pos/data/models/pos_menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
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
    final rawItems = UnifiedDummyStoreData.getMenusByStore(
          UnifiedDummyStoreData.merchantStoreId,
        );

    return rawItems
        .map(
          (item) {
            final index = rawItems.indexOf(item);
            return PosMenuItemModel(
            id: item.id,
            name: item.name,
            description:
                'Racikan spesial ${item.name} untuk kebutuhan dine-in, takeaway, dan online order.',
            categoryId: item.categoryId,
            basePrice: item.price.toDouble(),
            discountedPrice: index.isEven ? item.price.toDouble() * 0.9 : null,
            channelPricing: MenuChannelPricing(
              dineIn: item.price.toDouble(),
              takeaway: item.price.toDouble() + 1000,
              online: item.price.toDouble() + 2500,
            ),
            imageUrl: item.imageUrl,
            badges: index % 3 == 0
                ? const [MenuBadge.bestSeller]
                : index % 3 == 1
                    ? const [MenuBadge.promo]
                    : const [MenuBadge.chefsRecommendation],
            variants: const [
              MenuVariantOption(name: 'Regular', priceDelta: 0),
              MenuVariantOption(name: 'Jumbo', priceDelta: 5000),
            ],
            addOns: const [
              MenuAddOnOption(name: 'Ekstra Telur', price: 4000),
              MenuAddOnOption(name: 'Ekstra Daging', price: 7000),
            ],
            customNotes: const ['Pedas', 'Sedang', 'Tidak Pedas', 'Tanpa Bawang'],
            isActive: true,
            isInStock: item.isAvailable,
            remainingPortions: item.isAvailable ? 18 - (index % 7) : 0,
          );
          },
        )
        .toList();
  }

  Future<List<PosTableEntity>> getTables() async {
    return const [
      PosTableEntity(
        id: 'takeaway',
        label: 'Takeaway',
        status: TableStatus.available,
        channel: PosSalesChannel.takeaway,
      ),
      PosTableEntity(
        id: 'online',
        label: 'Online Delivery',
        status: TableStatus.available,
        channel: PosSalesChannel.online,
      ),
      PosTableEntity(
        id: 'T01',
        label: 'T01',
        status: TableStatus.available,
        channel: PosSalesChannel.dineIn,
      ),
      PosTableEntity(
        id: 'T02',
        label: 'T02',
        status: TableStatus.occupied,
        channel: PosSalesChannel.dineIn,
      ),
      PosTableEntity(
        id: 'T03',
        label: 'T03',
        status: TableStatus.reserved,
        channel: PosSalesChannel.dineIn,
      ),
      PosTableEntity(
        id: 'T04',
        label: 'T04',
        status: TableStatus.cleaning,
        channel: PosSalesChannel.dineIn,
      ),
      PosTableEntity(
        id: 'T05',
        label: 'T05',
        status: TableStatus.available,
        channel: PosSalesChannel.dineIn,
      ),
    ];
  }
}
