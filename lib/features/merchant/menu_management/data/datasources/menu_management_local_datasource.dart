import 'package:fe_gangsta_flutter/features/merchant/menu_management/data/models/menu_management_item_model.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_category.dart';
import 'package:fe_gangsta_flutter/features/merchant/menu_management/domain/entities/menu_management_item_entity.dart';
import 'package:fe_gangsta_flutter/core/utils/unified_dummy_store_data.dart';
import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/core/network/api_config.dart';

class MenuManagementLocalDataSource {
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

  Future<List<MenuManagementCategory>> getCategories() async {
    try {
      final client = ApiClient();
      final response = await client.get('/categories');
      if (response != null && response['data'] != null) {
        final list = response['data'] as List;
        final List<MenuManagementCategory> categories = [
          const MenuManagementCategory(id: 'all', label: 'All'),
        ];
        for (final item in list) {
          categories.add(MenuManagementCategory(
            id: item['id'].toString(),
            label: item['name'].toString(),
          ));
        }
        return categories;
      }
    } catch (e, stack) {
      print("API Error in Menu Management Categories: $e");
      print(stack);
    }

    final activeId = ApiClient.activeTenantId ?? UnifiedDummyStoreData.merchantStoreId;
    final categoryMap = UnifiedDummyStoreData.getCategoryMapByStore(activeId);

    final categories = <MenuManagementCategory>[
      const MenuManagementCategory(id: 'all', label: 'All'),
    ];
    categoryMap.forEach((id, name) {
      categories.add(MenuManagementCategory(id: id, label: name));
    });
    return categories;
  }

  Future<List<MenuManagementItemModel>> getItems() async {
    try {
      final client = ApiClient();
      final response = await client.get('/menus');
      if (response != null && response['data'] != null) {
        final list = response['data'] as List;
        final List<MenuManagementItemModel> menus = [];
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          menus.add(MenuManagementItemModel(
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
            badges: i % 3 == 0
                ? const [MenuBadge.bestSeller]
                : i % 3 == 1
                    ? const [MenuBadge.promo]
                    : const [MenuBadge.chefsRecommendation],
            isActive: true,
            isInStock: item['is_available'] ?? true,
            remainingPortions: (item['is_available'] ?? true) ? 99 : 0,
            sortOrder: i,
          ));
        }
        return menus;
      }
    } catch (e, stack) {
      print("API Error in Menu Management Items: $e");
      print(stack);
    }

    final activeId = ApiClient.activeTenantId ?? UnifiedDummyStoreData.merchantStoreId;
    final rawItems = UnifiedDummyStoreData.getMenusByStore(activeId);

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

  Future<MenuManagementCategory?> createCategory(String name) async {
    if (!ApiConfig.useMockData) {
      try {
        final client = ApiClient();
        final response = await client.post('/categories', body: {'name': name});
        if (response != null && response['data'] != null) {
          final data = response['data'];
          return MenuManagementCategory(
            id: data['id'].toString(),
            label: data['name'].toString(),
            isActive: data['is_active'] ?? true,
          );
        }
      } catch (e, stack) {
        print("API Error in Create Category: $e");
        print(stack);
      }
      return null;
    }

    // Mock implementation
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    return MenuManagementCategory(id: id, label: name);
  }

  Future<MenuManagementCategory?> updateCategory(String id, String name) async {
    if (!ApiConfig.useMockData) {
      try {
        final client = ApiClient();
        final response = await client.put('/categories/$id', body: {'name': name});
        if (response != null && response['data'] != null) {
          final data = response['data'];
          return MenuManagementCategory(
            id: data['id'].toString(),
            label: data['name'].toString(),
            isActive: data['is_active'] ?? true,
          );
        }
      } catch (e, stack) {
        print("API Error in Update Category: $e");
        print(stack);
      }
      return null;
    }

    return MenuManagementCategory(id: id, label: name);
  }

  Future<bool> deleteCategory(String id) async {
    if (!ApiConfig.useMockData) {
      try {
        final client = ApiClient();
        await client.delete('/categories/$id');
        return true;
      } catch (e, stack) {
        print("API Error in Delete Category: $e");
        print(stack);
        return false;
      }
    }
    return true;
  }

  Future<bool> toggleCategoryActive(String id, bool isActive) async {
    if (!ApiConfig.useMockData) {
      try {
        final client = ApiClient();
        await client.patch('/categories/$id/toggle-active', body: {'is_active': isActive});
        return true;
      } catch (e, stack) {
        print("API Error in Toggle Category Active: $e");
        print(stack);
        return false;
      }
    }
    return true;
  }

  Future<bool> reorderCategories(List<String> orderedIds) async {
    if (!ApiConfig.useMockData) {
      try {
        final client = ApiClient();
        await client.patch('/categories/reorder', body: {'ordered_ids': orderedIds});
        return true;
      } catch (e, stack) {
        print("API Error in Reorder Categories: $e");
        print(stack);
        return false;
      }
    }
    return true;
  }
}
