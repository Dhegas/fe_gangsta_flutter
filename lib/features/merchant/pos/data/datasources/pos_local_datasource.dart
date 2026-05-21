import 'package:fe_gangsta_flutter/features/merchant/pos/data/models/pos_menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/pos/domain/entities/pos_table_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/features/merchant/table_management/domain/entities/table_status.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';

class PosLocalDataSource {
  static String? lastErrorMessage;
  static bool wasFallbackTriggered = false;

  Future<String> getMerchantName() async {
    if (ApiClient.activeTenantName != null && ApiClient.activeTenantName!.isNotEmpty) {
      return ApiClient.activeTenantName!;
    }
    return UnifiedDummyStoreData.getStoreById(
          UnifiedDummyStoreData.merchantStoreId,
        )?.name ??
        'Merchant';
  }

  Future<String> getMerchantRoleLabel() async {
    return 'Owner';
  }

  Future<List<PosCategory>> getCategories() async {
    try {
      final client = ApiClient();
      final response = await client.get('/api/v1/categories');
      if (response != null && response['data'] != null) {
        final list = response['data'] as List;
        final List<PosCategory> categories = [
          const PosCategory(id: 'all', label: 'All'),
        ];
        for (final item in list) {
          categories.add(PosCategory(
            id: item['id'].toString(),
            label: item['name'].toString(),
          ));
        }
        return categories;
      }
    } catch (e, stack) {
      lastErrorMessage = e.toString();
      wasFallbackTriggered = true;
      print("API Error in POS Categories: $e");
      print(stack);
    }

    final activeId = ApiClient.activeTenantId ?? UnifiedDummyStoreData.merchantStoreId;
    final categoryMap = UnifiedDummyStoreData.getCategoryMapByStore(activeId);

    final categories = <PosCategory>[
      const PosCategory(id: 'all', label: 'All'),
    ];
    categoryMap.forEach((id, name) {
      categories.add(PosCategory(id: id, label: name));
    });
    return categories;
  }

  Future<List<PosMenuItemModel>> getMenuItems() async {
    try {
      final client = ApiClient();
      final response = await client.get('/api/v1/menus');
      if (response != null && response['data'] != null) {
        final list = response['data'] as List;
        final List<PosMenuItemModel> menus = [];
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          menus.add(PosMenuItemModel(
            id: item['id'].toString(),
            name: item['name'].toString(),
            description: item['description']?.toString() ?? '',
            categoryId: item['category_id']?.toString() ?? 'all',
            basePrice: (item['price'] as num).toDouble(),
            discountedPrice: null,
            channelPricing: MenuChannelPricing(
              dineIn: (item['price'] as num).toDouble(),
              takeaway: (item['price'] as num).toDouble() + 1000,
              online: (item['price'] as num).toDouble() + 2500,
            ),
            imageUrl: item['image_url']?.toString() ?? '',
            badges: i % 3 == 0
                ? const [MenuBadge.bestSeller]
                : i % 3 == 1
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
            isInStock: item['is_available'] ?? true,
            remainingPortions: (item['is_available'] ?? true) ? 99 : 0,
          ));
        }
        return menus;
      }
    } catch (e, stack) {
      lastErrorMessage = e.toString();
      wasFallbackTriggered = true;
      print("API Error in POS Menu Items: $e");
      print(stack);
    }

    final activeId = ApiClient.activeTenantId ?? UnifiedDummyStoreData.merchantStoreId;
    final rawItems = UnifiedDummyStoreData.getMenusByStore(activeId);

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
    try {
      final client = ApiClient();
      final response = await client.get('/api/v1/dining-tables');
      if (response != null && response['data'] != null) {
        final list = response['data'] as List;
        final List<PosTableEntity> tables = [
          const PosTableEntity(
            id: 'takeaway',
            label: 'Takeaway',
            status: TableStatus.available,
            channel: PosSalesChannel.takeaway,
          ),
          const PosTableEntity(
            id: 'online',
            label: 'Online Delivery',
            status: TableStatus.available,
            channel: PosSalesChannel.online,
          ),
        ];
        for (final item in list) {
          tables.add(PosTableEntity(
            id: item['id'].toString(),
            label: item['table_name'].toString(),
            status: TableStatus.available,
            channel: PosSalesChannel.dineIn,
          ));
        }
        return tables;
      }
    } catch (e, stack) {
      lastErrorMessage = e.toString();
      wasFallbackTriggered = true;
      print("API Error in POS Tables: $e");
      print(stack);
    }

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
