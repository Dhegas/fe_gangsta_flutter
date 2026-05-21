import 'package:fe_gangsta_flutter/core/services/api_client.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/models/dining_table_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/models/category_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/models/menu_item_model.dart';
import 'package:fe_gangsta_flutter/features/customer/menu/data/models/store_model.dart';

class MenuRemoteDataSource {
  MenuRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StoreModel>> getPublicTenants() async {
    try {
      final response = await _apiClient.get('/api/v1/public/tenants');
      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final dataList = response['data'] as List<dynamic>? ?? [];
          return dataList
              .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // Let it bubble up or return empty depending on requirement, bubbling is cleaner for clean arch error handling
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategoriesBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/api/v1/public/tenant/$slug/categories');
      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final dataList = response['data'] as List<dynamic>? ?? [];
          return dataList
              .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MenuItemModel>> getMenuItemsBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/api/v1/public/tenant/$slug/menus');
      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final dataList = response['data'] as List<dynamic>? ?? [];
          return dataList
              .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DiningTableModel>> getTablesBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/api/v1/public/tenant/$slug/tables');
      if (response != null && response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          final dataList = response['data'] as List<dynamic>? ?? [];
          return dataList
              .map((json) => DiningTableModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
